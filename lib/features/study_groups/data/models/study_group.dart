class StudyGroup {
  final int id;
  final int createdBy;
  final String name;
  final String subject;
  final String description;
  final int maxMembers;
  final int currentMembers;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final String coverImageUrl;
  final String creatorName;
  final String creatorAvatarUrl;
  final int upcomingSessionsCount;
  final DateTime? nextSessionAt;
  final bool isPrivate;

  /// Whether the currently signed-in user has joined this group.
  ///
  /// In this demo app there is no auth yet; this is derived from mock userId=1.
  final bool isJoined;

  /// Whether the currently signed-in user is the creator of this group.
  ///
  /// In this demo app there is no auth yet; this is derived from mock userId=1.
  final bool isCreator;

  StudyGroup({
    required this.id,
    required this.createdBy,
    required this.name,
    required this.subject,
    required this.description,
    required this.maxMembers,
    required this.currentMembers,
    required this.createdAt,
    this.deletedAt,
    required this.coverImageUrl,
    required this.creatorName,
    required this.creatorAvatarUrl,
    required this.upcomingSessionsCount,
    this.nextSessionAt,
    required this.isPrivate,
    required this.isJoined,
    required this.isCreator,
  });

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      id: json['id'] as int,
      createdBy: json['created_by'] as int,
      name: json['name'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String? ?? '',
      maxMembers: json['max_members'] as int,
      currentMembers: json['current_members'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      coverImageUrl: json['cover_image_url'] as String? ?? '',
      creatorName: json['creator_name'] as String? ?? '',
      creatorAvatarUrl: json['creator_avatar_url'] as String? ?? '',
      upcomingSessionsCount: json['upcoming_sessions_count'] as int? ?? 0,
      nextSessionAt: json['next_session_at'] != null
          ? DateTime.parse(json['next_session_at'] as String)
          : null,
      isPrivate: json['is_private'] as bool? ?? false,
      isJoined: json['is_joined'] as bool? ?? false,
      isCreator: json['is_creator'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_by': createdBy,
      'name': name,
      'subject': subject,
      'description': description,
      'max_members': maxMembers,
      'current_members': currentMembers,
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'cover_image_url': coverImageUrl,
      'creator_name': creatorName,
      'creator_avatar_url': creatorAvatarUrl,
      'upcoming_sessions_count': upcomingSessionsCount,
      'next_session_at': nextSessionAt?.toIso8601String(),
      'is_private': isPrivate,
      'is_joined': isJoined,
      'is_creator': isCreator,
    };
  }

  StudyGroup copyWith({
    int? id,
    int? createdBy,
    String? name,
    String? subject,
    String? description,
    int? maxMembers,
    int? currentMembers,
    DateTime? createdAt,
    DateTime? deletedAt,
    String? coverImageUrl,
    String? creatorName,
    String? creatorAvatarUrl,
    int? upcomingSessionsCount,
    DateTime? nextSessionAt,
    bool? isPrivate,
    bool? isJoined,
    bool? isCreator,
  }) {
    return StudyGroup(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      maxMembers: maxMembers ?? this.maxMembers,
      currentMembers: currentMembers ?? this.currentMembers,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatarUrl: creatorAvatarUrl ?? this.creatorAvatarUrl,
      upcomingSessionsCount: upcomingSessionsCount ?? this.upcomingSessionsCount,
      nextSessionAt: nextSessionAt ?? this.nextSessionAt,
      isPrivate: isPrivate ?? this.isPrivate,
      isJoined: isJoined ?? this.isJoined,
      isCreator: isCreator ?? this.isCreator,
    );
  }
}
