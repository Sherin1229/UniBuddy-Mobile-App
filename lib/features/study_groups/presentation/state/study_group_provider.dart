import 'package:flutter/foundation.dart';
import '../../data/models/study_group.dart';
import '../../data/models/group_member.dart';
import '../../data/models/study_session.dart';
import '../../data/models/study_session_draft.dart';
import '../../data/models/session_request.dart';
import '../../data/repositories/study_group_repository_impl.dart';

class StudyGroupProvider extends ChangeNotifier {
  StudyGroupRepositoryImpl _repository = StudyGroupRepositoryImpl();

  List<StudyGroup> _groups = [];
  StudyGroup? _selectedGroup;
  List<GroupMember> _groupMembers = [];
  List<StudySession> _upcomingSessions = [];
  List<SessionRequest> _sessionRequests = [];
  bool _isLoading = false;
  String? _error;
  bool _isFetching = false; // Prevent concurrent fetches

  // Getters
  List<StudyGroup> get groups => _groups;
  StudyGroup? get selectedGroup => _selectedGroup;
  List<GroupMember> get groupMembers => _groupMembers;
  List<StudySession> get upcomingSessions => _upcomingSessions;
  List<SessionRequest> get sessionRequests => _sessionRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void reassemble() {
    final selectedGroupId = _selectedGroup?.id;

    _repository = StudyGroupRepositoryImpl();
    _groups = [];
    _selectedGroup = null;
    _groupMembers = [];
    _upcomingSessions = [];
    _sessionRequests = [];
    _isLoading = false;
    _isFetching = false;
    _error = null;
    notifyListeners();

    if (selectedGroupId != null) {
      Future<void>.microtask(() => fetchGroupById(selectedGroupId));
    } else {
      Future<void>.microtask(fetchAllGroups);
    }
  }

  // Fetch all groups
  Future<void> fetchAllGroups() async {
    // Prevent concurrent calls
    if (_isFetching) {
      return;
    }

    _isFetching = true;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _groups = List<StudyGroup>.from(await _repository.getAllGroups());
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isFetching = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch group by ID
  Future<void> fetchGroupById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedGroup = await _repository.getGroupById(id);
      if (_selectedGroup != null) {
        await fetchGroupMembers(id);
        await fetchGroupSessions(id);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create group
  Future<void> createGroup({
    required String name,
    required String description,
    required String subject,
    required int maxMembers,
    required bool isPrivate,
    required List<StudySessionDraft> sessions,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createGroup(
        name: name,
        description: description,
        subject: subject,
        maxMembers: maxMembers,
        isPrivate: isPrivate,
        sessions: sessions,
      );
      // Refresh all groups to get the newly created group
      _groups = List<StudyGroup>.from(await _repository.getAllGroups());
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update group
  Future<void> updateGroup(
    int id, {
    required String name,
    required String subject,
    required String description,
    required int maxMembers,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedGroup = await _repository.updateGroup(
        id,
        name: name,
        subject: subject,
        description: description,
        maxMembers: maxMembers,
      );

      final index = _groups.indexWhere((g) => g.id == id);
      if (index != -1) {
        _groups[index] = updatedGroup;
      }

      if (_selectedGroup?.id == id) {
        _selectedGroup = updatedGroup;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete group
  Future<void> deleteGroup(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteGroup(id);
      _groups.removeWhere((g) => g.id == id);
      if (_selectedGroup?.id == id) {
        _selectedGroup = null;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Join group
  Future<void> joinGroup(int groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.joinGroup(groupId);
      // Refresh group data
      await fetchGroupById(groupId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Leave group
  Future<void> leaveGroup(int groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.leaveGroup(groupId);
      await fetchGroupById(groupId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch group members
  Future<void> fetchGroupMembers(int groupId) async {
    try {
      _groupMembers = await _repository.getGroupMembers(groupId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchGroupSessions(int groupId) async {
    try {
      _upcomingSessions = await _repository.getGroupSessions(groupId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addSession(
    int groupId, {
    required String title,
    required DateTime scheduledAt,
    required int durationMinutes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.addSession(
        groupId,
        title: title,
        scheduledAt: scheduledAt,
        durationMinutes: durationMinutes,
      );
      await fetchGroupById(groupId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSession(
    int groupId,
    int sessionId, {
    required String title,
    required DateTime scheduledAt,
    required int durationMinutes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateSession(
        groupId,
        sessionId,
        title: title,
        scheduledAt: scheduledAt,
        durationMinutes: durationMinutes,
      );
      await fetchGroupById(groupId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear selection
  void clearSelection() {
    _selectedGroup = null;
    _groupMembers = [];
    _upcomingSessions = [];
    _sessionRequests = [];
    notifyListeners();
  }

  // Request a session (for non-creators)
  Future<void> requestSession(
    int groupId, {
    required String title,
    required DateTime scheduledAt,
    required int durationMinutes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.requestSession(
        groupId,
        title: title,
        scheduledAt: scheduledAt,
        durationMinutes: durationMinutes,
      );
      await fetchSessionRequests(groupId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch session requests for a group (for creator)
  Future<void> fetchSessionRequests(int groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessionRequests = List<SessionRequest>.from(
        await _repository.getGroupSessionRequests(groupId),
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Approve a session request
  Future<void> approveSessionRequest(int requestId, int groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.approveSessionRequest(requestId);
      await fetchSessionRequests(groupId);
      await fetchGroupById(groupId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Decline a session request
  Future<void> declineSessionRequest(int requestId, int groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.declineSessionRequest(requestId);
      await fetchSessionRequests(groupId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
