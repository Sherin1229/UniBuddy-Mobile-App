import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/models/resource_model.dart';
import '../../data/repositories/resource_repository.dart';
import 'resource_library_state.dart';

class ResourceLibraryProvider extends ChangeNotifier {
  final _repo = ResourceRepository();
  ResourceLibraryState _state = const ResourceLibraryState();
  StreamSubscription<List<ResourceModel>>? _subscription;
  List<ResourceModel> _allResources = const [];

  ResourceLibraryState get state => _state;

  static const List<String> filters = [
    'All',
    'Notes',
    'Past Papers',
    'Lectures',
  ];

  void loadResources() {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repo.getResources().listen(
      (resources) {
        _allResources = resources;
        _state = _state.copyWith(
          resources: _applyFilters(resources),
          isLoading: false,
          clearError: true,
        );
        notifyListeners();
      },
      onError: (error) {
        _state = _state.copyWith(
          isLoading: false,
          error: 'Failed to load resources: $error',
        );
        notifyListeners();
      },
    );
  }

  void setFilter(String filter) {
    _state = _state.copyWith(
      selectedFilter: filter,
      resources: _applyFilters(_allResources, filter: filter),
    );
    notifyListeners();
  }

  void setSearch(String query) {
    _state = _state.copyWith(
      searchQuery: query,
      resources: _applyFilters(_allResources, searchQuery: query),
    );
    notifyListeners();
  }

  Future<String?> createResource({
    required String title,
    required String category,
    required String subject,
    required String description,
    required String uploadedBy,
    required String fileType,
    required int fileSizeKb,
  }) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    try {
      final resource = ResourceModel(
        id: '',
        title: title,
        category: category,
        subject: subject,
        description: description,
        uploadedBy: uploadedBy,
        uploadedAt: DateTime.now(),
        downloads: 0,
        fileType: fileType,
        fileSizeKb: fileSizeKb,
      );

      await _repo.createResource(resource);
      _state = _state.copyWith(isSubmitting: false, clearError: true);
      notifyListeners();
      return null;
    } catch (error) {
      const message = 'Failed to upload resource. Please try again.';
      _state = _state.copyWith(isSubmitting: false, error: message);
      notifyListeners();
      return message;
    }
  }

  Future<String?> updateResource(ResourceModel resource) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    try {
      await _repo.updateResource(resource);
      _state = _state.copyWith(isSubmitting: false, clearError: true);
      notifyListeners();
      return null;
    } catch (error) {
      const message = 'Failed to update resource. Please try again.';
      _state = _state.copyWith(isSubmitting: false, error: message);
      notifyListeners();
      return message;
    }
  }

  Future<String?> deleteResource(String id) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    try {
      await _repo.deleteResource(id);
      _state = _state.copyWith(isSubmitting: false, clearError: true);
      notifyListeners();
      return null;
    } catch (error) {
      const message = 'Failed to delete resource. Please try again.';
      _state = _state.copyWith(isSubmitting: false, error: message);
      notifyListeners();
      return message;
    }
  }

  List<ResourceModel> _applyFilters(
    List<ResourceModel> resources, {
    String? filter,
    String? searchQuery,
  }) {
    final selectedFilter = filter ?? _state.selectedFilter;
    final query = (searchQuery ?? _state.searchQuery).trim().toLowerCase();

    var filtered = resources;
    if (selectedFilter != 'All') {
      filtered = filtered
          .where(
            (r) => r.category.toLowerCase() == selectedFilter.toLowerCase(),
          )
          .toList();
    }

    if (query.isNotEmpty) {
      filtered = filtered.where((r) {
        return r.title.toLowerCase().contains(query) ||
            r.subject.toLowerCase().contains(query) ||
            r.description.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
