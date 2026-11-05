/// Taksonomi pusat WildSpot.
///
/// Home, kamera, dan observasi memakai label yang sama: All, Fauna, Flora,
/// dan Fungi. Community membaca enum ini, bukan daftar kategori sendiri.
enum SpeciesCategory {
  all,
  fauna,
  flora,
  fungi;

  String get label => switch (this) {
    SpeciesCategory.all => 'All',
    SpeciesCategory.fauna => 'Fauna',
    SpeciesCategory.flora => 'Flora',
    SpeciesCategory.fungi => 'Fungi',
  };
}
