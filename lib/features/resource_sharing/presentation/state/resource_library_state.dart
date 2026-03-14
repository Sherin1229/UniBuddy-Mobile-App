import '../../data/models/resource_model.dart';

class ResourceLibraryState {
  final List<ResourceModel> resources;
  final bool isLoading;
  final String? error;
  final String selectedFilter;
  final String searchQuery;

  const ResourceLibraryState({
    this.resources = const [],
    this.isLoading = false,
    this.error,
    this.selectedFilter = 'All',
    this.searchQuery = '',
  });

  ResourceLibraryState copyWith({
    List<ResourceModel>? resources,
    bool? isLoading,
    String? error,
    String? selectedFilter,
    String? searchQuery,
  }) {
    return ResourceLibraryState(
      resources: resources ?? this.resources,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
