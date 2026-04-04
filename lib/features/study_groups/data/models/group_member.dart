class GroupMember {
  final int id;
  final int groupId;
  final int userId;
  final String userName;
  final String? avatarUrl;
  final DateTime joinedAt;

  GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] as int,
      groupId: json['group_id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String? ?? 'Unknown',
      avatarUrl: json['avatar_url'] as String?,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'user_name': userName,
      'avatar_url': avatarUrl,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
