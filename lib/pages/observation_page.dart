import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ============================================================
// DESIGN SYSTEM
// ============================================================

const _bg = Color(0xFF1A211E);
const _card = Color(0xFF212A26);
const _green = Color(0xFF4CD964);
const _orange = Color(0xFFE07B12);
const _muted = Color(0xFFA9B3AE);

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
  List<int> _trendData = List.filled(7, 0);

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

  // ==========================================================
  // FETCH DATA FROM iNATURALIST API
  // ==========================================================

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
        _trendData = _buildTrendData(observations);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load observations.';
      });
    }
  }

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
  // ==========================================================
  // CREATE 7-DAY TREND FROM API DATA
  // ==========================================================

  List<int> _buildTrendData(List<_Observation> observations) {
    final now = DateTime.now();

    final List<int> data = List.filled(7, 0);

    for (final observation in observations) {
      if (observation.observedAt == null) continue;

      final date = DateTime(
        observation.observedAt!.year,
        observation.observedAt!.month,
        observation.observedAt!.day,
      );

      final today = DateTime(now.year, now.month, now.day);

      final difference = today.difference(date).inDays;

      if (difference >= 0 && difference < 7) {
        final index = 6 - difference;
        data[index]++;
      }
    }

    return data;
  }

  // ==========================================================
  // SEARCH
  // ==========================================================

  List<_Observation> get _filteredObservations {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return _observations;
    }

    return _observations.where((observation) {
      return observation.commonName.toLowerCase().contains(query) ||
          observation.scientificName.toLowerCase().contains(query) ||
          observation.category.toLowerCase().contains(query);
    }).toList();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              color: _green,
              backgroundColor: _card,
              onRefresh: _fetchObservations,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildLocalTrends(),
                        const SizedBox(height: 22),
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

            // ==================================================
            // FLOATING ACTION BUTTON
            // ==================================================
            Positioned(
              right: 18,
              bottom: 24,
              child: FloatingActionButton(
                backgroundColor: _green,
                foregroundColor: _bg,
                elevation: 5,
                onPressed: () {
                  // Aksi membuat observasi baru
                  // dapat dihubungkan ke screen/form milik project utama.
                },
                child: const Icon(Icons.camera_alt_rounded, size: 23),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // LOCAL TRENDS
  // ==========================================================

  Widget _buildLocalTrends() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.trending_up_rounded, color: _green, size: 19),
            const SizedBox(width: 7),
            const Text(
              'Local Trends',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              'Last 7 Days',
              style: TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'Daily discovery volume in your area',
          style: TextStyle(color: _muted, fontSize: 11),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 130,
          width: double.infinity,
          child: CustomPaint(
            painter: _TrendChartPainter(
              values: _trendData,
              lineColor: _green,
              gridColor: _muted.withValues(alpha: 0.14),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SEARCH BAR
  // ==========================================================

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(13),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) {
          setState(() {});
        },
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search_rounded, color: _muted, size: 20),
          hintText: 'Search species or tags...',
          hintStyle: TextStyle(color: _muted.withOpacity(0.75), fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  // ==========================================================
  // FILTER TABS
  // ==========================================================

  Widget _buildFilters() {
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
            color: _card,
            borderRadius: BorderRadius.circular(11),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded, color: _muted, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String title) {
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
          color: active ? _green : _card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active ? _bg : _muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // COMMUNITY FEED HEADER
  // ==========================================================

  Widget _buildCommunityHeader() {
    return Row(
      children: [
        const Icon(Icons.bar_chart_rounded, color: _green, size: 19),
        const SizedBox(width: 7),
        const Text(
          'Community Feed',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // OBSERVATION CONTENT
  // ==========================================================

  Widget _buildObservationContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(color: _green, strokeWidth: 2.5),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    final observations = _filteredObservations;

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

  Widget _buildViewOtherObservationsButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: _isLoadingMore ? null : _loadMoreObservations,
        icon: _isLoadingMore
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: _green),
              )
            : const Icon(Icons.visibility_outlined, size: 17),
        label: Text(
          _isLoadingMore
              ? 'Loading Observations...'
              : 'View Other Observations',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _green,
          side: BorderSide(color: _green.withValues(alpha: 0.65), width: 1),
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
  // ==========================================================
  // OBSERVATION CARD
  // ==========================================================

  Widget _buildObservationCard(_Observation observation) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PHOTO
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.35,
                child: Image.network(
                  observation.photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: _bg,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: _muted,
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
                      color: _bg,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: _green,
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
                    color: _bg.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        observation.isFlora
                            ? Icons.eco_rounded
                            : Icons.pets_rounded,
                        color: _green,
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

          // CARD CONTENT
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            observation.commonName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
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
                              color: _muted,
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.link_rounded, color: _green, size: 17),
                  ],
                ),
                const SizedBox(height: 11),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: _green,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        observation.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _muted, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: _muted,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      observation.timeAgo,
                      style: TextStyle(color: _muted, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // STATUS CHIP
  // ==========================================================

  Widget _buildStatusChip(String status) {
    final normalizedStatus = status.toLowerCase();

    final bool needsId =
        normalizedStatus == 'needs_id' || normalizedStatus == 'needs id';

    final Color statusColor = needsId ? _orange : _green;

    final String displayStatus = status
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
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

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: _muted, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Unable to load observations',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: _fetchObservations,
              child: const Text(
                'Try Again',
                style: TextStyle(color: _green, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, color: _muted, size: 35),
          const SizedBox(height: 10),
          const Text(
            'No observations found',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            'Try another species or tag.',
            style: TextStyle(color: _muted, fontSize: 11),
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
  final DateTime? observedAt;

  const _Observation({
    required this.commonName,
    required this.scientificName,
    required this.category,
    required this.qualityGrade,
    required this.location,
    required this.photoUrl,
    required this.observedAt,
  });

  factory _Observation.fromJson(Map<String, dynamic> json) {
    final taxon = json['taxon'] as Map<String, dynamic>? ?? {};

    final defaultPhoto =
        json['photos'] is List && (json['photos'] as List).isNotEmpty
        ? (json['photos'] as List).first as Map<String, dynamic>
        : null;

    String photoUrl = defaultPhoto?['url']?.toString() ?? '';

    // iNaturalist photo URL biasanya memiliki /square,
    // /medium, /large, dll.
    // Medium dipakai agar kualitas foto tetap baik.
    if (photoUrl.contains('/square.')) {
      photoUrl = photoUrl.replaceFirst('/square.', '/medium.');
    }

    final String placeGuess = json['place_guess']?.toString().trim() ?? '';

    final String fallbackLocation = placeGuess.isEmpty
        ? 'Unknown location'
        : placeGuess;

    final String scientificName =
        taxon['name']?.toString() ?? 'Unknown species';

    final String commonName =
        taxon['preferred_common_name']?.toString() ?? scientificName;

    final String iconicTaxon = taxon['iconic_taxon_name']?.toString() ?? '';

    final bool isFlora = iconicTaxon == 'Plantae' || iconicTaxon == 'Fungi';

    final String qualityGrade =
        json['quality_grade']?.toString().trim() ?? 'Unknown';

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
      observedAt: observedAt,
    );
  }

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
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }

    final days = difference.inDays;

    if (days < 7) {
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }

    return '${observedAt!.day}/${observedAt!.month}/${observedAt!.year}';
  }

  bool get isFlora => category == 'Flora';
}

// ============================================================
// TREND CHART
// ============================================================

class _TrendChartPainter extends CustomPainter {
  final List<int> values;
  final Color lineColor;
  final Color gridColor;

  _TrendChartPainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paintGrid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paintFill = Paint()
      ..color = lineColor.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Grid
    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    final maxValue = values.reduce((a, b) => a > b ? a : b);

    final double maxY = maxValue == 0 ? 1 : maxValue.toDouble();

    final path = Path();

    final double horizontalSpacing = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = horizontalSpacing * i;

      final normalized = values[i] / maxY;

      final y = size.height - (normalized * size.height * 0.78) - 5;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final previousX = horizontalSpacing * (i - 1);

        final previousNormalized = values[i - 1] / maxY;

        final previousY =
            size.height - (previousNormalized * size.height * 0.78) - 5;

        final controlPoint1 = Offset(
          previousX + (x - previousX) * 0.5,
          previousY,
        );

        final controlPoint2 = Offset(previousX + (x - previousX) * 0.5, y);

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          x,
          y,
        );
      }
    }

    // Area underneath line
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    // Points
    final paintPoint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final x = horizontalSpacing * i;

      final normalized = values[i] / maxY;

      final y = size.height - (normalized * size.height * 0.78) - 5;

      canvas.drawCircle(Offset(x, y), 2.5, paintPoint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}
