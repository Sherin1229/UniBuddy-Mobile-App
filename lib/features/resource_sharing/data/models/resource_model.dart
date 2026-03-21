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
  final String fileType;
  final int fileSizeKb;

  const ResourceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.subject,
    required this.description,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.downloads,
    required this.fileType,
    required this.fileSizeKb,
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
    String? fileType,
    int? fileSizeKb,
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
      fileType: fileType ?? this.fileType,
      fileSizeKb: fileSizeKb ?? this.fileSizeKb,
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
      fileType: map['fileType'] ?? 'PDF',
      fileSizeKb: map['fileSizeKb'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'subject': subject,
      'description': description,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
      'downloads': downloads,
      'fileType': fileType,
      'fileSizeKb': fileSizeKb,
    };
  }
}
