import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/app_theme.dart';
import 'camera_page.dart';

// ============================================================
// OBSERVATION PAGE
// ============================================================

class ObservationScreen extends StatefulWidget {
  const ObservationScreen({super.key});

  @override
  State<ObservationScreen> createState() => _ObservationPageState();
}

class _ObservationPageState extends State<ObservationScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<_Observation> _observations = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;

  String? _errorMessage;
  String _selectedTab = 'Recent';

  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchObservations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // FETCH OBSERVATIONS
  // ============================================================

  Future<void> _fetchObservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
    });

    try {
      final uri = Uri.https('api.inaturalist.org', '/v1/observations', {
        'per_page': '30',
        'page': '1',
        'order_by': 'observed_on',
        'order': 'desc',
        'photos': 'true',
        'geo': 'true',
      });

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('API request failed');
      }

      final Map<String, dynamic> jsonData =
          jsonDecode(response.body) as Map<String, dynamic>;

      final List<dynamic> results = jsonData['results'] as List<dynamic>? ?? [];

      final observations = results
          .map((item) => _Observation.fromJson(item as Map<String, dynamic>))
          .where((item) => item.photoUrl.isNotEmpty)
          .toList();

      setState(() {
        _observations = observations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load observations.';
      });
    }
  }

  // ============================================================
  // SEARCH BY TAG
  // ============================================================

  Future<void> _searchObservations(String query) async {
    final searchQuery = query.trim();

    if (searchQuery.isEmpty) {
      await _fetchObservations();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
    });

    try {
      final uri = Uri.https('api.inaturalist.org', '/v1/observations', {
        'per_page': '30',
        'page': '1',
        'order_by': 'observed_on',
        'order': 'desc',
        'photos': 'true',
        'geo': 'true',
        'q': searchQuery,
        'search_on': 'tags',
      });

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('API search request failed');
      }

      final Map<String, dynamic> jsonData =
          jsonDecode(response.body) as Map<String, dynamic>;

      final List<dynamic> results = jsonData['results'] as List<dynamic>? ?? [];

      final observations = results
          .map((item) => _Observation.fromJson(item as Map<String, dynamic>))
          .where((item) => item.photoUrl.isNotEmpty)
          .toList();

      setState(() {
        _observations = observations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to search observations.';
      });
    }
  }

  // ============================================================
  // LOAD MORE
  // ============================================================

  Future<void> _loadMoreObservations() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;

      final uri = Uri.https('api.inaturalist.org', '/v1/observations', {
        'per_page': '20',
        'page': '$nextPage',
        'order_by': 'observed_on',
        'order': 'desc',
        'photos': 'true',
        'geo': 'true',
      });

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('API request failed');
      }

      final Map<String, dynamic> jsonData =
          jsonDecode(response.body) as Map<String, dynamic>;

      final List<dynamic> results = jsonData['results'] as List<dynamic>? ?? [];

      final newObservations = results
          .map((item) => _Observation.fromJson(item as Map<String, dynamic>))
          .where((item) => item.photoUrl.isNotEmpty)
          .toList();

      setState(() {
        _observations.addAll(newObservations);
        _currentPage = nextPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.surface,
      child: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              color: cs.primary,
              backgroundColor: cs.surfaceContainer,
              onRefresh: _fetchObservations,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSearchBar(),
                        const SizedBox(height: 14),
                        _buildFilters(),
                        const SizedBox(height: 24),
                        _buildCommunityHeader(),
                        const SizedBox(height: 12),
                        _buildObservationContent(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              right: 18,
              bottom: 24,
              child: FloatingActionButton(
                backgroundColor: cs.primary,
                foregroundColor: cs.surface,
                elevation: 5,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CameraPage()),
                  );
                },
                child: const Icon(Icons.camera_alt_rounded, size: 23),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(13),
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (value) {
          _searchObservations(value);
        },
        style: TextStyle(color: cs.primary, fontSize: 13),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: cs.onSurfaceVariant,
            size: 20,
          ),
          hintText: 'Search by tag...',
          hintStyle: TextStyle(
            color: cs.onSurfaceVariant.withValues(alpha: 0.75),
            fontSize: 13,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        _buildTab('Recent'),
        const SizedBox(width: 7),
        _buildTab('Nearby'),
        const SizedBox(width: 7),
        _buildTab('Popular'),
        const Spacer(),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(11),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            icon: Icon(
              Icons.tune_rounded,
              color: cs.onSurfaceVariant,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String title) {
    final cs = Theme.of(context).colorScheme;
    final bool active = _selectedTab == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: active ? cs.primary : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active ? cs.surface : cs.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COMMUNITY HEADER
  // ============================================================

  Widget _buildCommunityHeader() {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(Icons.groups_rounded, color: cs.primary, size: 19),
        const SizedBox(width: 7),
        Text(
          'Community Feed',
          style: TextStyle(
            color: cs.primary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // OBSERVATION CONTENT
  // ============================================================

  Widget _buildObservationContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    final observations = _observations;

    if (observations.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        ...observations.map(
          (observation) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildObservationCard(observation),
          ),
        ),
        const SizedBox(height: 4),
        _buildViewOtherObservationsButton(),
      ],
    );
  }

  // ============================================================
  // VIEW OTHER OBSERVATIONS
  // ============================================================

  Widget _buildViewOtherObservationsButton() {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: _isLoadingMore ? null : _loadMoreObservations,
        icon: _isLoadingMore
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.primary,
                ),
              )
            : const Icon(Icons.visibility_outlined, size: 17),
        label: Text(
          _isLoadingMore
              ? 'Loading Observations...'
              : 'View Other Observations',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.primary.withValues(alpha: 0.65), width: 1),
          backgroundColor: cs.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ============================================================
  // OBSERVATION CARD
  // ============================================================

  Widget _buildObservationCard(_Observation observation) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.35,
                child: Image.network(
                  observation.photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: cs.surface,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: cs.onSurfaceVariant,
                          size: 35,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Container(
                      color: cs.surface,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: cs.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // CATEGORY
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        observation.isFlora
                            ? Icons.eco_rounded
                            : Icons.pets_rounded,
                        color: cs.primary,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        observation.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // STATUS
              Positioned(
                left: 12,
                bottom: 12,
                child: _buildStatusChip(observation.qualityGrade),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SPECIES NAME
                // Ikon info/! di sebelah kanan
                // sudah dihapus.
                Text(
                  observation.commonName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  observation.scientificName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 11),

                // LOCATION
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: cs.primary,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        observation.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // TIME
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: cs.onSurfaceVariant,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      observation.timeAgo,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                // TAGS
                if (observation.tags.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: observation.tags
                        .take(4)
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                color: cs.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _buildStatusChip(String status) {
    final cs = Theme.of(context).colorScheme;

    final normalizedStatus = status.toLowerCase();

    final bool needsId =
        normalizedStatus == 'needs_id' || normalizedStatus == 'needs id';

    final Color statusColor = needsId ? context.wsBrand.amber : cs.primary;

    final String displayStatus = status
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}'
                    '${word.substring(1)}',
        )
        .join(' ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            needsId
                ? Icons.help_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: statusColor,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            displayStatus,
            style: TextStyle(
              color: statusColor,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: cs.onSurfaceVariant, size: 40),
            const SizedBox(height: 12),
            Text(
              'Unable to load observations',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: _fetchObservations,
              child: Text(
                'Try Again',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: cs.onSurfaceVariant, size: 35),
          const SizedBox(height: 10),
          Text(
            'No observations found',
            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            'Try another tag.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// OBSERVATION MODEL
// ============================================================

class _Observation {
  final String commonName;
  final String scientificName;
  final String category;
  final String qualityGrade;
  final String location;
  final String photoUrl;
  final List<String> tags;
  final DateTime? observedAt;

  const _Observation({
    required this.commonName,
    required this.scientificName,
    required this.category,
    required this.qualityGrade,
    required this.location,
    required this.photoUrl,
    required this.tags,
    required this.observedAt,
  });

  factory _Observation.fromJson(Map<String, dynamic> json) {
    final taxon = json['taxon'] as Map<String, dynamic>? ?? {};

    // PHOTO
    final defaultPhoto =
        json['photos'] is List && (json['photos'] as List).isNotEmpty
        ? (json['photos'] as List).first as Map<String, dynamic>
        : null;

    String photoUrl = defaultPhoto?['url']?.toString() ?? '';

    if (photoUrl.contains('/square.')) {
      photoUrl = photoUrl.replaceFirst('/square.', '/medium.');
    }

    // LOCATION
    final String placeGuess = json['place_guess']?.toString().trim() ?? '';

    final String fallbackLocation = placeGuess.isEmpty
        ? 'Unknown location'
        : placeGuess;

    // SPECIES
    final String scientificName =
        taxon['name']?.toString() ?? 'Unknown species';

    final String commonName =
        taxon['preferred_common_name']?.toString() ?? scientificName;

    final String iconicTaxon = taxon['iconic_taxon_name']?.toString() ?? '';

    final bool isFlora = iconicTaxon == 'Plantae' || iconicTaxon == 'Fungi';

    // QUALITY GRADE
    final String qualityGrade =
        json['quality_grade']?.toString().trim() ?? 'Unknown';

    // TAGS
    final List<String> tags = (json['tags'] is List)
        ? (json['tags'] as List)
              .map((tag) => tag.toString().trim())
              .where((tag) => tag.isNotEmpty)
              .toList()
        : <String>[];

    // DATE
    DateTime? observedAt;

    final String? createdAt = json['created_at']?.toString();

    if (createdAt != null && createdAt.isNotEmpty) {
      observedAt = DateTime.tryParse(createdAt)?.toLocal();
    }

    if (observedAt == null) {
      final String? observedOn = json['observed_on']?.toString();

      if (observedOn != null && observedOn.isNotEmpty) {
        observedAt = DateTime.tryParse(observedOn)?.toLocal();
      }
    }

    return _Observation(
      commonName: commonName,
      scientificName: scientificName,
      category: isFlora ? 'Flora' : 'Fauna',
      qualityGrade: qualityGrade,
      location: fallbackLocation,
      photoUrl: photoUrl,
      tags: tags,
      observedAt: observedAt,
    );
  }

  // ============================================================
  // TIME AGO
  // ============================================================

  String get timeAgo {
    if (observedAt == null) {
      return 'Time unavailable';
    }

    final difference = DateTime.now().difference(observedAt!);

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;

      return '$minutes min ago';
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;

      return '$hours '
          '${hours == 1 ? 'hour' : 'hours'} ago';
    }

    final days = difference.inDays;

    if (days < 7) {
      return '$days '
          '${days == 1 ? 'day' : 'days'} ago';
    }

    return '${observedAt!.day}/'
        '${observedAt!.month}/'
        '${observedAt!.year}';
  }

  bool get isFlora => category == 'Flora';
}
