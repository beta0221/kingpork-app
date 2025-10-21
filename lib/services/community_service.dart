import 'package:tklab_ec_v2/models/community_models.dart';
import 'package:tklab_ec_v2/services/api/api_client.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';

/// Community service for managing posts and interactions
class CommunityService {
  final ApiClient _apiClient;

  CommunityService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get community posts with pagination
  ///
  /// Example:
  /// ```dart
  /// final response = await communityService.getPosts(page: 1, perPage: 20);
  /// ```
  Future<CommunityPostsResponse> getPosts({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.communityPosts}?page=$page&per_page=$perPage',
      requiresAuth: true,
    );

    return CommunityPostsResponse.fromJson(response);
  }

  /// Get a single post detail
  Future<CommunityPost> getPostDetail(int postId) async {
    final response = await _apiClient.get(
      ApiEndpoints.communityPostDetail(postId),
      requiresAuth: true,
    );

    return CommunityPost.fromJson(response);
  }

  /// Create a new post
  ///
  /// Example:
  /// ```dart
  /// final post = await communityService.createPost(
  ///   content: '這是我的新貼文',
  ///   images: ['image1.jpg', 'image2.jpg'],
  /// );
  /// ```
  Future<CommunityPost> createPost({
    required String content,
    List<String>? images,
  }) async {
    final request = CreatePostRequest(
      content: content,
      images: images,
    );

    final response = await _apiClient.post(
      ApiEndpoints.communityPost,
      body: request.toJson(),
      requiresAuth: true,
    );

    return CommunityPost.fromJson(response);
  }

  /// Toggle like on a post
  ///
  /// Returns the updated post data
  Future<CommunityPost> toggleLike(int postId) async {
    final response = await _apiClient.post(
      ApiEndpoints.communityPostLike(postId),
      requiresAuth: true,
    );

    return CommunityPost.fromJson(response);
  }

  /// Delete a post
  ///
  /// Returns true if deletion was successful
  Future<bool> deletePost(int postId) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.communityPostDelete(postId),
        requiresAuth: true,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get comments for a post
  Future<List<PostComment>> getComments(int postId) async {
    final response = await _apiClient.get(
      ApiEndpoints.communityPostComments(postId),
      requiresAuth: true,
    );

    final commentsList = response['comments'] as List;
    return commentsList
        .map((comment) => PostComment.fromJson(comment as Map<String, dynamic>))
        .toList();
  }

  /// Add a comment to a post
  Future<PostComment> addComment({
    required int postId,
    required String content,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.communityPostComments(postId),
      body: {'content': content},
      requiresAuth: true,
    );

    return PostComment.fromJson(response);
  }

  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}
