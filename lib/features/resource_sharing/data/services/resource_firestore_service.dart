import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import '../models/resource_model.dart';

enum ResourceReaction { like, dislike }

class ResourceReactionSummary {
  final int likes;
  final int dislikes;
  final ResourceReaction? userReaction;

  const ResourceReactionSummary({
    required this.likes,
    required this.dislikes,
    required this.userReaction,
  });
}

class ResourceFirestoreService {
  CollectionReference get _col =>
      FirebaseFirestore.instance.collection('resources');
  FirebaseStorage get _storage => FirebaseStorage.instance;

  static String _reactionToString(ResourceReaction reaction) {
    switch (reaction) {
      case ResourceReaction.like:
        return 'like';
      case ResourceReaction.dislike:
        return 'dislike';
    }
  }

  static ResourceReaction? _reactionFromString(String? value) {
    switch (value) {
      case 'like':
        return ResourceReaction.like;
      case 'dislike':
        return ResourceReaction.dislike;
      default:
        return null;
    }
  }

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

  Future<void> createResource(
    ResourceModel resource, {
    Uint8List? fileBytes,
    String? fileName,
    String? externalFileUrl,
  }) async {
    final externalUrl = externalFileUrl?.trim();
    if (externalUrl != null && externalUrl.isNotEmpty) {
      await _col
          .doc(resource.id)
          .set(
            resource
                .copyWith(
                  fileName:
                      resource.fileName ??
                      Uri.tryParse(externalUrl)?.pathSegments.last,
                  fileUrl: externalUrl,
                  storagePath: null,
                )
                .toMap(),
          );
      return;
    }

    if (fileBytes == null || fileName == null || fileName.trim().isEmpty) {
      throw FirebaseException(
        plugin: 'firebase_storage',
        code: 'invalid-argument',
        message: 'Either file bytes or an external link is required.',
      );
    }

    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final storagePath = 'resources/${resource.id}/$safeName';
    final ref = _storage.ref(storagePath);

    await ref.putData(fileBytes);
    String? downloadUrl;
    try {
      downloadUrl = await _getDownloadUrlWithRetry(ref);
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        rethrow;
      }
      // Keep upload successful even if URL is not immediately resolvable.
      downloadUrl = null;
    }

    await _col
        .doc(resource.id)
        .set(
          resource
              .copyWith(
                fileName: fileName,
                fileUrl: downloadUrl,
                storagePath: storagePath,
              )
              .toMap(),
        );
  }

  Future<String> resolveDownloadUrl(ResourceModel resource) async {
    if (resource.fileUrl != null && resource.fileUrl!.isNotEmpty) {
      return resource.fileUrl!;
    }

    final storagePath = resource.storagePath;
    if (storagePath == null || storagePath.isEmpty) {
      throw FirebaseException(
        plugin: 'firebase_storage',
        code: 'object-not-found',
        message: 'No storage path found for this resource.',
      );
    }

    final ref = _storage.ref(storagePath);
    final downloadUrl = await _getDownloadUrlWithRetry(ref);
    await _col.doc(resource.id).update({'fileUrl': downloadUrl});
    return downloadUrl;
  }

  Future<String> _getDownloadUrlWithRetry(Reference ref) async {
    for (var attempt = 0; attempt < 4; attempt++) {
      try {
        return await ref.getDownloadURL();
      } on FirebaseException catch (e) {
        final isTransientNotFound = e.code == 'object-not-found' && attempt < 3;
        if (!isTransientNotFound) {
          rethrow;
        }
        await Future<void>.delayed(const Duration(milliseconds: 700));
      }
    }

    throw FirebaseException(
      plugin: 'firebase_storage',
      code: 'object-not-found',
      message: 'Uploaded file could not be resolved from storage.',
    );
  }

  Future<bool> resourceExists(String id) async {
    final snap = await _col.doc(id).get();
    return snap.exists;
  }

  Future<ResourceReaction?> getUserReaction({
    required String resourceId,
    required String userId,
  }) async {
    final doc = await _col
        .doc(resourceId)
        .collection('reactions')
        .doc(userId)
        .get();
    final data = doc.data();
    return _reactionFromString(data?['reaction'] as String?);
  }

  Future<ResourceReactionSummary> setUserReaction({
    required String resourceId,
    required String userId,
    required ResourceReaction? reaction,
  }) async {
    final resourceRef = _col.doc(resourceId);
    final reactionRef = resourceRef.collection('reactions').doc(userId);

    return FirebaseFirestore.instance.runTransaction((tx) async {
      final resourceSnap = await tx.get(resourceRef);
      if (!resourceSnap.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'Resource not found.',
        );
      }

      final resourceData = resourceSnap.data() as Map<String, dynamic>? ?? {};
      var likes = (resourceData['likes'] as num?)?.toInt() ?? 0;
      var dislikes = (resourceData['dislikes'] as num?)?.toInt() ?? 0;

      final reactionSnap = await tx.get(reactionRef);
      final reactionData = reactionSnap.data();
      final previous = _reactionFromString(
        reactionData?['reaction'] as String?,
      );

      if (previous == ResourceReaction.like) {
        likes = (likes - 1).clamp(0, 1 << 30);
      } else if (previous == ResourceReaction.dislike) {
        dislikes = (dislikes - 1).clamp(0, 1 << 30);
      }

      if (reaction == ResourceReaction.like) {
        likes += 1;
      } else if (reaction == ResourceReaction.dislike) {
        dislikes += 1;
      }

      if (reaction == null) {
        tx.delete(reactionRef);
      } else {
        tx.set(reactionRef, {
          'reaction': _reactionToString(reaction),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      tx.update(resourceRef, {'likes': likes, 'dislikes': dislikes});

      return ResourceReactionSummary(
        likes: likes,
        dislikes: dislikes,
        userReaction: reaction,
      );
    });
  }

  Future<void> updateResource(ResourceModel resource) async {
    await _col.doc(resource.id).update(resource.toMap());
  }

  Future<void> incrementDownloadCount(String resourceId) async {
    await _col.doc(resourceId).update({'downloads': FieldValue.increment(1)});
  }

  Future<void> deleteResource(String id) async {
    final doc = await _col.doc(id).get();
    final data = doc.data() as Map<String, dynamic>?;
    final storagePath = data?['storagePath'] as String?;

    if (storagePath != null && storagePath.isNotEmpty) {
      try {
        await _storage.ref(storagePath).delete();
      } catch (_) {
        // Keep delete resilient even if file is already gone.
      }
    }

    await _col.doc(id).delete();
  }
}
