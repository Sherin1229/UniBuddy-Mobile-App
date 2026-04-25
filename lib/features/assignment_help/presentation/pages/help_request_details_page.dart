import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/help_request_model.dart';
import '../../data/models/help_response_model.dart';

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
  late int _commentCount;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _requestSubscription;

  // Firestore reference for responses subcollection
  CollectionReference get _responsesRef => FirebaseFirestore.instance
      .collection('help_requests')
      .doc(widget.request.id)
      .collection('responses');

  DocumentReference<Map<String, dynamic>> get _requestRef =>
      FirebaseFirestore.instance.collection('help_requests').doc(widget.request.id);

  @override
  void initState() {
    super.initState();
    _commentCount = widget.request.comments;
    _requestSubscription = _requestRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final comments = snapshot.data()?['comments'];
        if (comments is int) {
          setState(() {
            _commentCount = comments;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _requestSubscription?.cancel();
    _responseController.dispose();
    super.dispose();
  }

  // ── Post a response to Firestore ──────────────────
  void _postResponse() async {
    final text = _responseController.text.trim();
    if (text.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    final responderName = currentUser?.displayName ??
        currentUser?.email?.split('@').first ??
        'Anonymous';
    final responderEmail = currentUser?.email ?? '';
    final responderId = currentUser?.uid ?? '';
    final isOwner = responderId.isNotEmpty && responderId == widget.request.ownerId;

    setState(() => _isPosting = true);
    try {
      await _requestRef.update({'comments': FieldValue.increment(1)});

      await _responsesRef.add({
        'responderId': responderId,
        'responderName': responderName,
        'responderEmail': responderEmail,
        'text': text,
        'date': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': 0,
        'isOwner': isOwner,
        'attachmentName': null,
      });

      if (mounted) {
        setState(() {
          _commentCount += 1;
        });
        _responseController.clear();
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

  // ── Show Edit Dialog ─────────────────────────────
  void _showEditDialog(HelpRequest request) {
    final titleController = TextEditingController(text: request.title);
    final subjectController = TextEditingController(text: request.subject);
    final descriptionController =
        TextEditingController(text: request.description);
    final deadlineController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(request.deadline),
    );
    DateTime selectedDeadline = request.deadline;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.edit_document, color: Color(0xFF0F766E), size: 28),
              SizedBox(width: 10),
              Text(
                'Edit Help Request',
                style: TextStyle(
                  color: Color(0xFF134E4A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: const TextStyle(color: Color(0xFF0F766E)),
                      filled: true,
                      fillColor: const Color(0xFFF0FDFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon:
                          const Icon(Icons.title, color: Color(0xFF0F766E)),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      labelStyle: const TextStyle(color: Color(0xFF0F766E)),
                      filled: true,
                      fillColor: const Color(0xFFF0FDFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon:
                          const Icon(Icons.book, color: Color(0xFF0F766E)),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: const TextStyle(color: Color(0xFF0F766E)),
                      filled: true,
                      fillColor: const Color(0xFFF0FDFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.description,
                          color: Color(0xFF0F766E)),
                    ),
                    validator: (v) =>
                        v == null || v.length < 10 ? 'Min 10 chars' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: deadlineController,
                    readOnly: true,
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDeadline,
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDeadline = picked;
                          deadlineController.text =
                              DateFormat('yyyy-MM-dd').format(picked);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Deadline',
                      labelStyle: const TextStyle(color: Color(0xFF0F766E)),
                      filled: true,
                      fillColor: const Color(0xFFF0FDFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.calendar_today,
                          color: Color(0xFF0F766E)),
                      suffixIcon: const Icon(Icons.arrow_drop_down,
                          color: Color(0xFF0F766E)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await _requestRef.update({
                      'title': titleController.text.trim(),
                      'subject': subjectController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'deadline': Timestamp.fromDate(selectedDeadline),
                    });
                    if (mounted) {
                      setState(() {
                        request.title = titleController.text.trim();
                        request.subject = subjectController.text.trim();
                        request.description = descriptionController.text.trim();
                        request.deadline = selectedDeadline;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Request updated successfully!'),
                          backgroundColor: Color(0xFF0F766E),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Update failed: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
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
      backgroundColor: const Color(0xFFF2FCF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F766E),
        elevation: 0,
        title: const Text(
          'Help Request Details',
          style: TextStyle(
            color: Color(0xFF0F766E),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          if (isOwner && request.status != HelpRequestStatus.solved)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFDDF5EB),
                  foregroundColor: const Color(0xFF0F766E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark as Solved'),
                onPressed: _markAsSolved,
              ),
            ),
          if (isOwner)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFFFF),
                  foregroundColor: const Color(0xFF0F766E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.edit),
                tooltip: 'Edit',
                onPressed: () => _showEditDialog(request),
              ),
            ),
          if (isOwner)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEEF0),
                  foregroundColor: const Color(0xFFB91C1C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.delete),
                tooltip: 'Delete',
                onPressed: _deleteRequest,
              ),
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
                    color: const Color(0xFFF5FBF7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: const Color(0xFFBAD8C1),
                        width: 1.4,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
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
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF134E4A),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: statusColor.withAlpha(
                                      (0.18 * 255).round()),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _metaText('Owner', request.ownerName),
                              const SizedBox(height: 8),
                              _metaText('Subject', request.subject),
                              const SizedBox(height: 8),
                              _metaText('Deadline', deadlineStr),
                              const SizedBox(height: 8),
                              _metaText('Comments', '$_commentCount'),
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
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
            decoration: const BoxDecoration(
              color: Color(0xFFF7FDF8),
              border: Border(
                  top: BorderSide(color: Color(0xFFD7EDE3))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _responseController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Write a response...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _isPosting
                    ? const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF0F766E)),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDF5EB),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send,
                              color: Color(0xFF0F766E)),
                          onPressed: _postResponse,
                        ),
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
                color: Color(0xFF64748B))),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F766E))),
      ],
    );
  }

  Widget _buildResponseCard(HelpResponse r) {
    final displayName = r.responderName.isNotEmpty
        ? r.responderName
        : (r.responderEmail.split('@').first.isNotEmpty
            ? r.responderEmail.split('@').first
            : 'Anonymous');
    final avatarChar = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'A';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFFD8E9E0), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFE5E7EB),
                  child: Text(
                    avatarChar,
                    style: const TextStyle(
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Text(displayName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155))),
                if (r.isOwner)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Owner',
                        style: TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, HH:mm').format(r.date),
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(r.text,
                style: const TextStyle(color: Color(0xFF334155))),
            if (r.attachmentName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file,
                        size: 18, color: Color(0xFF2563EB)),
                    const SizedBox(width: 4),
                    Text(r.attachmentName!,
                        style: const TextStyle(
                            color: Color(0xFF0F766E),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}