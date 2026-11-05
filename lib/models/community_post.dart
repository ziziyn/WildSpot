import 'package:flutter/foundation.dart';

import 'species_category.dart';

/// Seberapa halus koordinat sebuah observasi boleh dibagikan.
///
/// Spesies terancam atau rawan perburuan memakai [obscured]: titik publik
/// dibulatkan ke grid 0.1° (sekitar 11 km) supaya sarang atau individu
/// tidak bisa dilacak dari feed.
enum LocationPrecision { precise, obscured }

/// Satu observasi di feed komunitas. Tidak berisi data tiruan.
@immutable
class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.locationLabel,
    required this.timeAgo,
    required this.body,
    required this.category,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.locationPrecision = LocationPrecision.precise,
    this.confirmCount = 0,
    this.isConfirmed = false,
    this.fieldNoteCount = 0,
    this.isReported = false,
  });

  final String id;
  final String authorName;
  final String authorAvatarUrl;

  /// Nama kawasan yang aman ditampilkan, misalnya nama taman nasional.
  final String locationLabel;
  final String timeAgo;
  final String body;
  final SpeciesCategory category;
  final String? imageUrl;

  /// Titik asli. Lapisan peta atau jarak hanya boleh membaca [publicLatitude]
  /// dan [publicLongitude].
  final double? latitude;
  final double? longitude;
  final LocationPrecision locationPrecision;

  /// Jumlah konfirmasi identifikasi dari kontributor lain.
  final int confirmCount;
  final bool isConfirmed;

  /// Catatan lapangan yang sudah ditambahkan ke observasi ini.
  final int fieldNoteCount;

  /// Gangguan habitat di sekitar observasi sudah dilaporkan.
  final bool isReported;

  bool get isLocationObscured =>
      locationPrecision == LocationPrecision.obscured;

  /// Lintang yang aman dibagikan. Null bila titik asli belum ada.
  double? get publicLatitude => _publicCoordinate(latitude, locationPrecision);

  /// Bujur yang aman dibagikan. Null bila titik asli belum ada.
  double? get publicLongitude =>
      _publicCoordinate(longitude, locationPrecision);

  CommunityPost copyWith({
    String? id,
    String? authorName,
    String? authorAvatarUrl,
    String? locationLabel,
    String? timeAgo,
    String? body,
    SpeciesCategory? category,
    String? imageUrl,
    double? latitude,
    double? longitude,
    LocationPrecision? locationPrecision,
    int? confirmCount,
    bool? isConfirmed,
    int? fieldNoteCount,
    bool? isReported,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      locationLabel: locationLabel ?? this.locationLabel,
      timeAgo: timeAgo ?? this.timeAgo,
      body: body ?? this.body,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationPrecision: locationPrecision ?? this.locationPrecision,
      confirmCount: confirmCount ?? this.confirmCount,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      fieldNoteCount: fieldNoteCount ?? this.fieldNoteCount,
      isReported: isReported ?? this.isReported,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunityPost &&
          other.id == id &&
          other.isConfirmed == isConfirmed &&
          other.confirmCount == confirmCount &&
          other.fieldNoteCount == fieldNoteCount &&
          other.isReported == isReported;

  @override
  int get hashCode =>
      Object.hash(id, isConfirmed, confirmCount, fieldNoteCount, isReported);
}

/// Grid publik untuk [LocationPrecision.obscured]. 0.1° ≈ 11 km di khatulistiwa.
const double kObscuredLocationGridDegrees = 0.1;

double? _publicCoordinate(double? value, LocationPrecision precision) {
  if (value == null) return null;
  if (precision == LocationPrecision.precise) return value;
  final steps = (value / kObscuredLocationGridDegrees).round();
  return steps / 10;
}
