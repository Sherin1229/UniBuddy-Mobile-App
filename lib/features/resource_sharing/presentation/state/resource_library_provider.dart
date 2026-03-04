import 'package:flutter/material.dart';
import '../../data/models/resource_model.dart';
import '../../data/repositories/resource_repository.dart';
import 'resource_library_state.dart';

class ResourceLibraryProvider extends ChangeNotifier {
  final _repo = ResourceRepository();
  ResourceLibraryState _state = const ResourceLibraryState();

  ResourceLibraryState get state => _state;

  static const List<String> filters = ['All', 'Notes', 'Past Papers', 'Lectures'];

  void loadResources() {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    // Mock data for visual testing
    Future.delayed(const Duration(seconds: 1), () {
      final mockResources = [
        ResourceModel(
          id: '1',
          title: 'Calculus Study Guide',
          subject: 'Mathematics',
          uploadedBy: 'Sarah',
          uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
          downloads: 124,
          fileType: 'PDF',
          fileSizeKb: 450,
        ),
        ResourceModel(
          id: '2',
          title: 'Ancient History Notes',
          subject: 'History',
          uploadedBy: 'Alex',
          uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
          downloads: 85,
          fileType: 'PDF',
          fileSizeKb: 1200,
        ),
        ResourceModel(
          id: '3',
          title: 'Java Programming Basics',
          subject: 'Computer Science',
          uploadedBy: 'John',
          uploadedAt: DateTime.now().subtract(const Duration(hours: 3)),
          downloads: 210,
          fileType: 'PDF',
          fileSizeKb: 890,
        ),
      ];

      List<ResourceModel> filtered = mockResources;
      if (_state.selectedFilter != 'All') {
        filtered = mockResources
            .where((r) => r.subject == _state.selectedFilter || (r.subject == 'Computer Science' && _state.selectedFilter == 'Lectures'))
            .toList();
      }
      if (_state.searchQuery.isNotEmpty) {
        filtered = mockResources
            .where((r) => r.title.toLowerCase().contains(_state.searchQuery.toLowerCase()))
            .toList();
      }

      _state = _state.copyWith(resources: filtered, isLoading: false);
      notifyListeners();
    });
  }

  void setFilter(String filter) {
    _state = _state.copyWith(selectedFilter: filter, searchQuery: '');
    loadResources();
  }

  void setSearch(String query) {
    _state = _state.copyWith(searchQuery: query, selectedFilter: 'All');
    loadResources();
  }
}
