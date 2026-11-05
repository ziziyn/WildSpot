import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';

const int _kNameMax = 60;
const int _kDescMax = 300;
const int _kMaxPhotos = 3;

/// Flutter mengecilkan floating label ke 75% saat berada di atas field.
/// Dipakai agar ukuran label akhir (14sp) sama dengan halaman Edit Profile.
const double _kFloatingLabelScale = 0.75;

const double _kTileWidth = 72;
const double _kTileHeight = 96;

const _kMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(DateTime d) => '${d.day} ${_kMonths[d.month - 1]} ${d.year}';

String _formatTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String _formatCoordinates(double lat, double lng) =>
    '${lat.abs().toStringAsFixed(4)}° ${lat >= 0 ? 'N' : 'S'}, '
    '${lng.abs().toStringAsFixed(4)}° ${lng >= 0 ? 'E' : 'W'}';

/// Hasil dari [UploadLogPage], dikembalikan lewat `Navigator.pop`.
/// Kategori, lokasi, dan waktu tidak ikut karena sudah dimiliki pemanggil.
class UploadLogData {
  const UploadLogData({
    required this.name,
    required this.description,
    required this.photos,
    required this.isNewName,
  });

  final String name;
  final String description;
  final List<ImageProvider> photos;

  /// True jika nama tidak ada di daftar `knownNames` (user menambah nama baru).
  final bool isNewName;
}

/// Halaman Upload Log: dibuka setelah foto diambil di CameraPage.
///
/// Yang bisa diisi user: foto (1–3), "What did you find?", dan deskripsi.
/// Kategori, lokasi, tanggal, dan jam diterima dari pemanggil dan hanya
/// ditampilkan (terkunci).
///
/// Upload baru aktif setelah "What did you find?" terisi. Menekan Upload
/// mengembalikan [UploadLogData] lewat `Navigator.pop`; proses unggah ke
/// server dilakukan pemanggil. Menekan Cancel (atau back) menutup
/// halaman tanpa hasil (null); jika sudah ada input, user diminta konfirmasi.
class UploadLogPage extends StatefulWidget {
  const UploadLogPage({
    super.key,
    required this.category,
    required this.photos,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    required this.knownNames,
    required this.onAddPhoto,
  }) : assert(photos.length >= 1 && photos.length <= _kMaxPhotos);

  /// 'Flora' | 'Fauna' | 'Fungi' — kategori yang dipilih di CameraPage.
  final String category;

  /// Foto awal dari kamera (1–3).
  final List<ImageProvider> photos;

  /// Nama tempat hasil deteksi lokasi, mis. "Major's Hill Park, Ottawa".
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime capturedAt;

  /// Nama yang sudah dikenal untuk kategori ini; disaring sesuai ketikan user.
  final List<String> knownNames;

  /// Dipanggil saat tombol + ditekan (mis. buka kamera). Kembalikan foto baru,
  /// atau null jika dibatalkan.
  final Future<ImageProvider?> Function() onAddPhoto;

  @override
  State<UploadLogPage> createState() => _UploadLogPageState();
}

class _UploadLogPageState extends State<UploadLogPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  late final List<ImageProvider> _photos = List.of(widget.photos);
  bool _addingPhoto = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  /// True jika user sudah mengisi sesuatu atau mengubah daftar foto.
  bool get _hasChanges =>
      _nameCtrl.text.trim().isNotEmpty ||
      _descCtrl.text.trim().isNotEmpty ||
      !listEquals(_photos, widget.photos);

  Future<void> _addPhoto() async {
    if (_addingPhoto || _photos.length >= _kMaxPhotos) return;
    _addingPhoto = true;
    final photo = await widget.onAddPhoto();
    _addingPhoto = false;
    if (photo == null || !mounted || _photos.length >= _kMaxPhotos) return;
    setState(() => _photos.add(photo));
  }

  void _removePhoto(int index) {
    if (_photos.length <= 1) return; // minimal satu foto
    setState(() => _photos.removeAt(index));
  }

  void _upload() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return; // nama wajib diisi
    final isNew =
        !widget.knownNames.any((n) => n.toLowerCase() == name.toLowerCase());

    Navigator.of(context).pop(
      UploadLogData(
        name: name,
        description: _descCtrl.text.trim(),
        photos: List.unmodifiable(_photos),
        isNewName: isNew,
      ),
    );
  }

  /// Dialog konfirmasi discard. Mengembalikan true jika user memilih "Yes".
  Future<bool> _confirmDiscard() async {
    final cs = Theme.of(context).colorScheme;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'Are you sure you want to discard your changes? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text(
              'Yes',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Iterable<_Suggestion> _suggestionsFor(TextEditingValue value) {
    final query = value.text.trim();
    if (query.isEmpty) return const Iterable<_Suggestion>.empty();

    final lower = query.toLowerCase();
    final matches = widget.knownNames
        .where((n) => n.toLowerCase().contains(lower))
        .take(5)
        .map((n) => _Suggestion(n))
        .toList();
    final exactExists = widget.knownNames.any((n) => n.toLowerCase() == lower);

    return [
      ...matches,
      if (!exactExists) _Suggestion(query, isNew: true),
    ];
  }

  /// Membungkus field "What did you find?" dengan daftar saran. Daftar muncul
  /// tepat di bawah kotak input (menutupi baris helper), seperti di mockup.
  Widget _withSuggestions(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    Widget field,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) => RawAutocomplete<_Suggestion>(
        textEditingController: controller,
        focusNode: focusNode,
        displayStringForOption: (o) => o.text,
        optionsBuilder: _suggestionsFor,
        fieldViewBuilder: (context, textController, focus, onSubmitted) =>
            field,
        optionsViewBuilder: (context, onSelected, options) => _SuggestionList(
          width: constraints.maxWidth,
          query: controller.text.trim(),
          category: widget.category,
          options: options.toList(),
          onSelected: onSelected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Rebuild setiap teks berubah: dipakai PopScope dan tombol Upload.
    return ListenableBuilder(
      listenable: Listenable.merge([_nameCtrl, _descCtrl]),
      builder: (context, _) {
        final hasChanges = _hasChanges; // untuk konfirmasi saat Cancel
        final canUpload = _nameCtrl.text.trim().isNotEmpty;
        final disabledFg = cs.onSurface.withAlpha(0x61);

        // canPop false saat ada perubahan → Cancel (maybePop) dan gestur/tombol
        // back sistem sama-sama melewati dialog konfirmasi.
        return PopScope(
          canPop: !hasChanges,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final discard = await _confirmDiscard();
            if (discard && context.mounted) Navigator.of(context).pop();
          },
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 64,
              centerTitle: true,
              leadingWidth: 96,
              leading: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Navigator.maybePop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: cs.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    'Cancel',
                    style: tt.labelLarge!.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              title: const Text('Upload Log'),
            ),
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  children: [
                    // ── Foto (1–3)
                    _PhotoStrip(
                      photos: _photos,
                      category: widget.category,
                      onAdd: _addPhoto,
                      onRemove: _removePhoto,
                    ),
                    const SizedBox(height: 20),

                    // ── What did you find? (dengan daftar saran)
                    _LimitedField(
                      controller: _nameCtrl,
                      label: 'What did you find?',
                      hint: 'Search or type a name',
                      helper: 'Pick from the list or add a new one',
                      maxLength: _kNameMax,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      wrapField: _withSuggestions,
                    ),
                    const SizedBox(height: 20),

                    // ── Description (tumbuh mengikuti isi)
                    _LimitedField(
                      controller: _descCtrl,
                      label: 'Description',
                      hint: 'Describe what you saw',
                      helper: 'Habitat, behaviour, anything notable',
                      maxLength: _kDescMax,
                      minLines: 3,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 20),

                    // ── Data otomatis (terkunci)
                    _LockedInfo(
                      category: widget.category,
                      locationName: widget.locationName,
                      coordinates: _formatCoordinates(
                        widget.latitude,
                        widget.longitude,
                      ),
                      date: _formatDate(widget.capturedAt),
                      time: _formatTime(widget.capturedAt),
                    ),
                  ],
                ),
              ),
            ),

            // ── Tombol upload (menempel di bawah, naik saat keyboard muncul)
            // Nonaktif (abu-abu) selama nama belum diisi.
            bottomNavigationBar: Material(
              color: cs.surface,
              elevation: 8,
              shadowColor: cs.shadow,
              surfaceTintColor: Colors.transparent,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: canUpload ? _upload : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: context.wsBrand.forest,
                        foregroundColor: cs.onPrimary,
                        // Standar disabled M3 (12% / 38% onSurface) → abu-abu.
                        disabledBackgroundColor: cs.onSurface.withAlpha(0x1F),
                        disabledForegroundColor: disabledFg,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(WsRadius.pill),
                        ),
                      ),
                      child: Text(
                        'Upload',
                        style: tt.labelLarge!.copyWith(
                          color: canUpload ? cs.onPrimary : disabledFg,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  IKON KATEGORI
//  Sama dengan pilihan di CameraPage: Flora, Fauna, Fungi.
// ═══════════════════════════════════════════════════════════════════

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon(this.category, {this.size = 20, this.color});

  final String category;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    switch (category.toLowerCase()) {
      case 'fungi':
        return ImageIcon(
          const AssetImage('assets/mushroom.png'),
          size: size,
          color: color,
        );
      case 'fauna':
        return Icon(Icons.pets_outlined, size: size, color: color);
      case 'flora':
      default:
        return Icon(Icons.eco_outlined, size: size, color: color);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  FOTO: tile, tombol hapus (x), tombol tambah (+), dan keterangan
// ═══════════════════════════════════════════════════════════════════

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({
    required this.photos,
    required this.category,
    required this.onAdd,
    required this.onRemove,
  });

  final List<ImageProvider> photos;
  final String category;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final count = photos.length;
    final canRemove = count > 1; // minimal satu foto
    final canAdd = count < _kMaxPhotos;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              _PhotoTile(
                image: photos[i],
                category: category,
                onRemove: canRemove ? () => onRemove(i) : null,
              ),
            ],
            if (canAdd) ...[
              const SizedBox(width: 12),
              _AddPhotoTile(onTap: onAdd),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          canAdd
              ? 'Photos · $count / $_kMaxPhotos'
              : 'Photos · $count / $_kMaxPhotos · maximum reached',
          style: tt.bodySmall,
        ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.image,
    required this.category,
    required this.onRemove,
  });

  final ImageProvider image;
  final String category;

  /// Null saat hanya ada satu foto → tombol x tidak ditampilkan.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: _kTileWidth,
      height: _kTileHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.all(WsRadius.lg),
              child: Image(
                image: image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: cs.surfaceContainerHigh,
                  child: Center(
                    child: _CategoryIcon(category, size: 28, color: cs.primary),
                  ),
                ),
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: 0,
              right: 0,
              child: Semantics(
                button: true,
                label: 'Remove photo',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onRemove,
                  // Area sentuh 40dp, lingkaran yang terlihat 24dp.
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: cs.onSurface.withAlpha(0xCC),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 14, color: cs.surface),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Add photo',
      child: Material(
        color: cs.surfaceContainer,
        borderRadius: const BorderRadius.all(WsRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: _kTileWidth,
            height: _kTileHeight,
            child: Icon(Icons.add, size: 28, color: cs.primary),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  FIELD DENGAN LABEL MENGAMBANG, HELPER, DAN COUNTER "n / max"
//  Saat user mencoba mengetik melewati batas: outline, label, pesan, dan
//  counter jadi merah.
// ═══════════════════════════════════════════════════════════════════

/// Membatasi panjang teks seperti [LengthLimitingTextInputFormatter], sekaligus
/// melapor ke [onOverflowChanged] apakah input terakhir ditolak karena sudah
/// melewati batas. Perubahan yang hanya memindah kursor diabaikan.
class _LimitFormatter extends TextInputFormatter {
  _LimitFormatter(int maxLength, this.onOverflowChanged)
      : _inner = LengthLimitingTextInputFormatter(maxLength);

  final LengthLimitingTextInputFormatter _inner;
  final ValueChanged<bool> onOverflowChanged;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final result = _inner.formatEditUpdate(oldValue, newValue);
    if (newValue.text != oldValue.text) {
      onOverflowChanged(result.text != newValue.text);
    }
    return result;
  }
}

class _LimitedField extends StatefulWidget {
  const _LimitedField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.helper,
    required this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.wrapField,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String helper;
  final int maxLength;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;

  /// Membungkus kotak input saja (tanpa baris helper), mis. dengan daftar saran.
  final Widget Function(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    Widget field,
  )? wrapField;

  @override
  State<_LimitedField> createState() => _LimitedFieldState();
}

class _LimitedFieldState extends State<_LimitedField> {
  final FocusNode _focusNode = FocusNode();

  /// True saat user mencoba mengetik melewati batas; kembali false pada
  /// perubahan teks berikutnya yang diterima (mis. menghapus).
  final ValueNotifier<bool> _overLimit = ValueNotifier<bool>(false);

  late final TextInputFormatter _limiter =
      _LimitFormatter(widget.maxLength, (v) => _overLimit.value = v);

  @override
  void dispose() {
    _focusNode.dispose();
    _overLimit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final forest = context.wsBrand.forest;

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: const BorderRadius.all(WsRadius.lg),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ListenableBuilder(
      listenable: Listenable.merge([widget.controller, _overLimit]),
      builder: (context, _) {
        final length = widget.controller.text.characters.length;
        final overLimit = _overLimit.value;

        // Ukuran dibagi skala floating label supaya hasil akhirnya 14sp.
        final labelStyle = tt.labelLarge!.copyWith(
          color: overLimit ? cs.error : cs.primary,
          fontWeight: FontWeight.w700,
          fontSize: tt.labelLarge!.fontSize! / _kFloatingLabelScale,
        );

        final feedbackStyle = tt.bodySmall!.copyWith(
          color: overLimit ? cs.error : null,
          fontWeight: overLimit ? FontWeight.w700 : null,
        );

        final field = TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          // Batas ditangani formatter (bukan maxLength) agar percobaan
          // mengetik melewati batas bisa dideteksi.
          inputFormatters: [_limiter],
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          cursorColor: overLimit ? cs.error : forest,
          style: tt.bodyLarge,
          decoration: InputDecoration(
            labelText: widget.label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: labelStyle,
            floatingLabelStyle: labelStyle,
            hintText: widget.hint,
            hintStyle: tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: border(overLimit ? cs.error : cs.outline),
            focusedBorder: border(overLimit ? cs.error : forest, 2),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.wrapField != null
                ? widget.wrapField!(context, widget.controller, _focusNode, field)
                : field,
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      overLimit ? 'Character limit reached' : widget.helper,
                      style: feedbackStyle,
                    ),
                  ),
                  Text('$length / ${widget.maxLength}', style: feedbackStyle),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DAFTAR SARAN (responsif terhadap ketikan, seperti hashtag Instagram)
// ═══════════════════════════════════════════════════════════════════

class _Suggestion {
  const _Suggestion(this.text, {this.isNew = false});

  final String text;

  /// True untuk baris "Add “…” as new".
  final bool isNew;
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.width,
    required this.query,
    required this.category,
    required this.options,
    required this.onSelected,
  });

  final double width;
  final String query;
  final String category;
  final List<_Suggestion> options;
  final AutocompleteOnSelected<_Suggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Material(
          elevation: 6,
          color: cs.surfaceContainerLowest,
          shadowColor: cs.shadow,
          surfaceTintColor: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(WsRadius.lg),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: width,
              maxWidth: width,
              maxHeight: 280,
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final highlighted =
                    AutocompleteHighlightedOption.of(context) == index;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (option.isNew && index > 0) const Divider(height: 1),
                    InkWell(
                      onTap: () => onSelected(option),
                      child: Container(
                        width: double.infinity,
                        color: highlighted ? cs.surfaceContainer : null,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: _SuggestionRow(
                          option: option,
                          query: query,
                          category: category,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({
    required this.option,
    required this.query,
    required this.category,
  });

  final _Suggestion option;
  final String query;
  final String category;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final Widget label;
    if (option.isNew) {
      label = Text(
        'Add “${option.text}” as new',
        style: tt.bodyLarge!.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      // Bagian yang cocok dengan ketikan dicetak tebal.
      final base = tt.bodyLarge!;
      final text = option.text;
      final start = query.isEmpty ? -1 : text.toLowerCase().indexOf(query.toLowerCase());
      final end = start + query.length;
      label = (start < 0 || end > text.length)
          ? Text(text, style: base, maxLines: 1, overflow: TextOverflow.ellipsis)
          : Text.rich(
              TextSpan(
                style: base,
                children: [
                  TextSpan(text: text.substring(0, start)),
                  TextSpan(
                    text: text.substring(start, end),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: text.substring(end)),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
    }

    return Row(
      children: [
        _CategoryIcon(category, size: 20, color: cs.primary),
        const SizedBox(width: 16),
        Expanded(child: label),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DATA OTOMATIS (TERKUNCI): kategori, lokasi, tanggal, jam
// ═══════════════════════════════════════════════════════════════════

class _LockedInfo extends StatelessWidget {
  const _LockedInfo({
    required this.category,
    required this.locationName,
    required this.coordinates,
    required this.date,
    required this.time,
  });

  final String category;
  final String locationName;
  final String coordinates;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              Icon(Icons.lock_outline, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Detected automatically, can’t be edited',
                style: tt.bodySmall!.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: const BorderRadius.all(WsRadius.lg),
          ),
          child: Column(
            children: [
              _InfoRow(
                icon: _CategoryIcon(category, color: cs.onSurfaceVariant),
                label: 'Category',
                value: category,
              ),
              const Divider(height: 1),
              _InfoRow(
                icon: Icon(Icons.location_on_outlined,
                    size: 20, color: cs.onSurfaceVariant),
                label: 'Location',
                value: locationName,
                extra: Text(
                  coordinates,
                  style: context.wsMono.stat.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const Divider(height: 1),
              Row(
                children: [
                  Expanded(
                    child: _InfoRow(
                      icon: Icon(Icons.calendar_today_outlined,
                          size: 20, color: cs.onSurfaceVariant),
                      label: 'Date',
                      value: date,
                    ),
                  ),
                  Expanded(
                    child: _InfoRow(
                      icon: Icon(Icons.schedule,
                          size: 20, color: cs.onSurfaceVariant),
                      label: 'Time',
                      value: time,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.extra,
  });

  final Widget icon;
  final String label;
  final String value;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(width: 20, height: 20, child: icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.bodySmall),
                Text(value, style: tt.bodyLarge),
                if (extra != null) ...[
                  const SizedBox(height: 2),
                  extra!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}