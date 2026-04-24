import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/study_group.dart';
import '../models/group_member.dart';
import '../models/study_session.dart';
import '../models/study_session_draft.dart';
import '../models/session_request.dart';
import 'study_group_repository.dart';

class StudyGroupRepositoryImpl implements StudyGroupRepository {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const String _groupsCollection = 'study_groups';

  // Demo user (until we add auth)
  static const int _currentUserId = 1;
  static const String _currentUserName = 'You';
  static const String _currentUserAvatarUrl =
      'https://randomuser.me/api/portraits/men/32.jpg';

  // In-memory demo data (seeded on first use)
  bool _seeded = false;
  List<StudyGroup> _mockGroups = [];
  final Map<int, List<GroupMember>> _membersByGroup =
      <int, List<GroupMember>>{};
  final Map<int, List<StudySession>> _sessionsByGroup =
      <int, List<StudySession>>{};
  final Map<int, List<SessionRequest>> _sessionRequestsByGroup =
      <int, List<SessionRequest>>{};

  int _groupIdCounter = 100;
  int _memberIdCounter = 1000;
  int _sessionIdCounter = 2000;
  int _requestIdCounter = 3000;
  bool _mockFirestoreSeeded = false;

  Future<void> _saveGroupToFirestore({
    required StudyGroup group,
    required List<StudySession> sessions,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final groupRef = FirebaseFirestore.instance
        .collection(_groupsCollection)
        .doc(group.id.toString());

    await groupRef.set({
      'id': group.id,
      'created_by': group.createdBy,
      'name': group.name,
      'subject': group.subject,
      'description': group.description,
      'max_members': group.maxMembers,
      'current_members': group.currentMembers,
      'created_at': Timestamp.fromDate(group.createdAt),
      'cover_image_url': group.coverImageUrl,
      'creator_name': group.creatorName,
      'creator_avatar_url': group.creatorAvatarUrl,
      'upcoming_sessions_count': group.upcomingSessionsCount,
      'next_session_at': group.nextSessionAt != null
          ? Timestamp.fromDate(group.nextSessionAt!)
          : null,
      'is_private': group.isPrivate,
      'is_joined': group.isJoined,
      'is_creator': group.isCreator,
      'firebase_uid': user?.uid,
      'updated_at': FieldValue.serverTimestamp(),
    });

    final WriteBatch batch = FirebaseFirestore.instance.batch();
    final sessionsCollection = groupRef.collection('sessions');
    for (final session in sessions) {
      final sessionRef = sessionsCollection.doc(session.id.toString());
      batch.set(sessionRef, {
        'id': session.id,
        'group_id': session.groupId,
        'title': session.title,
        'scheduled_at': Timestamp.fromDate(session.scheduledAt),
        'duration_minutes': session.durationMinutes,
        'participant_count': session.participantCount,
      });
    }
    await batch.commit();
  }

  void _ensureSeeded() {
    if (_seeded) return;
    _seeded = true;

    final now = DateTime.now();

    // Group 1 (Creator is "You")
    _membersByGroup[101] = <GroupMember>[
      GroupMember(
        id: _memberIdCounter++,
        groupId: 101,
        userId: 1,
        userName: 'You',
        avatarUrl: _currentUserAvatarUrl,
        joinedAt: now.subtract(const Duration(days: 50)),
      ),
      GroupMember(
        id: _memberIdCounter++,
        groupId: 101,
        userId: 2,
        userName: 'Alex Johnson',
        avatarUrl: 'https://randomuser.me/api/portraits/men/11.jpg',
        joinedAt: now.subtract(const Duration(days: 20)),
      ),
      GroupMember(
        id: _memberIdCounter++,
        groupId: 101,
        userId: 3,
        userName: 'Priya Sharma',
        avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
        joinedAt: now.subtract(const Duration(days: 18)),
      ),
      GroupMember(
        id: _memberIdCounter++,
        groupId: 101,
        userId: 4,
        userName: 'Carlos Rivera',
        avatarUrl: 'https://randomuser.me/api/portraits/men/54.jpg',
        joinedAt: now.subtract(const Duration(days: 15)),
      ),
      GroupMember(
        id: _memberIdCounter++,
        groupId: 101,
        userId: 5,
        userName: 'Mei Lin',
        avatarUrl: 'https://randomuser.me/api/portraits/women/63.jpg',
        joinedAt: now.subtract(const Duration(days: 10)),
      ),
    ];
    _sessionsByGroup[101] = <StudySession>[
      StudySession(
        id: _sessionIdCounter++,
        groupId: 101,
        title: 'Multivariable Limits Deep Dive',
        scheduledAt: DateTime(now.year, now.month, now.day + 1, 18, 0),
        durationMinutes: 90,
        participantCount: 5,
      ),
      StudySession(
        id: _sessionIdCounter++,
        groupId: 101,
        title: 'ODE Techniques Practice',
        scheduledAt: DateTime(now.year, now.month, now.day + 3, 16, 0),
        durationMinutes: 120,
        participantCount: 4,
      ),
      StudySession(
        id: _sessionIdCounter++,
        groupId: 101,
        title: 'Real Analysis Review',
        scheduledAt: DateTime(now.year, now.month, now.day + 6, 17, 0),
        durationMinutes: 90,
        participantCount: 5,
      ),
    ];

    // Group 2 (Not joined)
    _membersByGroup[102] = <GroupMember>[
      GroupMember(
        id: _memberIdCounter++,
        groupId: 102,
        userId: 6,
        userName: 'Sofia Martinez',
        avatarUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
        joinedAt: now.subtract(const Duration(days: 22)),
      ),
      GroupMember(
        id: _memberIdCounter++,
        groupId: 102,
        userId: 7,
        userName: 'Liam Chen',
        avatarUrl: 'https://randomuser.me/api/portraits/men/74.jpg',
        joinedAt: now.subtract(const Duration(days: 18)),
      ),
    ];
    _sessionsByGroup[102] = <StudySession>[
      StudySession(
        id: _sessionIdCounter++,
        groupId: 102,
        title: 'Gradient Descent Workshop',
        scheduledAt: DateTime(now.year, now.month, now.day + 2, 19, 0),
        durationMinutes: 75,
        participantCount: 3,
      ),
    ];

    // Group 3 (Joined)
    _membersByGroup[103] = <GroupMember>[
      GroupMember(
        id: _memberIdCounter++,
        groupId: 103,
        userId: 1,
        userName: 'You',
        avatarUrl: _currentUserAvatarUrl,
        joinedAt: now.subtract(const Duration(days: 8)),
      ),
      GroupMember(
        id: _memberIdCounter++,
        groupId: 103,
        userId: 8,
        userName: 'Noah Baker',
        avatarUrl: 'https://randomuser.me/api/portraits/men/41.jpg',
        joinedAt: now.subtract(const Duration(days: 7)),
      ),
      GroupMember(
        id: _memberIdCounter++,
        groupId: 103,
        userId: 9,
        userName: 'Ava Williams',
        avatarUrl: 'https://randomuser.me/api/portraits/women/50.jpg',
        joinedAt: now.subtract(const Duration(days: 6)),
      ),
    ];
    _sessionsByGroup[103] = <StudySession>[
      StudySession(
        id: _sessionIdCounter++,
        groupId: 103,
        title: 'Algorithms Speedrun',
        scheduledAt: DateTime(now.year, now.month, now.day + 4, 15, 30),
        durationMinutes: 110,
        participantCount: 4,
      ),
      StudySession(
        id: _sessionIdCounter++,
        groupId: 103,
        title: 'Dynamic Programming Patterns',
        scheduledAt: DateTime(now.year, now.month, now.day + 7, 18, 0),
        durationMinutes: 100,
        participantCount: 3,
      ),
    ];

    // Group 4 (Creator is other)
    _membersByGroup[104] = <GroupMember>[
      GroupMember(
        id: _memberIdCounter++,
        groupId: 104,
        userId: 10,
        userName: 'Emma Davis',
        avatarUrl: 'https://randomuser.me/api/portraits/women/35.jpg',
        joinedAt: now.subtract(const Duration(days: 30)),
      ),
      GroupMember(
        id: _memberIdCounter++,
        groupId: 104,
        userId: 1,
        userName: 'You',
        avatarUrl: _currentUserAvatarUrl,
        joinedAt: now.subtract(const Duration(days: 12)),
      ),
    ];
    _sessionsByGroup[104] = <StudySession>[
      StudySession(
        id: _sessionIdCounter++,
        groupId: 104,
        title: 'Statistics Practice Set',
        scheduledAt: DateTime(now.year, now.month, now.day + 5, 17, 0),
        durationMinutes: 90,
        participantCount: 4,
      ),
    ];

    // Group 5 (Not joined)
    _membersByGroup[105] = <GroupMember>[
      GroupMember(
        id: _memberIdCounter++,
        groupId: 105,
        userId: 11,
        userName: 'Daniel Wilson',
        avatarUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
        joinedAt: now.subtract(const Duration(days: 25)),
      ),
    ];
    _sessionsByGroup[105] = <StudySession>[
      StudySession(
        id: _sessionIdCounter++,
        groupId: 105,
        title: 'Physics Problem Clinic',
        scheduledAt: DateTime(now.year, now.month, now.day + 8, 20, 0),
        durationMinutes: 120,
        participantCount: 2,
      ),
    ];

    // Group 6 (Joined, near-full)
    _membersByGroup[106] = <GroupMember>[
      GroupMember(
        id: _memberIdCounter++,
        groupId: 106,
        userId: 1,
        userName: 'You',
        avatarUrl: _currentUserAvatarUrl,
        joinedAt: now.subtract(const Duration(days: 3)),
      ),
      GroupMember(
        id: _memberIdCounter++,
        groupId: 106,
        userId: 12,
        userName: 'Harper Thompson',
        avatarUrl: 'https://randomuser.me/api/portraits/women/28.jpg',
        joinedAt: now.subtract(const Duration(days: 3)),
      ),
      GroupMember(
        id: _memberIdCounter++,
        groupId: 106,
        userId: 13,
        userName: 'Ethan Roberts',
        avatarUrl: 'https://randomuser.me/api/portraits/men/59.jpg',
        joinedAt: now.subtract(const Duration(days: 2)),
      ),
      GroupMember(
        id: _memberIdCounter++,
        groupId: 106,
        userId: 14,
        userName: 'Grace Lee',
        avatarUrl: 'https://randomuser.me/api/portraits/women/19.jpg',
        joinedAt: now.subtract(const Duration(days: 2)),
      ),
      GroupMember(
        id: _memberIdCounter++,
        groupId: 106,
        userId: 15,
        userName: 'Oliver King',
        avatarUrl: 'https://randomuser.me/api/portraits/men/67.jpg',
        joinedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
    _sessionsByGroup[106] = <StudySession>[
      StudySession(
        id: _sessionIdCounter++,
        groupId: 106,
        title: 'Calculus Derivative Drills',
        scheduledAt: DateTime(now.year, now.month, now.day + 1, 14, 0),
        durationMinutes: 90,
        participantCount: 5,
      ),
    ];

    _mockGroups = <StudyGroup>[
      StudyGroup(
        id: 101,
        createdBy: 1,
        name: 'Advanced Calculus Mastery',
        subject: 'Mathematics',
        description:
            'A dedicated group for students tackling advanced calculus topics including multivariable calculus, differential equations, and real analysis. We meet three times a week to solve problems together and review lecture notes.',
        maxMembers: 12,
        currentMembers: _membersByGroup[101]!.length,
        createdAt: now.subtract(const Duration(days: 60)),
        coverImageUrl:
            'https://images.pexels.com/photos/301920/pexels-photo-301920.jpeg?auto=compress&cs=tinysrgb&w=1200',
        creatorName: 'You',
        creatorAvatarUrl: _currentUserAvatarUrl,
        upcomingSessionsCount: _sessionsByGroup[101]!.length,
        nextSessionAt: _sessionsByGroup[101]!
            .map((s) => s.scheduledAt)
            .reduce((a, b) => a.isBefore(b) ? a : b),
        isPrivate: false,
        isJoined: true,
        isCreator: true,
      ),
      StudyGroup(
        id: 102,
        createdBy: 6,
        name: 'Machine Learning Study Circle',
        subject: 'Computer Science',
        description:
            'Learn ML fundamentals through weekly sessions: model building, hands-on exercises, and guided reading.',
        maxMembers: 10,
        currentMembers: _membersByGroup[102]!.length,
        createdAt: now.subtract(const Duration(days: 35)),
        coverImageUrl:
            'https://images.pexels.com/photos/546819/pexels-photo-546819.jpeg?auto=compress&cs=tinysrgb&w=1200',
        creatorName: 'Sofia Martinez',
        creatorAvatarUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
        upcomingSessionsCount: _sessionsByGroup[102]!.length,
        nextSessionAt: _sessionsByGroup[102]!
            .map((s) => s.scheduledAt)
            .reduce((a, b) => a.isBefore(b) ? a : b),
        isPrivate: true,
        isJoined: false,
        isCreator: false,
      ),
      StudyGroup(
        id: 103,
        createdBy: 8,
        name: 'Algorithms & Complexity Lab',
        subject: 'Algorithms',
        description:
            'Solve problems together, discuss complexity proofs, and share strategies for interviews and exams.',
        maxMembers: 12,
        currentMembers: _membersByGroup[103]!.length,
        createdAt: now.subtract(const Duration(days: 25)),
        coverImageUrl:
            'https://images.pexels.com/photos/574071/pexels-photo-574071.jpeg?auto=compress&cs=tinysrgb&w=1200',
        creatorName: 'Noah Baker',
        creatorAvatarUrl: 'https://randomuser.me/api/portraits/men/41.jpg',
        upcomingSessionsCount: _sessionsByGroup[103]!.length,
        nextSessionAt: _sessionsByGroup[103]!
            .map((s) => s.scheduledAt)
            .reduce((a, b) => a.isBefore(b) ? a : b),
        isPrivate: false,
        isJoined: true,
        isCreator: false,
      ),
      StudyGroup(
        id: 104,
        createdBy: 10,
        name: 'Statistics Masterclass',
        subject: 'Statistics',
        description:
            'Practice distributions, confidence intervals, regression, and real-world stats interpretation.',
        maxMembers: 6,
        currentMembers: _membersByGroup[104]!.length,
        createdAt: now.subtract(const Duration(days: 18)),
        coverImageUrl:
            'https://images.pexels.com/photos/590022/pexels-photo-590022.jpeg?auto=compress&cs=tinysrgb&w=1200',
        creatorName: 'Emma Davis',
        creatorAvatarUrl: 'https://randomuser.me/api/portraits/women/35.jpg',
        upcomingSessionsCount: _sessionsByGroup[104]!.length,
        nextSessionAt: _sessionsByGroup[104]!
            .map((s) => s.scheduledAt)
            .reduce((a, b) => a.isBefore(b) ? a : b),
        isPrivate: true,
        isJoined: true,
        isCreator: false,
      ),
      StudyGroup(
        id: 105,
        createdBy: 11,
        name: 'Physics Problem Solvers',
        subject: 'Physics',
        description:
            'A calm, focused group for breaking down physics problems step-by-step and building intuition.',
        maxMembers: 8,
        currentMembers: _membersByGroup[105]!.length,
        createdAt: now.subtract(const Duration(days: 12)),
        coverImageUrl:
            'https://images.pexels.com/photos/256262/pexels-photo-256262.jpeg?auto=compress&cs=tinysrgb&w=1200',
        creatorName: 'Daniel Wilson',
        creatorAvatarUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
        upcomingSessionsCount: _sessionsByGroup[105]!.length,
        nextSessionAt: _sessionsByGroup[105]!
            .map((s) => s.scheduledAt)
            .reduce((a, b) => a.isBefore(b) ? a : b),
        isPrivate: false,
        isJoined: false,
        isCreator: false,
      ),
      StudyGroup(
        id: 106,
        createdBy: 12,
        name: 'Calculus Intensive Prep',
        subject: 'Mathematics',
        description:
            'Join for focused drills and quick feedback. Great for keeping momentum through exams.',
        maxMembers: 6,
        currentMembers: _membersByGroup[106]!.length,
        createdAt: now.subtract(const Duration(days: 9)),
        coverImageUrl:
            'https://images.pexels.com/photos/4143794/pexels-photo-4143794.jpeg?auto=compress&cs=tinysrgb&w=1200',
        creatorName: 'Harper Thompson',
        creatorAvatarUrl: 'https://randomuser.me/api/portraits/women/28.jpg',
        upcomingSessionsCount: _sessionsByGroup[106]!.length,
        nextSessionAt: _sessionsByGroup[106]!
            .map((s) => s.scheduledAt)
            .reduce((a, b) => a.isBefore(b) ? a : b),
        isPrivate: false,
        isJoined: true,
        isCreator: false,
      ),
    ];
  }

  void _recomputeGroupFlags(int groupId) {
    final groupIndex = _mockGroups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    final group = _mockGroups[groupIndex];
    final members = _membersByGroup[groupId] ?? const <GroupMember>[];
    final isCreator = group.createdBy == _currentUserId;
    final isJoined = members.any((m) => m.userId == _currentUserId);

    _mockGroups[groupIndex] = group.copyWith(
      currentMembers: members.length,
      isJoined: isJoined,
      isCreator: isCreator,
    );
  }

  Future<void> _seedFirstMockGroupsToFirestore({int limit = 3}) async {
    if (_mockFirestoreSeeded) return;

    // Seed only the original mock groups from Study Group page data.
    final groupsToSeed = _mockGroups
        .where((g) => g.id >= 101 && g.id <= 103)
        .take(limit);

    for (final group in groupsToSeed) {
      try {
        await _saveGroupToFirestore(
          group: group,
          sessions: _sessionsByGroup[group.id] ?? const <StudySession>[],
        );
      } catch (_) {
        // Continue seeding remaining groups even if one write fails.
      }
    }

    _mockFirestoreSeeded = true;
  }

  @override
  Future<List<StudyGroup>> getAllGroups() async {
    try {
      _ensureSeeded();
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      for (final g in _mockGroups) {
        _recomputeGroupFlags(g.id);
      }

      // One-time sync: push first 3 seeded mock groups to Firestore.
      await _seedFirstMockGroupsToFirestore(limit: 3);

      return List<StudyGroup>.unmodifiable(_mockGroups);
    } catch (e) {
      throw Exception('Failed to fetch groups: $e');
    }
  }

  @override
  Future<StudyGroup?> getGroupById(int id) async {
    try {
      _ensureSeeded();
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final groupIndex = _mockGroups.indexWhere((group) => group.id == id);
      return groupIndex != -1 ? _mockGroups[groupIndex] : null;
    } catch (e) {
      throw Exception('Failed to fetch group: $e');
    }
  }

  @override
  Future<List<StudySession>> getGroupSessions(int groupId) async {
    try {
      _ensureSeeded();
      await Future.delayed(const Duration(milliseconds: 300));
      return List<StudySession>.unmodifiable(
        _sessionsByGroup[groupId] ?? const <StudySession>[],
      );
    } catch (e) {
      throw Exception('Failed to fetch group sessions: $e');
    }
  }

  @override
  Future<StudyGroup> createGroup({
    required String name,
    required String description,
    required String subject,
    required int maxMembers,
    required bool isPrivate,
    required List<StudySessionDraft> sessions,
  }) async {
    try {
      _ensureSeeded();
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      final groupId = _groupIdCounter++;

      final createdSessions = sessions
          .where((s) => s.title.trim().isNotEmpty)
          .map(
            (s) => StudySession(
              id: _sessionIdCounter++,
              groupId: groupId,
              title: s.title.trim(),
              scheduledAt: DateTime(
                s.scheduledAt.year,
                s.scheduledAt.month,
                s.scheduledAt.day,
                s.scheduledAt.hour,
                s.scheduledAt.minute,
              ),
              durationMinutes: s.durationMinutes,
              participantCount: 1,
            ),
          )
          .toList();

      createdSessions.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      final nextAt = createdSessions.isEmpty
          ? null
          : createdSessions.first.scheduledAt;

      final newGroup = StudyGroup(
        id: groupId,
        createdBy: _currentUserId,
        name: name,
        subject: subject,
        description: description,
        maxMembers: maxMembers,
        currentMembers: 1,
        createdAt: DateTime.now(),
        coverImageUrl: _subjectCoverImage(subject),
        creatorName: _currentUserName,
        creatorAvatarUrl: _currentUserAvatarUrl,
        upcomingSessionsCount: createdSessions.length,
        nextSessionAt: nextAt,
        isPrivate: isPrivate,
        isJoined: true,
        isCreator: true,
      );

      _membersByGroup[groupId] = <GroupMember>[
        GroupMember(
          id: _memberIdCounter++,
          groupId: groupId,
          userId: _currentUserId,
          userName: _currentUserName,
          avatarUrl: _currentUserAvatarUrl,
          joinedAt: DateTime.now(),
        ),
      ];
      _sessionsByGroup[groupId] = createdSessions;

      // Persist created group to Firebase first so creation only succeeds when synced.
      await _saveGroupToFirestore(group: newGroup, sessions: createdSessions);

      _mockGroups = <StudyGroup>[newGroup, ..._mockGroups];
      return newGroup;
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  @override
  Future<StudyGroup> updateGroup(
    int id, {
    required String name,
    required String subject,
    required String description,
    required int maxMembers,
  }) async {
    try {
      _ensureSeeded();
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      final index = _mockGroups.indexWhere((g) => g.id == id);
      if (index != -1) {
        final members = _membersByGroup[id] ?? const <GroupMember>[];
        final minAllowedMembers = members.length > 2 ? members.length : 2;
        if (maxMembers < minAllowedMembers) {
          throw Exception(
            'Member limit cannot be below joined members (${members.length}). Minimum allowed is $minAllowedMembers',
          );
        }

        final updatedGroup = _mockGroups[index].copyWith(
          name: name,
          subject: subject,
          description: description,
          maxMembers: maxMembers,
          currentMembers: members.length,
        );
        _mockGroups[index] = updatedGroup;
        _recomputeGroupFlags(id);
        return updatedGroup;
      }
      throw Exception('Group not found');
    } catch (e) {
      throw Exception('Failed to update group: $e');
    }
  }

  @override
  Future<void> deleteGroup(int id) async {
    try {
      _ensureSeeded();
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      _mockGroups.removeWhere((g) => g.id == id);
      _membersByGroup.remove(id);
      _sessionsByGroup.remove(id);
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }

  @override
  Future<void> joinGroup(int groupId) async {
    try {
      _ensureSeeded();
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final groupIndex = _mockGroups.indexWhere((g) => g.id == groupId);
      if (groupIndex != -1) {
        final group = _mockGroups[groupIndex];

        if (group.isPrivate && group.createdBy != _currentUserId) {
          throw Exception('Private group - invitation required');
        }

        if (group.createdBy == _currentUserId) {
          // Creator is already a member.
          return;
        }

        final members = _membersByGroup[groupId] ?? <GroupMember>[];
        final alreadyJoined = members.any((m) => m.userId == _currentUserId);
        if (alreadyJoined) return;

        if (group.currentMembers < group.maxMembers) {
          _membersByGroup[groupId] = <GroupMember>[
            ...members,
            GroupMember(
              id: _memberIdCounter++,
              groupId: groupId,
              userId: _currentUserId,
              userName: _currentUserName,
              avatarUrl: _currentUserAvatarUrl,
              joinedAt: DateTime.now(),
            ),
          ];
          _recomputeGroupFlags(groupId);
        } else {
          throw Exception('Group is full');
        }
      }
    } catch (e) {
      throw Exception('Failed to join group: $e');
    }
  }

  @override
  Future<void> leaveGroup(int groupId) async {
    try {
      _ensureSeeded();
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final groupIndex = _mockGroups.indexWhere((g) => g.id == groupId);
      if (groupIndex != -1) {
        final group = _mockGroups[groupIndex];

        if (group.createdBy == _currentUserId) {
          // Keep the demo simple: creators should delete the group instead.
          throw Exception('Creators cannot leave. Delete the group instead.');
        }

        final members = _membersByGroup[groupId] ?? <GroupMember>[];
        final nextMembers = members
            .where((m) => m.userId != _currentUserId)
            .toList();
        _membersByGroup[groupId] = nextMembers;
        _recomputeGroupFlags(groupId);
      }
    } catch (e) {
      throw Exception('Failed to leave group: $e');
    }
  }

  String _subjectCoverImage(String subject) {
    final key = subject.toLowerCase();
    if (key.contains('math') || key.contains('calculus')) {
      return 'https://images.pexels.com/photos/301920/pexels-photo-301920.jpeg?auto=compress&cs=tinysrgb&w=1200';
    }
    if (key.contains('computer') ||
        key.contains('machine') ||
        key.contains('code')) {
      return 'https://images.pexels.com/photos/546819/pexels-photo-546819.jpeg?auto=compress&cs=tinysrgb&w=1200';
    }
    if (key.contains('algorithm') || key.contains('data structure')) {
      return 'https://images.pexels.com/photos/574071/pexels-photo-574071.jpeg?auto=compress&cs=tinysrgb&w=1200';
    }
    if (key.contains('stat')) {
      return 'https://images.pexels.com/photos/590022/pexels-photo-590022.jpeg?auto=compress&cs=tinysrgb&w=1200';
    }
    if (key.contains('physics')) {
      return 'https://images.pexels.com/photos/256262/pexels-photo-256262.jpeg?auto=compress&cs=tinysrgb&w=1200';
    }
    return 'https://images.pexels.com/photos/1184572/pexels-photo-1184572.jpeg?auto=compress&cs=tinysrgb&w=1200';
  }

  @override
  Future<List<GroupMember>> getGroupMembers(int groupId) async {
    try {
      _ensureSeeded();
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      return List<GroupMember>.unmodifiable(
        _membersByGroup[groupId] ?? const <GroupMember>[],
      );
    } catch (e) {
      throw Exception('Failed to fetch group members: $e');
    }
  }

  @override
  Future<StudySession> addSession(
    int groupId, {
    required String title,
    required DateTime scheduledAt,
    required int durationMinutes,
  }) async {
    try {
      _ensureSeeded();
      await Future.delayed(const Duration(milliseconds: 500));

      final groupIndex = _mockGroups.indexWhere((g) => g.id == groupId);
      if (groupIndex == -1) {
        throw Exception('Group not found');
      }

      final session = StudySession(
        id: _sessionIdCounter++,
        groupId: groupId,
        title: title,
        scheduledAt: scheduledAt,
        durationMinutes: durationMinutes,
        participantCount: 1,
      );

      final current = _sessionsByGroup[groupId] ?? <StudySession>[];
      final next = [...current, session]
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      _sessionsByGroup[groupId] = next;

      final nextAt = next.isEmpty ? null : next.first.scheduledAt;
      _mockGroups[groupIndex] = _mockGroups[groupIndex].copyWith(
        upcomingSessionsCount: next.length,
        nextSessionAt: nextAt,
      );

      return session;
    } catch (e) {
      throw Exception('Failed to add session: $e');
    }
  }

  @override
  Future<StudySession> updateSession(
    int groupId,
    int sessionId, {
    required String title,
    required DateTime scheduledAt,
    required int durationMinutes,
  }) async {
    try {
      _ensureSeeded();
      await Future.delayed(const Duration(milliseconds: 450));

      final groupIndex = _mockGroups.indexWhere((g) => g.id == groupId);
      if (groupIndex == -1) {
        throw Exception('Group not found');
      }

      final sessions = _sessionsByGroup[groupId] ?? <StudySession>[];
      final sessionIndex = sessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex == -1) {
        throw Exception('Session not found');
      }

      final existing = sessions[sessionIndex];
      final updated = StudySession(
        id: existing.id,
        groupId: existing.groupId,
        title: title,
        scheduledAt: scheduledAt,
        durationMinutes: durationMinutes,
        participantCount: existing.participantCount,
      );

      final next = [...sessions];
      next[sessionIndex] = updated;
      next.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      _sessionsByGroup[groupId] = next;

      final nextAt = next.isEmpty ? null : next.first.scheduledAt;
      _mockGroups[groupIndex] = _mockGroups[groupIndex].copyWith(
        upcomingSessionsCount: next.length,
        nextSessionAt: nextAt,
      );

      return updated;
    } catch (e) {
      throw Exception('Failed to update session: $e');
    }
  }

  @override
  Future<SessionRequest> requestSession(
    int groupId, {
    required String title,
    required DateTime scheduledAt,
    required int durationMinutes,
  }) async {
    try {
      _ensureSeeded();
      await Future.delayed(const Duration(milliseconds: 500));

      final groupIndex = _mockGroups.indexWhere((g) => g.id == groupId);
      if (groupIndex == -1) {
        throw Exception('Group not found');
      }

      final request = SessionRequest(
        id: _requestIdCounter++,
        groupId: groupId,
        requestedByUserId: _currentUserId,
        requestedByUserName: _currentUserName,
        requestedByUserAvatar: _currentUserAvatarUrl,
        title: title,
        scheduledAt: scheduledAt,
        durationMinutes: durationMinutes,
        status: 'pending',
        requestedAt: DateTime.now(),
      );

      final current = _sessionRequestsByGroup[groupId] ?? <SessionRequest>[];
      _sessionRequestsByGroup[groupId] = [...current, request];

      return request;
    } catch (e) {
      throw Exception('Failed to request session: $e');
    }
  }

  @override
  Future<List<SessionRequest>> getGroupSessionRequests(int groupId) async {
    try {
      _ensureSeeded();
      await Future.delayed(const Duration(milliseconds: 500));

      return List<SessionRequest>.unmodifiable(
        _sessionRequestsByGroup[groupId] ?? const <SessionRequest>[],
      );
    } catch (e) {
      throw Exception('Failed to fetch session requests: $e');
    }
  }

  @override
  Future<void> approveSessionRequest(int requestId) async {
    try {
      _ensureSeeded();
      await Future.delayed(const Duration(milliseconds: 500));

      SessionRequest? targetRequest;
      int? targetGroupId;

      for (final groupId in _sessionRequestsByGroup.keys) {
        final requests = _sessionRequestsByGroup[groupId] ?? [];
        final idx = requests.indexWhere((r) => r.id == requestId);
        if (idx != -1) {
          targetRequest = requests[idx];
          targetGroupId = groupId;
          break;
        }
      }

      if (targetRequest == null || targetGroupId == null) {
        throw Exception('Session request not found');
      }

      final session = StudySession(
        id: _sessionIdCounter++,
        groupId: targetGroupId,
        title: targetRequest.title,
        scheduledAt: targetRequest.scheduledAt,
        durationMinutes: targetRequest.durationMinutes,
        participantCount: 1,
      );

      final current = _sessionsByGroup[targetGroupId] ?? <StudySession>[];
      final next = [...current, session]
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      _sessionsByGroup[targetGroupId] = next;

      final groupIndex = _mockGroups.indexWhere((g) => g.id == targetGroupId);
      if (groupIndex != -1) {
        final nextAt = next.isEmpty ? null : next.first.scheduledAt;
        _mockGroups[groupIndex] = _mockGroups[groupIndex].copyWith(
          upcomingSessionsCount: next.length,
          nextSessionAt: nextAt,
        );
      }

      final requests = _sessionRequestsByGroup[targetGroupId] ?? [];
      final approvedRequests = requests
          .map((r) => r.id == requestId ? r.copyWith(status: 'approved') : r)
          .toList();
      _sessionRequestsByGroup[targetGroupId] = approvedRequests;
    } catch (e) {
      throw Exception('Failed to approve session request: $e');
    }
  }

  @override
  Future<void> declineSessionRequest(int requestId) async {
    try {
      _ensureSeeded();
      await Future.delayed(const Duration(milliseconds: 500));

      for (final groupId in _sessionRequestsByGroup.keys) {
        final requests = _sessionRequestsByGroup[groupId] ?? [];
        final idx = requests.indexWhere((r) => r.id == requestId);
        if (idx != -1) {
          requests[idx] = requests[idx].copyWith(status: 'declined');
          return;
        }
      }

      throw Exception('Session request not found');
    } catch (e) {
      throw Exception('Failed to decline session request: $e');
    }
  }
}
