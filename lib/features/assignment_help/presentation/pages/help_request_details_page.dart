import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/help_request_model.dart';
import '../../data/models/help_response_model.dart';

class HelpRequestDetailsPage extends StatefulWidget {
  final HelpRequest request;
  const HelpRequestDetailsPage({super.key, required this.request});

  @override
  State<HelpRequestDetailsPage> createState() => _HelpRequestDetailsPageState();
}

class _HelpRequestDetailsPageState extends State<HelpRequestDetailsPage> {
  late List<HelpResponse> responses;
  final _responseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    responses = [
      HelpResponse(
        responderName: 'Kushani A',
        text: 'Sure. An example of a JOIN query /SELECT students, name, courses, title FROM students JOIN courses ON students.id = courses.id;',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        attachmentName: 'Example SQL.jpg',
        likes: 9,
        comments: 2,
        isOwner: true,
      ),
      HelpResponse(
        responderName: 'Samantha R',
        text: 'You can also use LEFT JOIN for optional matches.',
        date: DateTime.now().subtract(const Duration(hours: 1)),
        likes: 3,
        comments: 3,
      ),
    ];
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  void _postResponse() {
    final text = _responseController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      responses.insert(0, HelpResponse(
        responderName: 'You',
        text: text,
        date: DateTime.now(),
        isOwner: false,
      ));
      _responseController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Response posted!')),
    );
  }

  Color _getStatusColor(HelpRequestStatus status) {
    switch (status) {
      case HelpRequestStatus.overdue:
        return const Color(0xFFDC2626);
      case HelpRequestStatus.open:
        return const Color(0xFF2563EB);
      case HelpRequestStatus.solved:
        return const Color(0xFF059669);
    }
  }

  String _getStatusText(HelpRequestStatus status) {
    switch (status) {
      case HelpRequestStatus.overdue:
        return 'OVERDUE';
      case HelpRequestStatus.open:
        return 'OPEN';
      case HelpRequestStatus.solved:
        return 'SOLVED';
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final statusColor = _getStatusColor(request.status);
    final statusText = _getStatusText(request.status);
    final deadlineStr = DateFormat('MMMM d, yyyy').format(request.deadline);
    final isOwner = request.ownerName == 'Kushani A'; // Replace with actual user check

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Request Details'),
        actions: [
          if (isOwner && request.status != HelpRequestStatus.solved)
            TextButton.icon(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              label: const Text('Mark as Solved', style: TextStyle(color: Colors.green)),
              onPressed: () {
                setState(() {
                  widget.request.status = HelpRequestStatus.solved;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Marked as solved (mock only)')),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
            ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () async {
                final newValues = await showDialog<Map<String, String>>(
                  context: context,
                  builder: (ctx) {
                    final titleController = TextEditingController(text: request.title);
                    final descController = TextEditingController(text: request.description);
                    return AlertDialog(
                      title: const Text('Edit Request'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: titleController,
                            decoration: const InputDecoration(labelText: 'Title'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: descController,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(labelText: 'Description'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop({
                              'title': titleController.text,
                              'description': descController.text,
                            });
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    );
                  },
                );
                if (newValues != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request updated (mock only)')),
                  );
                  // In a real app, update the backend and refresh the page.
                }
              },
            ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Request'),
                    content: const Text('Are you sure you want to delete this request?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request deleted (placeholder)')),
                          );
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            request.title,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 18, color: Color(0xFF6B7280)),
                        const SizedBox(width: 6),
                        Text('Owner: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(request.ownerName),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.book_outlined, size: 18, color: Color(0xFF6B7280)),
                        const SizedBox(width: 6),
                        Text('Subject: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(request.subject),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18, color: Color(0xFF6B7280)),
                        const SizedBox(width: 6),
                        Text('Deadline: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(deadlineStr),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      request.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 18),
                    if (request.attachmentName != null)
                      Row(
                        children: [
                          const Icon(Icons.attach_file, color: Color(0xFF2563EB)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E7FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(request.attachmentName!),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.visibility, size: 18, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text('${request.views}'),
                        const SizedBox(width: 18),
                        Icon(Icons.thumb_up_alt_outlined, size: 18, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text('${request.likes}'),
                        const SizedBox(width: 18),
                        Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text('${request.comments}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text('Responses', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ...responses.map((r) => _buildResponseCard(r)).toList(),
            const SizedBox(height: 24),
            _buildPostResponseBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseCard(HelpResponse r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(r.responderName[0]),
                ),
                const SizedBox(width: 10),
                Text(r.responderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (r.isOwner)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('OWNER', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                const Spacer(),
                Text(DateFormat('MMM d, HH:mm').format(r.date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 10),
            Text(r.text),
            if (r.attachmentName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 18, color: Color(0xFF2563EB)),
                    const SizedBox(width: 4),
                    Text(r.attachmentName!),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text('${r.likes}'),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text('${r.comments}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostResponseBox() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _responseController,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write a response...',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF0F766E)),
              onPressed: _postResponse,
              tooltip: 'Post Response',
            ),
          ],
        ),
      ),
    );
  }
}
