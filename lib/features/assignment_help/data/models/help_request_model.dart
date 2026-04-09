enum HelpRequestStatus { overdue, open, solved }

class HelpRequest {
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
}
