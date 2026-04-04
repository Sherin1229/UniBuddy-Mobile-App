import 'package:flutter/foundation.dart';

/// Temporary session data used during group creation before IDs are assigned.
@immutable
class StudySessionDraft {
  final String title;
  final DateTime scheduledAt;
  final int durationMinutes;

  const StudySessionDraft({
    required this.title,
    required this.scheduledAt,
    required this.durationMinutes,
  });
}

