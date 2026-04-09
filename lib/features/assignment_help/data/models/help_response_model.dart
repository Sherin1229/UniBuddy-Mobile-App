class HelpResponse {
  final String responderName;
  final String text;
  final DateTime date;
  final String? attachmentName;
  final int likes;
  final int comments;
  final bool isOwner;

  HelpResponse({
    required this.responderName,
    required this.text,
    required this.date,
    this.attachmentName,
    this.likes = 0,
    this.comments = 0,
    this.isOwner = false,
  });
}
