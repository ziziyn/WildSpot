import '../models/community_post.dart';

/// Sumber feed komunitas. UI bergantung pada kontrak ini, bukan pada data tiruan.
abstract interface class CommunityRepository {
  List<CommunityPost> fetchFollowing();

  List<CommunityPost> fetchDiscovery();
}
