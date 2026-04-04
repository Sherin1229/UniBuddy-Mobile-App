class SessionRequest {
  final int id;
  final int groupId;
  final int requestedByUserId;
  final String requestedByUserName;
  final String requestedByUserAvatar;
  final String title;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String status; // pending, approved, declined
  final DateTime requestedAt;

  SessionRequest({
    required this.id,
    required this.groupId,
    required this.requestedByUserId,
    required this.requestedByUserName,
    required this.requestedByUserAvatar,
    required this.title,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    required this.requestedAt,
  });

  factory SessionRequest.fromJson(Map<String, dynamic> json) {
    return SessionRequest(
      id: json['id'] as int,
      groupId: json['group_id'] as int,
      requestedByUserId: json['requested_by_user_id'] as int,
      requestedByUserName: json['requested_by_user_name'] as String,
      requestedByUserAvatar: json['requested_by_user_avatar'] as String,
      title: json['title'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      durationMinutes: json['duration_minutes'] as int,
      status: json['status'] as String,
      requestedAt: DateTime.parse(json['requested_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'requested_by_user_id': requestedByUserId,
      'requested_by_user_name': requestedByUserName,
      'requested_by_user_avatar': requestedByUserAvatar,
      'title': title,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'status': status,
      'requested_at': requestedAt.toIso8601String(),
    };
  }

  SessionRequest copyWith({
    int? id,
    int? groupId,
    int? requestedByUserId,
    String? requestedByUserName,
    String? requestedByUserAvatar,
    String? title,
    DateTime? scheduledAt,
    int? durationMinutes,
    String? status,
    DateTime? requestedAt,
  }) {
    return SessionRequest(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      requestedByUserId: requestedByUserId ?? this.requestedByUserId,
      requestedByUserName: requestedByUserName ?? this.requestedByUserName,
      requestedByUserAvatar:
          requestedByUserAvatar ?? this.requestedByUserAvatar,
      title: title ?? this.title,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
    );
  }
}
