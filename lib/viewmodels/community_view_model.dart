import 'package:tklab_ec_v2/models/community_models.dart';
import 'package:tklab_ec_v2/services/community_service.dart';
import 'package:tklab_ec_v2/viewmodels/base_view_model.dart';

/// CommunityViewModel manages community posts and interactions
class CommunityViewModel extends BaseViewModel {
  final CommunityService _communityService;

  List<CommunityPost> _posts = [];
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;

  List<CommunityPost> get posts => _posts;
  bool get hasMorePages => _hasMorePages;
  bool get isLoadingMore => _isLoadingMore;
  int get postsCount => _posts.length;

  CommunityViewModel({CommunityService? communityService})
      : _communityService = communityService ?? CommunityService();

  /// Initialize community feed
  Future<void> initialize() async {
    _currentPage = 1;
    _hasMorePages = true;
    await loadPosts();
  }

  /// Load posts from API
  Future<void> loadPosts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePages = true;
      _posts.clear();
    }

    setLoading();
    try {
      final response = await _communityService.getPosts(page: _currentPage);
      _posts.addAll(response.posts);
      _hasMorePages = response.hasMorePages;
      _currentPage++;

      setSuccess();
    } catch (e) {
      setError('載入貼文失敗: ${e.toString()}');
    }
  }

  /// Load more posts (pagination)
  Future<void> loadMorePosts() async {
    if (_isLoadingMore || !_hasMorePages) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _communityService.getPosts(page: _currentPage);
      _posts.addAll(response.posts);
      _hasMorePages = response.hasMorePages;
      _currentPage++;
    } catch (e) {
      // Silent fail for pagination
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Create a new post
  Future<bool> createPost({
    required String content,
    List<String>? images,
  }) async {
    try {
      final newPost = await _communityService.createPost(
        content: content,
        images: images,
      );
      _posts.insert(0, newPost);
      notifyListeners();
      return true;
    } catch (e) {
      setError('發佈貼文失敗: ${e.toString()}');
      return false;
    }
  }

  /// Toggle like on a post
  Future<void> toggleLike(int postId) async {
    try {
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index == -1) return;

      final post = _posts[index];
      final newLikeCount = post.isLiked ? post.likeCount - 1 : post.likeCount + 1;
      final newIsLiked = !post.isLiked;

      // Update locally for immediate feedback
      _posts[index] = post.copyWith(
        likeCount: newLikeCount,
        isLiked: newIsLiked,
      );
      notifyListeners();

      // Call API to toggle like
      final updatedPost = await _communityService.toggleLike(postId);
      _posts[index] = updatedPost;
      notifyListeners();
    } catch (e) {
      // Revert on error
      await loadPosts(refresh: true);
      setError('操作失敗: ${e.toString()}');
    }
  }

  /// Delete a post
  Future<bool> deletePost(int postId) async {
    try {
      final success = await _communityService.deletePost(postId);
      if (success) {
        _posts.removeWhere((post) => post.id == postId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      setError('刪除貼文失敗: ${e.toString()}');
      return false;
    }
  }

  /// Refresh posts
  Future<void> refresh() async {
    await loadPosts(refresh: true);
  }

  @override
  void dispose() {
    _communityService.dispose();
    super.dispose();
  }
}
