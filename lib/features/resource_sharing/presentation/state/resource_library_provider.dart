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

    final stream = _state.searchQuery.isNotEmpty
        ? _repo.searchResources(_state.searchQuery)
        : _repo.getResources(subject: _state.selectedFilter);

    stream.listen(
      (resources) {
        _state = _state.copyWith(resources: resources, isLoading: false);
        notifyListeners();
      },
      onError: (e) {
        _state = _state.copyWith(isLoading: false, error: e.toString());
        notifyListeners();
      },
    );
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
