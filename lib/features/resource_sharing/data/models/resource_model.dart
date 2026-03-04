class ResourceModel {
  final String id;
  final String title;
  final String subject;
  final String uploadedBy;
  final DateTime uploadedAt;
  final int downloads;
  final String fileType;
  final int fileSizeKb;

  const ResourceModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.downloads,
    required this.fileType,
    required this.fileSizeKb,
  });

  factory ResourceModel.fromMap(Map<String, dynamic> map, String id) {
    return ResourceModel(
      id: id,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedAt: DateTime.tryParse(map['uploadedAt'] ?? '') ?? DateTime.now(),
      downloads: map['downloads'] ?? 0,
      fileType: map['fileType'] ?? 'PDF',
      fileSizeKb: map['fileSizeKb'] ?? 0,
    );
  }
}
