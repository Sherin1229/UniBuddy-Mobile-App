import '../models/study_group.dart';
import '../models/group_member.dart';
import '../models/study_session.dart';
import '../models/study_session_draft.dart';
import '../models/session_request.dart';

abstract class StudyGroupRepository {
  Future<List<StudyGroup>> getAllGroups();
  Future<StudyGroup?> getGroupById(int id);
  Future<List<StudySession>> getGroupSessions(int groupId);
  Future<StudyGroup> createGroup({
    required String name,
    required String description,
    required String subject,
    required int maxMembers,
    required bool isPrivate,
    required List<StudySessionDraft> sessions,
  });
  Future<StudyGroup> updateGroup(
    int id, {
    required String name,
    required String subject,
    required String description,
    required int maxMembers,
  });
  Future<void> deleteGroup(int id);
  Future<void> joinGroup(int groupId);
  Future<void> leaveGroup(int groupId);
  Future<List<GroupMember>> getGroupMembers(int groupId);
  Future<StudySession> addSession(
    int groupId, {
    required String title,
    required DateTime scheduledAt,
    required int durationMinutes,
  });

  Future<StudySession> updateSession(
    int groupId,
    int sessionId, {
    required String title,
    required DateTime scheduledAt,
    required int durationMinutes,
  });

  Future<SessionRequest> requestSession(
    int groupId, {
    required String title,
    required DateTime scheduledAt,
    required int durationMinutes,
  });

  Future<List<SessionRequest>> getGroupSessionRequests(int groupId);

  Future<void> approveSessionRequest(int requestId);

  Future<void> declineSessionRequest(int requestId);
}
