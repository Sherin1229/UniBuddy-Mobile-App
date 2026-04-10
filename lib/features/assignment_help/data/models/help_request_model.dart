import 'package:cloud_firestore/cloud_firestore.dart';

enum HelpRequestStatus { overdue, open, solved }

class HelpRequest {
  final String id;
  final DateTime createdAt;
  final String ownerId;
  String title;
  String subject;
  String ownerName;
  String description;
  DateTime deadline;
  HelpRequestStatus status;
  final int views;
  final int likes;
  final int comments;
  final String? attachmentPath;
  final String? attachmentName;

  HelpRequest({
    required this.id,
    required this.createdAt,
    required this.ownerId,
    required this.title,
    required this.subject,
    required this.ownerName,
    required this.description,
    required this.deadline,
    this.status = HelpRequestStatus.open,
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
    this.attachmentPath,
    this.attachmentName,
  });

  factory HelpRequest.fromMap(Map<String, dynamic> map, String docId) {
    DateTime deadline = DateTime.now();
    if (map['deadline'] != null) {
      deadline = (map['deadline'] as Timestamp).toDate();
    }

    HelpRequestStatus status;
    final now = DateTime.now();
    final deadlineDay =
        DateTime(deadline.year, deadline.month, deadline.day);
    final today = DateTime(now.year, now.month, now.day);

    if (map['status'] == 'solved') {
      status = HelpRequestStatus.solved;
    } else if (deadlineDay.isBefore(today)) {
      status = HelpRequestStatus.overdue;
    } else {
      status = HelpRequestStatus.open;
    }

    DateTime createdAt = DateTime.now();
    if (map['createdAt'] != null) {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    }

    return HelpRequest(
      id: docId,
      createdAt: createdAt,
      ownerId: map['ownerId'] ?? '',
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      ownerName: map['ownerName'] ?? '',
      description: map['description'] ?? '',
      deadline: deadline,
      status: status,
      views: map['views'] ?? 0,
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      attachmentPath: map['attachmentPath'],
      attachmentName: map['attachmentName'],
    );
  }

  factory HelpRequest.fromJson(Map<String, dynamic> json) {
    DateTime deadline = DateTime.now();
    if (json['deadline'] != null) {
      // Handle both string and timestamp formats
      if (json['deadline'] is String) {
        deadline = DateTime.parse(json['deadline']);
      } else {
        deadline = DateTime.fromMillisecondsSinceEpoch(json['deadline']);
      }
    }

    HelpRequestStatus status;
    final now = DateTime.now();
    final deadlineDay =
        DateTime(deadline.year, deadline.month, deadline.day);
    final today = DateTime(now.year, now.month, now.day);

    if (json['status'] == 'solved') {
      status = HelpRequestStatus.solved;
    } else if (deadlineDay.isBefore(today)) {
      status = HelpRequestStatus.overdue;
    } else {
      status = HelpRequestStatus.open;
    }

    DateTime createdAt = DateTime.now();
    if (json['createdAt'] != null) {
      if (json['createdAt'] is String) {
        createdAt = DateTime.parse(json['createdAt']);
      } else if (json['createdAt'] is int) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt']);
      }
    }

    return HelpRequest(
      id: json['id'] ?? '',
      createdAt: createdAt,
      ownerId: json['ownerId'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      ownerName: json['ownerName'] ?? '',
      description: json['description'] ?? '',
      deadline: deadline,
      status: status,
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      attachmentPath: json['attachmentPath'],
      attachmentName: json['attachmentName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subject': subject,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status == HelpRequestStatus.solved ? 'solved' : 'open',
      'views': views,
      'likes': likes,
      'comments': comments,
      'attachmentPath': attachmentPath,
      'attachmentName': attachmentName,
    };
  }
}