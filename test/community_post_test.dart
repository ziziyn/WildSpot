import 'package:flutter_test/flutter_test.dart';
import 'package:wild_spot/models/community_post.dart';
import 'package:wild_spot/models/species_category.dart';

void main() {
  test('obscured coordinates snap to a 0.1 degree grid', () {
    const post = CommunityPost(
      id: 'leuser',
      authorName: 'Sari Wulandari',
      authorAvatarUrl: 'https://example.com/a.jpg',
      locationLabel: 'Taman Nasional Gunung Leuser',
      timeAgo: '2h',
      body: 'Sumatran orangutan',
      category: SpeciesCategory.fauna,
      latitude: 3.5418,
      longitude: 97.6284,
      locationPrecision: LocationPrecision.obscured,
    );

    expect(post.publicLatitude, 3.5);
    expect(post.publicLongitude, 97.6);
    expect(post.publicLatitude, isNot(post.latitude));
    expect(post.publicLongitude, isNot(post.longitude));
  });

  test('precise coordinates stay unchanged', () {
    const post = CommunityPost(
      id: 'fungi',
      authorName: 'Ayu Lestari',
      authorAvatarUrl: 'https://example.com/a.jpg',
      locationLabel: 'Taman Nasional Gunung Leuser',
      timeAgo: '1d',
      body: 'Cookeina speciosa',
      category: SpeciesCategory.fungi,
      latitude: 3.6821,
      longitude: 97.5412,
      locationPrecision: LocationPrecision.precise,
    );

    expect(post.publicLatitude, 3.6821);
    expect(post.publicLongitude, 97.5412);
  });
}
