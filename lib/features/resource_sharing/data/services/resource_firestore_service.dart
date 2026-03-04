import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resource_model.dart';

class ResourceFirestoreService {
  final _col = FirebaseFirestore.instance.collection('resources');

  Stream<List<ResourceModel>> fetchResources({String? subject}) {
    Query query = _col.orderBy('uploadedAt', descending: true);
    if (subject != null && subject != 'All') {
      query = query.where('subject', isEqualTo: subject);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((d) => ResourceModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList());
  }

  Stream<List<ResourceModel>> searchResources(String query) {
    return _col
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ResourceModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }
}
