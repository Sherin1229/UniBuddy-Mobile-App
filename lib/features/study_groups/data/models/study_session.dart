class StudySession {
  final int id;
  final int groupId;
  final String title;
  final DateTime scheduledAt;
  final int durationMinutes;
  final int participantCount;

  StudySession({
    required this.id,
    required this.groupId,
    required this.title,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.participantCount,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] as int,
      groupId: json['group_id'] as int,
      title: json['title'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      durationMinutes: json['duration_minutes'] as int,
      participantCount: json['participant_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'title': title,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'participant_count': participantCount,
    };
  }
}

