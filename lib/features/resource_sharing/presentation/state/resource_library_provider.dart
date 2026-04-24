import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/models/resource_model.dart';
import '../../data/services/resource_firestore_service.dart';
import 'resource_library_state.dart';

class ResourceLibraryProvider extends ChangeNotifier {
  static const Duration _requestTimeout = Duration(seconds: 30);
  final ResourceFirestoreService _service = ResourceFirestoreService();
  ResourceLibraryState _state = const ResourceLibraryState();
  List<ResourceModel> _allResources = const [];
  StreamSubscription<List<ResourceModel>>? _resourceSubscription;

  ResourceLibraryState get state => _state;

  static const List<String> filters = [
    'All',
    'Notes',
    'Past Papers',
    'Lectures',
  ];

  @override
  void dispose() {
    _resourceSubscription?.cancel();
    super.dispose();
  }

  void loadResources() {
    _resourceSubscription?.cancel();
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    _resourceSubscription = _service.fetchResources().listen(
      (resources) {
        _allResources = resources;
        _state = _state.copyWith(
          resources: _applyFilters(_allResources),
          isLoading: false,
          clearError: true,
        );
        notifyListeners();
      },
      onError: (error) {
        _state = _state.copyWith(
          isLoading: false,
          error: 'Failed to load resources. Please try again.',
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
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    if (FirebaseAuth.instance.currentUser == null) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
      } catch (_) {
        final message =
            'Authentication failed. Please sign in and try uploading again.';
        _state = _state.copyWith(isSubmitting: false, error: message);
        notifyListeners();
        return message;
      }
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      final message = 'Authentication failed. Please sign in and try again.';
      _state = _state.copyWith(isSubmitting: false, error: message);
      notifyListeners();
      return message;
    }

    if (fileBytes == null || fileName == null || fileName.trim().isEmpty) {
      final message = 'Please attach a file before uploading.';
      _state = _state.copyWith(isSubmitting: false, error: message);
      notifyListeners();
      return message;
    }

    final resource = ResourceModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      category: category,
      subject: subject,
      description: description,
      uploadedBy: uploadedBy,
      uploadedByUid: currentUser.uid,
      uploadedAt: DateTime.now(),
      downloads: 0,
      likes: 0,
      dislikes: 0,
      fileType: fileType,
      fileSizeKb: fileSizeKb,
      fileName: fileName,
      fileUrl: null,
    );

    try {
      // File upload can legitimately take longer than metadata writes.
      await _service.createResource(
        resource,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      _state = _state.copyWith(isSubmitting: false, clearError: true);
      notifyListeners();
      return null;
    } catch (error) {
      if (error is TimeoutException) {
        // Avoid false negatives when Firestore commit succeeds after client timeout.
        final wasCreated = await _verifyResourceCreation(resource.id);
        if (wasCreated) {
          _state = _state.copyWith(isSubmitting: false, clearError: true);
          notifyListeners();
          return null;
        }
      }

      final message = _mapBackendError(error, action: 'upload');
      _state = _state.copyWith(isSubmitting: false, error: message);
      notifyListeners();
      return message;
    }
  }

  Future<bool> _verifyResourceCreation(String id) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final exists = await _service
            .resourceExists(id)
            .timeout(const Duration(seconds: 4));
        if (exists) {
          return true;
        }
      } catch (_) {
        // Ignore and retry quickly to allow eventual consistency.
      }
      await Future<void>.delayed(const Duration(milliseconds: 600));
    }
    return false;
  }

  Future<String?> updateResource(ResourceModel resource) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    try {
      await _service.updateResource(resource).timeout(_requestTimeout);
      _state = _state.copyWith(isSubmitting: false, clearError: true);
      notifyListeners();
      return null;
    } catch (error) {
      final message = _mapBackendError(error, action: 'update');
      _state = _state.copyWith(isSubmitting: false, error: message);
      notifyListeners();
      return message;
    }
  }

  Future<String?> deleteResource(String id) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    try {
      await _service.deleteResource(id).timeout(_requestTimeout);
      _state = _state.copyWith(isSubmitting: false, clearError: true);
      notifyListeners();
      return null;
    } catch (error) {
      final message = _mapBackendError(error, action: 'delete');
      _state = _state.copyWith(isSubmitting: false, error: message);
      notifyListeners();
      return message;
    }
  }

  String _mapBackendError(Object error, {required String action}) {
    if (error is TimeoutException) {
      return 'Request timed out while trying to $action the resource. Check your connection and try again.';
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
        case 'unauthorized':
          return 'Permission denied. Please check your Firestore/Storage rules.';
        case 'unavailable':
        case 'network-request-failed':
          return 'Firestore is temporarily unavailable. Please try again.';
        case 'unauthenticated':
          return 'You need to sign in before uploading resources.';
        case 'bucket-not-found':
          return 'Storage bucket is not configured correctly for this Firebase project.';
        case 'invalid-argument':
          return 'Please attach a file before uploading.';
        case 'object-not-found':
          return 'File reference could not be found in storage.';
        case 'quota-exceeded':
          return 'Firebase Storage quota exceeded. Try again later.';
        case 'retry-limit-exceeded':
          return 'Upload timed out due to poor network. Please try again.';
        case 'cloudinary-not-configured':
          return 'Cloudinary is not configured. Set cloud name and upload preset.';
        default:
          return 'Failed to $action resource (${error.code}).';
      }
    }

    return 'Failed to $action resource. Please try again.';
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
}
