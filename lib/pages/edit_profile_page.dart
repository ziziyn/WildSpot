import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/user_avatar.dart';
import '../core/app_theme.dart';
import '../core/user_scope.dart';

const int _kNameMax = 30;
const int _kBioMax = 150;

/// Flutter mengecilkan floating label ke 75% saat berada di atas field.
/// Dipakai agar ukuran label akhir (14sp) sama dengan tombol "Edit picture".
const double _kFloatingLabelScale = 0.75;

/// Halaman Edit Profile: ubah foto, nama, dan bio.
///
/// Dibuka lewat `Navigator.push` dari Profile Page (tanpa bottom nav).
/// Nama disimpan ke `UserController`; bio dikembalikan ke pemanggil lewat
/// `Navigator.pop` (String), karena bio belum menjadi bagian dari
/// `UserProfile`. Menekan Cancel (atau back) menutup halaman tanpa menyimpan
/// (hasil null); jika sudah ada perubahan, user diminta konfirmasi discard.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.initialBio});

  final String initialBio;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;

  // Nilai awal untuk mendeteksi perubahan (dibandingkan setelah trim).
  String _initialName = '';
  late final String _initialBio;

  @override
  void initState() {
    super.initState();
    _initialBio = widget.initialBio.trim();
    _nameCtrl = TextEditingController();
    _bioCtrl = TextEditingController(text: widget.initialBio);
  }

  bool _nameInitialised = false;

  // Nama awal dibaca dari UserScope; InheritedWidget tidak boleh dibaca di
  // initState, jadi diisi sekali di sini.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_nameInitialised) {
      _nameCtrl.text = context.currentUser.name;
      _initialName = _nameCtrl.text.trim();
      _nameInitialised = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  /// True jika nama atau bio berbeda dari nilai awal.
  bool get _hasChanges =>
      _nameCtrl.text.trim() != _initialName ||
      _bioCtrl.text.trim() != _initialBio;

  // TODO: pilih foto (galeri/kamera) lalu unggah; hasilnya jadi avatarUrl baru.
  void _pickAvatar() {}

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || !_hasChanges) return;

    final controller = UserScope.of(context);
    controller.update(controller.profile.copyWith(name: name));
    Navigator.of(context).pop(_bioCtrl.text.trim());
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Rebuild setiap teks berubah: dipakai PopScope dan tombol Save.
    return ListenableBuilder(
      listenable: Listenable.merge([_nameCtrl, _bioCtrl]),
      builder: (context, _) {
        final canSave = _nameCtrl.text.trim().isNotEmpty && _hasChanges;

        // canPop false saat ada perubahan → Cancel (maybePop) dan gestur/tombol
        // back sistem sama-sama melewati dialog konfirmasi.
        return PopScope(
          canPop: !_hasChanges,
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
              title: const Text('Edit Profile'),
            ),
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  children: [
                    // ── Avatar (ganti foto lewat tombol "Edit picture")
                    const UserAvatar(size: UserAvatarSize.large),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _pickAvatar,
                      child: Text(
                        'Edit picture',
                        style: tt.labelLarge!.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Name
                    _CounterField(
                      controller: _nameCtrl,
                      label: 'Name',
                      helper: 'Shown on your profile and posts',
                      maxLength: _kNameMax,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 20),

                    // ── Bio
                    _CounterField(
                      controller: _bioCtrl,
                      label: 'Bio',
                      helper: 'Tell others what you explore',
                      maxLength: _kBioMax,
                      minLines: 4,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
            ),

            // ── Tombol simpan (menempel di bawah, naik saat keyboard muncul)
            // Nonaktif (abu-abu) jika nama kosong atau belum ada perubahan.
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
                      onPressed: canSave ? _save : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: context.wsBrand.forest,
                        foregroundColor: cs.onPrimary,
                        // Standar disabled M3 (12% / 38% onSurface) → abu-abu.
                        disabledBackgroundColor: cs.onSurface.withAlpha(0x1F),
                        disabledForegroundColor: cs.onSurface.withAlpha(0x61),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(WsRadius.pill),
                        ),
                      ),
                      child: Text(
                        'Save changes',
                        style: tt.labelLarge!.copyWith(
                          color: canSave
                              ? cs.onPrimary
                              : cs.onSurface.withAlpha(0x61),
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
//  FIELD DENGAN LABEL MENGAMBANG, HELPER, DAN COUNTER "n / max"
// ═══════════════════════════════════════════════════════════════════

/// Membatasi input di [maxLength] karakter (lewat formatter bawaan Flutter) dan
/// memberi tahu lewat [onOverflow] saat user mencoba mengetik/paste melebihi
/// batas.
class _LimitAlertFormatter extends TextInputFormatter {
  _LimitAlertFormatter({required int maxLength, required this.onOverflow})
      : _inner = LengthLimitingTextInputFormatter(maxLength);

  final LengthLimitingTextInputFormatter _inner;
  final VoidCallback onOverflow;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final result = _inner.formatEditUpdate(oldValue, newValue);
    if (result.text != newValue.text) onOverflow(); // input ditolak/dipotong
    return result;
  }
}

class _CounterField extends StatefulWidget {
  const _CounterField({
    required this.controller,
    required this.label,
    required this.helper,
    required this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final String helper;
  final int maxLength;
  final int? minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;

  @override
  State<_CounterField> createState() => _CounterFieldState();
}

class _CounterFieldState extends State<_CounterField> {
  // True setelah user mencoba mengetik melewati batas; kembali false begitu
  // panjang teks turun di bawah batas.
  final ValueNotifier<bool> _limitHit = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _limitHit.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_limitHit.value &&
        widget.controller.text.characters.length < widget.maxLength) {
      _limitHit.value = false;
    }
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

    // Label disetarakan dengan "Edit picture" (labelLarge, w700, primary).
    // Ukuran dibagi skala floating label supaya hasil akhirnya tetap 14sp.
    final labelStyle = tt.labelLarge!.copyWith(
      color: cs.primary,
      fontWeight: FontWeight.w700,
      fontSize: tt.labelLarge!.fontSize! / _kFloatingLabelScale,
    );

    return ValueListenableBuilder<bool>(
      valueListenable: _limitHit,
      builder: (context, limitHit, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: widget.controller,
              // Batas ditangani formatter (bukan maxLength) agar percobaan
              // mengetik melewati batas bisa dideteksi.
              inputFormatters: [
                _LimitAlertFormatter(
                  maxLength: widget.maxLength,
                  onOverflow: () => _limitHit.value = true,
                ),
              ],
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              textCapitalization: widget.textCapitalization,
              cursorColor: forest,
              style: tt.bodyLarge,
              decoration: InputDecoration(
                labelText: widget.label,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: labelStyle,
                floatingLabelStyle: labelStyle,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                enabledBorder: border(limitHit ? cs.error : cs.outline),
                focusedBorder: border(limitHit ? cs.error : forest, 2),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: Text(widget.helper, style: tt.bodySmall)),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: widget.controller,
                    builder: (context, value, _) => Text(
                      '${value.text.characters.length} / ${widget.maxLength}',
                      style: tt.bodySmall!.copyWith(
                        color: limitHit ? cs.error : null,
                        fontWeight: limitHit ? FontWeight.w700 : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}