import '../models/resource_model.dart';
import '../services/resource_firestore_service.dart';

class ResourceRepository {
  final _service = ResourceFirestoreService();

  Stream<List<ResourceModel>> getResources({String? subject}) =>
      _service.fetchResources(subject: subject);

  Stream<List<ResourceModel>> searchResources(String query) =>
      _service.searchResources(query);
}
