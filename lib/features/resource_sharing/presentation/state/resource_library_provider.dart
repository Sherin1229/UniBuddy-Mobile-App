import 'package:flutter/material.dart';
import '../../data/models/resource_model.dart';
import 'resource_library_state.dart';

class ResourceLibraryProvider extends ChangeNotifier {
  ResourceLibraryState _state = const ResourceLibraryState();
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

    Future.delayed(const Duration(milliseconds: 350), () {
      _allResources = _mockResources();
      _state = _state.copyWith(
        resources: _applyFilters(_allResources),
        isLoading: false,
        clearError: true,
      );
      notifyListeners();
    });
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
        id: DateTime.now().microsecondsSinceEpoch.toString(),
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

      _allResources = [resource, ..._allResources];
      _state = _state.copyWith(
        isSubmitting: false,
        resources: _applyFilters(_allResources),
        clearError: true,
      );
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
      _allResources = _allResources
          .map((r) => r.id == resource.id ? resource : r)
          .toList();
      _state = _state.copyWith(
        isSubmitting: false,
        resources: _applyFilters(_allResources),
        clearError: true,
      );
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
      _allResources = _allResources.where((r) => r.id != id).toList();
      _state = _state.copyWith(
        isSubmitting: false,
        resources: _applyFilters(_allResources),
        clearError: true,
      );
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

  List<ResourceModel> _mockResources() {
    return [
      ResourceModel(
        id: 'r1',
        title: 'Calculus Study Guide',
        category: 'Notes',
        subject: 'Mathematics',
        description:
            'Comprehensive guide covering limits, derivatives, and integrals with worked examples.',
        uploadedBy: 'Sarah Perera',
        uploadedAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
        downloads: 124,
        fileType: 'PDF',
        fileSizeKb: 450,
      ),
      ResourceModel(
        id: 'r2',
        title: 'Data Structures Past Paper 2023',
        category: 'Past Papers',
        subject: 'Computer Science',
        description:
            'Final exam paper with marking scheme and a breakdown of high-weight questions.',
        uploadedBy: 'Nimali Jayasena',
        uploadedAt: DateTime.now().subtract(const Duration(days: 6)),
        downloads: 302,
        fileType: 'PDF',
        fileSizeKb: 780,
      ),
      ResourceModel(
        id: 'r3',
        title: 'OOP Lecture Slides - Week 5',
        category: 'Lectures',
        subject: 'Software Engineering',
        description:
            'Covers abstraction, encapsulation, inheritance, and polymorphism with UML samples.',
        uploadedBy: 'Kavindu Silva',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 18)),
        downloads: 88,
        fileType: 'PPTX',
        fileSizeKb: 1560,
      ),
      ResourceModel(
        id: 'r4',
        title: 'Database Systems Quick Revision',
        category: 'Notes',
        subject: 'Information Systems',
        description:
            'Concise revision notes for SQL joins, normalization, indexing, and transactions.',
        uploadedBy: 'Tharushi Fernando',
        uploadedAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        downloads: 167,
        fileType: 'DOCX',
        fileSizeKb: 620,
      ),
    ];
  }
}
