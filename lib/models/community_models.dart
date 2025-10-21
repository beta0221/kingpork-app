/// Post author model
class PostAuthor {
  final int id;
  final String name;
  final String? avatar;

  PostAuthor({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['id'] as int,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
    };
  }
}

/// Community post model
class CommunityPost {
  final int id;
  final String content;
  final List<String> images;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final String createdAt;
  final PostAuthor author;

  CommunityPost({
    required this.id,
    required this.content,
    required this.images,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.createdAt,
    required this.author,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as int,
      content: json['content'] as String,
      images: List<String>.from(json['images'] ?? []),
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      author: PostAuthor.fromJson(json['author'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'images': images,
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_liked': isLiked,
      'created_at': createdAt,
      'author': author.toJson(),
    };
  }

  /// Create a copy with optional new values
  CommunityPost copyWith({
    int? id,
    String? content,
    List<String>? images,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    String? createdAt,
    PostAuthor? author,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      content: content ?? this.content,
      images: images ?? this.images,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
    );
  }
}

/// Post comment model
class PostComment {
  final int id;
  final int postId;
  final String content;
  final String createdAt;
  final PostAuthor author;

  PostComment({
    required this.id,
    required this.postId,
    required this.content,
    required this.createdAt,
    required this.author,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      content: json['content'] as String,
      createdAt: json['created_at'] as String,
      author: PostAuthor.fromJson(json['author'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'content': content,
      'created_at': createdAt,
      'author': author.toJson(),
    };
  }
}

/// Create post request model
class CreatePostRequest {
  final String content;
  final List<String>? images;

  CreatePostRequest({
    required this.content,
    this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      if (images != null) 'images': images,
    };
  }
}

/// Community posts response model
class CommunityPostsResponse {
  final List<CommunityPost> posts;
  final int total;
  final int currentPage;
  final int lastPage;

  CommunityPostsResponse({
    required this.posts,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory CommunityPostsResponse.fromJson(Map<String, dynamic> json) {
    return CommunityPostsResponse(
      posts: (json['data'] as List)
          .map((item) => CommunityPost.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
    );
  }

  bool get hasMorePages => currentPage < lastPage;
}
