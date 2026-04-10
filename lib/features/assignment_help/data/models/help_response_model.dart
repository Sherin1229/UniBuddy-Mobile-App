import 'package:cloud_firestore/cloud_firestore.dart';

class HelpResponse {
  final String id;
  final String responderId;
  final String responderName;
  final String responderEmail;
  final String text;
  final DateTime date;
  final String? attachmentName;
  final int likes;
  final int comments;
  final bool isOwner;

  HelpResponse({
    required this.id,
    required this.responderId,
    required this.responderName,
    required this.responderEmail,
    required this.text,
    required this.date,
    this.attachmentName,
    this.likes = 0,
    this.comments = 0,
    this.isOwner = false,
  });

  factory HelpResponse.fromMap(Map<String, dynamic> map, String docId) {
    DateTime date = DateTime.now();
    if (map['date'] != null) {
      date = (map['date'] as Timestamp).toDate();
    }
    return HelpResponse(
      id: docId,
      responderId: map['responderId'] ?? '',
      responderName: map['responderName'] ?? '',
      responderEmail: map['responderEmail'] ?? '',
      text: map['text'] ?? '',
      date: date,
      attachmentName: map['attachmentName'],
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      isOwner: map['isOwner'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'responderId': responderId,
      'responderName': responderName,
      'responderEmail': responderEmail,
      'text': text,
      'date': Timestamp.fromDate(date),
      'attachmentName': attachmentName,
      'likes': likes,
      'comments': comments,
      'isOwner': isOwner,
    };
  }
}