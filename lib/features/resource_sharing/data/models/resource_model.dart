import 'package:cloud_firestore/cloud_firestore.dart';

class ResourceModel {
  final String id;
  final String title;
  final String category;
  final String subject;
  final String description;
  final String uploadedBy;
  final DateTime uploadedAt;
  final int downloads;
  final int likes;
  final int dislikes;
  final String fileType;
  final int fileSizeKb;
  final String? fileName;
  final String? fileUrl;
  final String? storagePath;

  const ResourceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.subject,
    required this.description,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.downloads,
    required this.likes,
    required this.dislikes,
    required this.fileType,
    required this.fileSizeKb,
    this.fileName,
    this.fileUrl,
    this.storagePath,
  });

  ResourceModel copyWith({
    String? id,
    String? title,
    String? category,
    String? subject,
    String? description,
    String? uploadedBy,
    DateTime? uploadedAt,
    int? downloads,
    int? likes,
    int? dislikes,
    String? fileType,
    int? fileSizeKb,
    String? fileName,
    String? fileUrl,
    String? storagePath,
  }) {
    return ResourceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      downloads: downloads ?? this.downloads,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      fileType: fileType ?? this.fileType,
      fileSizeKb: fileSizeKb ?? this.fileSizeKb,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      storagePath: storagePath ?? this.storagePath,
    );
  }

  factory ResourceModel.fromMap(Map<String, dynamic> map, String id) {
    final uploadedAtRaw = map['uploadedAt'];
    DateTime uploadedAt;
    if (uploadedAtRaw is DateTime) {
      uploadedAt = uploadedAtRaw;
    } else if (uploadedAtRaw is Timestamp) {
      uploadedAt = uploadedAtRaw.toDate();
    } else {
      uploadedAt =
          DateTime.tryParse((uploadedAtRaw ?? '').toString()) ?? DateTime.now();
    }

    return ResourceModel(
      id: id,
      title: map['title'] ?? '',
      category: map['category'] ?? 'Notes',
      subject: map['subject'] ?? '',
      description: map['description'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedAt: uploadedAt,
      downloads: map['downloads'] ?? 0,
      likes: map['likes'] ?? 0,
      dislikes: map['dislikes'] ?? 0,
      fileType: map['fileType'] ?? 'PDF',
      fileSizeKb: map['fileSizeKb'] ?? 0,
      fileName: map['fileName'] as String?,
      fileUrl: map['fileUrl'] as String?,
      storagePath: map['storagePath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'subject': subject,
      'description': description,
      'uploadedBy': uploadedBy,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'downloads': downloads,
      'likes': likes,
      'dislikes': dislikes,
      'fileType': fileType,
      'fileSizeKb': fileSizeKb,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'storagePath': storagePath,
    };
  }
}
