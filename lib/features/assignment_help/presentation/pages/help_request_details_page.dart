import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/help_request_model.dart';
import '../../data/models/help_response_model.dart';
import 'edit_help_request_page.dart';

class HelpRequestDetailsPage extends StatefulWidget {
  final HelpRequest request;
  const HelpRequestDetailsPage({super.key, required this.request});

  @override
  State<HelpRequestDetailsPage> createState() =>
      _HelpRequestDetailsPageState();
}

class _HelpRequestDetailsPageState extends State<HelpRequestDetailsPage> {
  final _responseController = TextEditingController();
  bool _isPosting = false;

  // Firestore reference for responses subcollection
  CollectionReference get _responsesRef => FirebaseFirestore.instance
      .collection('help_requests')
      .doc(widget.request.id)
      .collection('responses');

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  // ── Post a response to Firestore ──────────────────
  void _postResponse() async {
    final text = _responseController.text.trim();
    if (text.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    final responderName = currentUser?.displayName ?? 'Anonymous';
    final currentUid = currentUser?.uid;
    final isOwner = currentUid != null && currentUid == widget.request.ownerId;

    setState(() => _isPosting = true);
    try {
      await _responsesRef.add({
        'responderName': responderName,
        'text': text,
        'date': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': 0,
        'isOwner': isOwner,
        'attachmentName': null,
      });
      _responseController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Response posted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  // ── Mark as Solved in Firestore ───────────────────
  void _markAsSolved() async {
    try {
      await FirebaseFirestore.instance
          .collection('help_requests')
          .doc(widget.request.id)
          .update({'status': 'solved'});
      if (mounted) {
        setState(() => widget.request.status = HelpRequestStatus.solved);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marked as solved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  // ── Delete request from Firestore ─────────────────
  void _deleteRequest() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Request'),
        content:
            const Text('Are you sure you want to delete this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await FirebaseFirestore.instance
                    .collection('help_requests')
                    .doc(widget.request.id)
                    .delete();
                if (!mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request deleted!')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete: $e')),
                );
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
    final deadlineStr =
        DateFormat('MMMM d, yyyy').format(request.deadline);
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUid = currentUser?.uid;
    final currentDisplayName = currentUser?.displayName;
    final isOwner = (currentUid != null && request.ownerId == currentUid) ||
        (request.ownerId.isEmpty && currentDisplayName != null && request.ownerName == currentDisplayName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Request Details'),
        actions: [
          if (isOwner && request.status != HelpRequestStatus.solved)
            TextButton.icon(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              label: const Text('Mark as Solved',
                  style: TextStyle(color: Colors.green)),
              onPressed: _markAsSolved,
            ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () async {
                final updated = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        EditHelpRequestPage(request: request),
                  ),
                );
                if (updated == true) setState(() {});
              },
            ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
              onPressed: _deleteRequest,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Request card ──
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  request.title,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  statusText,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 16,
                            runSpacing: 6,
                            children: [
                              _metaText('Owner', request.ownerName),
                              _metaText('Subject', request.subject),
                              _metaText('Deadline', deadlineStr),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(request.description,
                              style: const TextStyle(fontSize: 16)),
                          if (request.attachmentName != null) ...[
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const Icon(Icons.attach_file,
                                    color: Color(0xFF2563EB)),
                                const SizedBox(width: 8),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0E7FF),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                      request.attachmentName!),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Icon(Icons.visibility,
                                  size: 18,
                                  color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text('${request.views}'),
                              const SizedBox(width: 18),
                              Icon(Icons.thumb_up_alt_outlined,
                                  size: 18,
                                  color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text('${request.likes}'),
                              const SizedBox(width: 18),
                              Icon(Icons.chat_bubble_outline,
                                  size: 18,
                                  color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text('${request.comments}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Live responses from Firestore ──
                  Text('Responses',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),

                  StreamBuilder<QuerySnapshot>(
                    stream: _responsesRef
                        .orderBy('date', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('No responses yet. Be the first!',
                              style:
                                  TextStyle(color: Colors.grey)),
                        );
                      }
                      final responses =
                          snapshot.data!.docs.map((doc) {
                        return HelpResponse.fromMap(
                          doc.data() as Map<String, dynamic>,
                          doc.id,
                        );
                      }).toList();

                      return Column(
                        children: responses
                            .map((r) => _buildResponseCard(r))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // ── Reply bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
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
                _isPosting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send,
                            color: Color(0xFF0F766E)),
                        onPressed: _postResponse,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaText(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280))),
        Text(value,
            style:
                const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildResponseCard(HelpResponse r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
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
                Text(r.responderName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                if (r.isOwner)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('OWNER',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, HH:mm').format(r.date),
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(r.text),
            if (r.attachmentName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file,
                        size: 18, color: Color(0xFF2563EB)),
                    const SizedBox(width: 4),
                    Text(r.attachmentName!),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.thumb_up_alt_outlined,
                    size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text('${r.likes}'),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline,
                    size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text('${r.comments}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}