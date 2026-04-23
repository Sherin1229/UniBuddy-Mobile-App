import '../../data/models/resource_model.dart';

class ResourceLibraryState {
  final List<ResourceModel> resources;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String selectedFilter;
  final String searchQuery;

  const ResourceLibraryState({
    this.resources = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.selectedFilter = 'All',
    this.searchQuery = '',
  });

  ResourceLibraryState copyWith({
    List<ResourceModel>? resources,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    String? selectedFilter,
    String? searchQuery,
  }) {
    return ResourceLibraryState(
      resources: resources ?? this.resources,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
