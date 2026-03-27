import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resource_model.dart';

class ResourceFirestoreService {
  CollectionReference get _col =>
      FirebaseFirestore.instance.collection('resources');

  Stream<List<ResourceModel>> fetchResources({String? category}) {
    Query query = _col.orderBy('uploadedAt', descending: true);
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map(
      (snap) => snap.docs
          .map(
            (d) =>
                ResourceModel.fromMap(d.data() as Map<String, dynamic>, d.id),
          )
          .toList(),
    );
  }

  Stream<List<ResourceModel>> searchResources(String query) {
    return _col
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => ResourceModel.fromMap(
                  d.data() as Map<String, dynamic>,
                  d.id,
                ),
              )
              .toList(),
        );
  }

  Future<void> createResource(ResourceModel resource) async {
    await _col.add(resource.toMap());
  }

  Future<void> updateResource(ResourceModel resource) async {
    await _col.doc(resource.id).update(resource.toMap());
  }

  Future<void> deleteResource(String id) async {
    await _col.doc(id).delete();
  }
}
