import '../models/community_post.dart';
import '../models/species_category.dart';
import 'community_repository.dart';

/// Feed tiruan bertema alam Indonesia. Gambar tiap pos adalah foto spesies
/// yang disebut di teksnya (Wikimedia Commons).
class MockCommunityRepository implements CommunityRepository {
  const MockCommunityRepository();

  @override
  List<CommunityPost> fetchFollowing() => List<CommunityPost>.of(_following);

  @override
  List<CommunityPost> fetchDiscovery() => List<CommunityPost>.of(_discovery);
}

const _avatarSari =
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80';
const _avatarDimas =
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80';
const _avatarAyu =
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80';
const _avatarRaka =
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80';
const _avatarIntan =
    'https://images.unsplash.com/photo-1521119989659-a83eee488004?w=200&q=80';
const _avatarYoga =
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80';
const _avatarMelati =
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80';
const _avatarFarhan =
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80';

const _orangutanMother =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Induk_Orangutan_Sumatera_sedang_memberi_makan_anaknya.jpg/1280px-Induk_Orangutan_Sumatera_sedang_memberi_makan_anaknya.jpg';
const _rafflesia =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Rafflesia_Arnoldii_Batang_Palupuah_Indonesia.jpg/1280px-Rafflesia_Arnoldii_Batang_Palupuah_Indonesia.jpg';
const _cookeina =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/Cookeina_speciosa.jpg/1280px-Cookeina_speciosa.jpg';
const _kedih =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/Kedih_Baby_Thomas_Leaf_Monkey.jpg/1280px-Kedih_Baby_Thomas_Leaf_Monkey.jpg';
const _nepenthes =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Nepenthes_sumatrana.jpg/1280px-Nepenthes_sumatrana.jpg';
const _komodo =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Varanus_komodoensis.jpg/1280px-Varanus_komodoensis.jpg';
const _kuauRaja =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Kuau_Raja.jpg/1280px-Kuau_Raja.jpg';
const _youngOrangutan =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Young_orang_utan.JPG/1280px-Young_orang_utan.JPG';

const _following = <CommunityPost>[
  CommunityPost(
    id: 'f1',
    authorName: 'Sari Wulandari',
    authorAvatarUrl: _avatarSari,
    locationLabel: 'Taman Nasional Gunung Leuser',
    timeAgo: '2h',
    body: 'Sumatran orangutan mother feeding her infant in the Gunung Leuser canopy. Please confirm the ID. The exact point stays hidden because this species is critically endangered.',
    category: SpeciesCategory.fauna,
    imageUrl: _orangutanMother,
    latitude: 3.5418,
    longitude: 97.6284,
    locationPrecision: LocationPrecision.obscured,
    confirmCount: 18,
    fieldNoteCount: 4,
  ),
  CommunityPost(
    id: 'f2',
    authorName: 'Dimas Pratama',
    authorAvatarUrl: _avatarDimas,
    locationLabel: 'Batang Palupuh, Sumatera Barat',
    timeAgo: '5h',
    body: 'Rafflesia arnoldii in bloom at Batang Palupuh. The flower only lasts a few days, and the trail edge around it is getting trampled. Confirm the ID if the petals match.',
    category: SpeciesCategory.flora,
    imageUrl: _rafflesia,
    latitude: -0.2471,
    longitude: 100.3644,
    locationPrecision: LocationPrecision.obscured,
    confirmCount: 11,
    isConfirmed: true,
    fieldNoteCount: 6,
  ),
  CommunityPost(
    id: 'f3',
    authorName: 'Ayu Lestari',
    authorAvatarUrl: _avatarAyu,
    locationLabel: 'Taman Nasional Gunung Leuser',
    timeAgo: '1d',
    body: 'Cookeina speciosa fruiting on a fallen log in Leuser. I left the dead wood in place so the fungus can finish its cycle.',
    category: SpeciesCategory.fungi,
    imageUrl: _cookeina,
    latitude: 3.6821,
    longitude: 97.5412,
    locationPrecision: LocationPrecision.precise,
    confirmCount: 7,
    fieldNoteCount: 3,
  ),
  CommunityPost(
    id: 'f4',
    authorName: 'Raka Mahendra',
    authorAvatarUrl: _avatarRaka,
    locationLabel: 'Bukit Lawang, Sumatera Utara',
    timeAgo: '6h',
    body: 'Thomas\'s langur (kedih) at the forest edge in Bukit Lawang. The pale underside looks like Presbytis thomasi — can someone help confirm the ID?',
    category: SpeciesCategory.fauna,
    imageUrl: _kedih,
    latitude: 3.5447,
    longitude: 98.1236,
    locationPrecision: LocationPrecision.obscured,
    confirmCount: 5,
    fieldNoteCount: 2,
  ),
];

const _discovery = <CommunityPost>[
  CommunityPost(
    id: 'd1',
    authorName: 'Intan Permata',
    authorAvatarUrl: _avatarIntan,
    locationLabel: 'Sumatera Utara',
    timeAgo: '1h',
    body: 'Nepenthes sumatrana pitcher in a lowland Sumatran forest. Easy to miss among the undergrowth. The location is obscured to reduce collection pressure.',
    category: SpeciesCategory.flora,
    imageUrl: _nepenthes,
    latitude: 1.8214,
    longitude: 98.9122,
    locationPrecision: LocationPrecision.obscured,
    confirmCount: 3,
    fieldNoteCount: 1,
  ),
  CommunityPost(
    id: 'd2',
    authorName: 'Yoga Saputra',
    authorAvatarUrl: _avatarYoga,
    locationLabel: 'Taman Nasional Komodo',
    timeAgo: '3h',
    body: 'Komodo dragon crossing open ground inside Komodo National Park. Kept well back. Sharing the sighting without a precise coordinate.',
    category: SpeciesCategory.fauna,
    imageUrl: _komodo,
    latitude: -8.5512,
    longitude: 119.4891,
    locationPrecision: LocationPrecision.obscured,
    confirmCount: 22,
    fieldNoteCount: 8,
  ),
  CommunityPost(
    id: 'd3',
    authorName: 'Melati Kusuma',
    authorAvatarUrl: _avatarMelati,
    locationLabel: 'Bukit Lawang, Sumatera Utara',
    timeAgo: '8h',
    body: 'Great argus (kuau raja) on the forest floor near Bukit Lawang. The eye-spots across the wing were unmistakable.',
    category: SpeciesCategory.fauna,
    imageUrl: _kuauRaja,
    latitude: 3.556,
    longitude: 98.141,
    locationPrecision: LocationPrecision.obscured,
    confirmCount: 9,
    fieldNoteCount: 2,
  ),
  CommunityPost(
    id: 'd4',
    authorName: 'Farhan Yusuf',
    authorAvatarUrl: _avatarFarhan,
    locationLabel: 'Bukit Lawang, Taman Nasional Gunung Leuser',
    timeAgo: '12h',
    body: 'Young Sumatran orangutan moving through the mid-canopy at Bukit Lawang. Observation only — no approach.',
    category: SpeciesCategory.fauna,
    imageUrl: _youngOrangutan,
    latitude: 3.5388,
    longitude: 97.6511,
    locationPrecision: LocationPrecision.obscured,
    confirmCount: 14,
    fieldNoteCount: 5,
  ),
];
