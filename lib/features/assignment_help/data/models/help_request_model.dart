enum HelpRequestStatus { overdue, open, solved }

class HelpRequest {
  final String id;
  final String title;
  final String subject;
  final String ownerName;
  final String description;
  final DateTime deadline;
  HelpRequestStatus status;
  final int views;
  final int likes;
  final int comments;
  final String? attachmentPath;
  final String? attachmentName;

  HelpRequest({
    required this.id,
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
