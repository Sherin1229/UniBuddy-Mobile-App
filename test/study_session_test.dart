import 'package:flutter_test/flutter_test.dart';
import 'package:unibuddy/features/study_groups/data/models/session_request.dart';
import 'package:unibuddy/features/study_groups/data/models/study_session.dart';
import 'package:unibuddy/features/study_groups/data/repositories/study_group_repository_impl.dart';
import 'package:unibuddy/features/study_groups/presentation/state/study_group_provider.dart';

void main() {
  group('Study Session Component Tests', () {
    late StudyGroupRepositoryImpl repository;
    late StudyGroupProvider provider;

    setUp(() {
      repository = StudyGroupRepositoryImpl();
      provider = StudyGroupProvider();
    });

    test('1) StudySession toJson/fromJson round-trip keeps values', () {
      final scheduledAt = DateTime(2026, 4, 24, 10, 30);
      final session = StudySession(
        id: 1,
        groupId: 101,
        title: 'Calculus Revision',
        scheduledAt: scheduledAt,
        durationMinutes: 90,
        participantCount: 5,
      );

      final json = session.toJson();
      final decoded = StudySession.fromJson(json);

      expect(decoded.id, 1);
      expect(decoded.groupId, 101);
      expect(decoded.title, 'Calculus Revision');
      expect(decoded.scheduledAt, scheduledAt);
      expect(decoded.durationMinutes, 90);
      expect(decoded.participantCount, 5);
    });

    test('2) SessionRequest copyWith updates only provided fields', () {
      final req = SessionRequest(
        id: 11,
        groupId: 101,
        requestedByUserId: 1,
        requestedByUserName: 'You',
        requestedByUserAvatar: 'avatar-url',
        title: 'Linear Algebra Practice',
        scheduledAt: DateTime(2026, 4, 25, 14, 0),
        durationMinutes: 60,
        status: 'pending',
        requestedAt: DateTime(2026, 4, 24, 9, 0),
      );

      final updated = req.copyWith(status: 'approved');

      expect(updated.id, req.id);
      expect(updated.title, req.title);
      expect(updated.status, 'approved');
      expect(req.status, 'pending'); // original remains unchanged
    });

    test('3) getAllGroups returns seeded groups', () async {
      final groups = await repository.getAllGroups();

      expect(groups, isNotEmpty);
      expect(groups.length, greaterThanOrEqualTo(6));
    });

    test('4) getGroupById returns null for unknown group', () async {
      final group = await repository.getGroupById(999999);

      expect(group, isNull);
    });

    test('5) addSession increases session count for group', () async {
      const groupId = 101;
      final before = await repository.getGroupSessions(groupId);

      await repository.addSession(
        groupId,
        title: 'New Added Session',
        scheduledAt: DateTime.now().add(const Duration(days: 12)),
        durationMinutes: 75,
      );

      final after = await repository.getGroupSessions(groupId);

      expect(after.length, before.length + 1);
      expect(after.any((s) => s.title == 'New Added Session'), isTrue);
    });

    test('6) updateSession changes title/time/duration', () async {
      const groupId = 101;
      final sessions = await repository.getGroupSessions(groupId);
      final target = sessions.first;

      final newTime = target.scheduledAt.add(const Duration(days: 1));

      final updated = await repository.updateSession(
        groupId,
        target.id,
        title: 'Updated Session Title',
        scheduledAt: newTime,
        durationMinutes: 120,
      );

      expect(updated.id, target.id);
      expect(updated.title, 'Updated Session Title');
      expect(updated.scheduledAt, newTime);
      expect(updated.durationMinutes, 120);
    });

    test('7) requestSession creates pending request', () async {
      const groupId = 101;

      final request = await repository.requestSession(
        groupId,
        title: 'Requested Session',
        scheduledAt: DateTime.now().add(const Duration(days: 2)),
        durationMinutes: 90,
      );

      expect(request.groupId, groupId);
      expect(request.title, 'Requested Session');
      expect(request.status, 'pending');

      final requests = await repository.getGroupSessionRequests(groupId);
      expect(requests.any((r) => r.id == request.id), isTrue);
    });

    test('8) approveSessionRequest marks request approved and adds session',
        () async {
      const groupId = 101;

      final beforeSessions = await repository.getGroupSessions(groupId);

      final request = await repository.requestSession(
        groupId,
        title: 'Approval Flow Session',
        scheduledAt: DateTime.now().add(const Duration(days: 3)),
        durationMinutes: 80,
      );

      await repository.approveSessionRequest(request.id);

      final requests = await repository.getGroupSessionRequests(groupId);
      final approved = requests.firstWhere((r) => r.id == request.id);
      final afterSessions = await repository.getGroupSessions(groupId);

      expect(approved.status, 'approved');
      expect(
        afterSessions.any((s) => s.title == 'Approval Flow Session'),
        isTrue,
      );
      expect(afterSessions.length, beforeSessions.length + 1);
    });

    test('9) declineSessionRequest marks request declined without adding session',
        () async {
      const groupId = 101;

      final beforeSessions = await repository.getGroupSessions(groupId);

      final request = await repository.requestSession(
        groupId,
        title: 'Decline Flow Session',
        scheduledAt: DateTime.now().add(const Duration(days: 4)),
        durationMinutes: 70,
      );

      await repository.declineSessionRequest(request.id);

      final requests = await repository.getGroupSessionRequests(groupId);
      final declined = requests.firstWhere((r) => r.id == request.id);
      final afterSessions = await repository.getGroupSessions(groupId);

      expect(declined.status, 'declined');
      expect(
        afterSessions.any((s) => s.title == 'Decline Flow Session'),
        isFalse,
      );
      expect(afterSessions.length, beforeSessions.length);
    });

    test('10) provider fetchGroupById loads selected group and sessions',
        () async {
      await provider.fetchGroupById(101);

      expect(provider.error, isNull);
      expect(provider.selectedGroup, isNotNull);
      expect(provider.selectedGroup!.id, 101);
      expect(provider.groupMembers, isNotEmpty);
      expect(provider.upcomingSessions, isNotEmpty);
      expect(provider.isLoading, isFalse);
    });
  });
}