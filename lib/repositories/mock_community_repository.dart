import '../models/community_post.dart';
import '../models/species_category.dart';
import 'community_repository.dart';

/// Feed tiruan bertema alam Indonesia. Gambar tiap pos adalah foto spesies
/// yang disebut di teksnya (Wikimedia Commons).
///
/// Posts without [imageUrl] render as [DiscussionCard] (text-only).
/// Posts with    [imageUrl] render as [ObservationCard] (photo-backed).
///
/// Both lists are top-level `const` so the data is deterministic across
/// hot-restarts and full restarts — no randomness, no instability.
class MockCommunityRepository implements CommunityRepository {
  const MockCommunityRepository();

  @override
  List<CommunityPost> fetchFollowing() => List<CommunityPost>.of(_following);

  @override
  List<CommunityPost> fetchDiscovery() => List<CommunityPost>.of(_discovery);
}

// ─── Avatar URLs ────────────────────────────────────────────────────────────

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
const _avatarBudi =
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80';
const _avatarCitra =
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80';

// ─── Image URLs ──────────────────────────────────────────────────────────────

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

// ─── Following feed ──────────────────────────────────────────────────────────
//
// Deterministic, interleaved mix of ObservationCard + DiscussionCard.
// Order is fixed; never shuffled.

const _following = <CommunityPost>[
  // ── Observation 1 ───────────────────────────────────────────────────────
  CommunityPost(
    id: 'f1',
    authorName: 'Sari Wulandari',
    authorAvatarUrl: _avatarSari,
    locationLabel: 'Taman Nasional Gunung Leuser',
    timeAgo: '2h',
    body:
        'Sumatran orangutan mother feeding her infant in the Gunung Leuser canopy. The exact point stays hidden because this species is critically endangered.',
    category: SpeciesCategory.fauna,
    imageUrl: _orangutanMother,
    latitude: 3.5418,
    longitude: 97.6284,
    locationPrecision: LocationPrecision.obscured,
    confirmCount: 18,
    commentCount: 7,
    fieldNoteCount: 4,
  ),
  // ── Discussion 1 ────────────────────────────────────────────────────────
  CommunityPost(
    id: 'f5',
    authorName: 'Budi Santoso',
    authorAvatarUrl: _avatarBudi,
    locationLabel: 'Sumatra',
    timeAgo: '3h',
    body:
        'Has anyone else noticed fewer hornbills along the Leuser highway corridor this season? Last year the count was much higher near the same transect.',
    category: SpeciesCategory.fauna,
    commentCount: 14,
  ),
  // ── Observation 2 ───────────────────────────────────────────────────────
  CommunityPost(
    id: 'f2',
    authorName: 'Dimas Pratama',
    authorAvatarUrl: _avatarDimas,
    locationLabel: 'Batang Palupuh, Sumatera Barat',
    timeAgo: '5h',
    body:
        'Rafflesia arnoldii in bloom at Batang Palupuh. The flower only lasts a few days, and the trail edge around it is getting trampled. Confirm the ID if the petals match.',
    category: SpeciesCategory.flora,
    imageUrl: _rafflesia,
    latitude: -0.2471,
    longitude: 100.3644,
    locationPrecision: LocationPrecision.obscured,
    confirmCount: 11,
    isConfirmed: true,
    commentCount: 6,
    fieldNoteCount: 6,
  ),
  // ── Discussion 2 ────────────────────────────────────────────────────────
  CommunityPost(
    id: 'f6',
    authorName: 'Citra Dewi',
    authorAvatarUrl: _avatarCitra,
    locationLabel: 'Jawa Tengah',
    timeAgo: '7h',
    body:
        'Best time of day to photograph jewel beetles without disturbing their roosting behaviour? I usually go midday but the heat is brutal.',
    category: SpeciesCategory.fauna,
    commentCount: 9,
  ),
  // ── Observation 3 ───────────────────────────────────────────────────────
  CommunityPost(
    id: 'f3',
    authorName: 'Ayu Lestari',
    authorAvatarUrl: _avatarAyu,
    locationLabel: 'Taman Nasional Gunung Leuser',
    timeAgo: '1d',
    body:
        'Cookeina speciosa fruiting on a fallen log in Leuser. I left the dead wood in place so the fungus can finish its cycle.',
    category: SpeciesCategory.fungi,
    imageUrl: _cookeina,
    latitude: 3.6821,
    longitude: 97.5412,
    locationPrecision: LocationPrecision.precise,
    confirmCount: 7,
    commentCount: 3,
    fieldNoteCount: 3,
  ),
  // ── Observation 4 ───────────────────────────────────────────────────────
  CommunityPost(
    id: 'f4',
    authorName: 'Raka Mahendra',
    authorAvatarUrl: _avatarRaka,
    locationLabel: 'Bukit Lawang, Sumatera Utara',
    timeAgo: '6h',
    body:
        "Thomas's langur (kedih) at the forest edge in Bukit Lawang. The pale underside looks like Presbytis thomasi — can someone help confirm the ID?",
    category: SpeciesCategory.fauna,
    imageUrl: _kedih,
    latitude: 3.5447,
    longitude: 98.1236,
    locationPrecision: LocationPrecision.obscured,
    confirmCount: 5,
    commentCount: 2,
    fieldNoteCount: 2,
  ),
];

// ─── Discovery feed ──────────────────────────────────────────────────────────
//
// Deterministic interleaved mix: ObservationCard + DiscussionCard.
// Near You radius = 300 km from device (3.595, 98.672 — Medan area).

const _discovery = <CommunityPost>[
  // ── Observation 1 — within Near You radius (~196 km) ────────────────────
  CommunityPost(
    id: 'd1',
    authorName: 'Intan Permata',
    authorAvatarUrl: _avatarIntan,
    locationLabel: 'Sumatera Utara',
    timeAgo: '1h',
    body:
        'Nepenthes sumatrana pitcher in a lowland Sumatran forest. Easy to miss among the undergrowth. The location is obscured to reduce collection pressure.',
    category: SpeciesCategory.flora,
    imageUrl: _nepenthes,
    // ≈ 196 km south of device — within Near You 300 km radius.
    latitude: 1.8214,
    longitude: 98.9122,
    locationPrecision: LocationPrecision.obscured,
    confirmCount: 3,
    commentCount: 5,
    fieldNoteCount: 1,
  ),
  // ── Discussion 1 — text-only, no coordinates ────────────────────────────
  CommunityPost(
    id: 'd5',
    authorName: 'Budi Santoso',
    authorAvatarUrl: _avatarBudi,
    locationLabel: 'Sumatra',
    timeAgo: '2h',
    body:
        'What is the best protocol for reporting a potential new Rafflesia bud site without exposing the exact location publicly? Looking for community input.',
    category: SpeciesCategory.flora,
    commentCount: 11,
  ),
  // ── Observation 2 — outside Near You radius (~1 700 km) ─────────────────
  CommunityPost(
    id: 'd2',
    authorName: 'Yoga Saputra',
    authorAvatarUrl: _avatarYoga,
    locationLabel: 'Taman Nasional Komodo',
    timeAgo: '3h',
    body:
        'Komodo dragon crossing open ground inside Komodo National Park. Kept well back. Sharing the sighting without a precise coordinate.',
    category: SpeciesCategory.fauna,
    imageUrl: _komodo,
    // Komodo (≈ 1 700 km from device) — intentionally outside Near You radius.
    latitude: -8.5512,
    longitude: 119.4891,
    locationPrecision: LocationPrecision.obscured,
    confirmCount: 22,
    commentCount: 8,
    fieldNoteCount: 8,
  ),
  // ── Discussion 2 — text-only, no coordinates ────────────────────────────
  CommunityPost(
    id: 'd6',
    authorName: 'Citra Dewi',
    authorAvatarUrl: _avatarCitra,
    locationLabel: 'Indonesia',
    timeAgo: '5h',
    body:
        'My ancient woodland indicator checklist: bluebell, wood anemone, dog\'s mercury, and ramsons. What would you add for Sumatran primary forest?',
    category: SpeciesCategory.flora,
    commentCount: 23,
  ),
  // ── Observation 3 — within Near You radius (~59 km) ─────────────────────
  CommunityPost(
    id: 'd3',
    authorName: 'Melati Kusuma',
    authorAvatarUrl: _avatarMelati,
    locationLabel: 'Bukit Lawang, Sumatera Utara',
    timeAgo: '8h',
    body:
        'Great argus (kuau raja) on the forest floor near Bukit Lawang. The eye-spots across the wing were unmistakable.',
    category: SpeciesCategory.fauna,
    imageUrl: _kuauRaja,
    // ≈ 59 km west of device — within Near You 300 km radius.
    latitude: 3.556,
    longitude: 98.141,
    locationPrecision: LocationPrecision.obscured,
    confirmCount: 9,
    commentCount: 4,
    fieldNoteCount: 2,
  ),
  // ── Observation 4 — within Near You radius ───────────────────────────────
  CommunityPost(
    id: 'd4',
    authorName: 'Farhan Yusuf',
    authorAvatarUrl: _avatarFarhan,
    locationLabel: 'Bukit Lawang, Taman Nasional Gunung Leuser',
    timeAgo: '12h',
    body:
        'Young Sumatran orangutan moving through the mid-canopy at Bukit Lawang. Observation only — no approach.',
    category: SpeciesCategory.fauna,
    imageUrl: _youngOrangutan,
    latitude: 3.5388,
    longitude: 97.6511,
    locationPrecision: LocationPrecision.obscured,
    confirmCount: 14,
    commentCount: 6,
    fieldNoteCount: 5,
  ),
];
