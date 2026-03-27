import '../models/resource_model.dart';
import '../services/resource_firestore_service.dart';

class ResourceRepository {
  final _service = ResourceFirestoreService();

  Stream<List<ResourceModel>> getResources({String? category}) =>
      _service.fetchResources(category: category);

  Stream<List<ResourceModel>> searchResources(String query) =>
      _service.searchResources(query);

  Future<void> createResource(ResourceModel resource) =>
      _service.createResource(resource);

  Future<void> updateResource(ResourceModel resource) =>
      _service.updateResource(resource);

  Future<void> deleteResource(String id) => _service.deleteResource(id);
}
