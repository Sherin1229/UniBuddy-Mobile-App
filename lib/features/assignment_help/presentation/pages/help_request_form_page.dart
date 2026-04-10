import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/help_request_model.dart';

class HelpRequestFormPage extends StatefulWidget {
  const HelpRequestFormPage({super.key});

  @override
  State<HelpRequestFormPage> createState() => _HelpRequestFormPageState();
}

class _HelpRequestFormPageState extends State<HelpRequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedSubject;
  PlatformFile? _pickedFile;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser?.displayName != null) {
      _ownerNameController.text = currentUser!.displayName!;
    }
  }

  final List<String> _subjects = [
    'Database Systems',
    'Programming',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _pickAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  void _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _deadlineController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Parse deadline
      final deadline = DateTime.parse(_deadlineController.text.trim());

      // Create help request model
      final currentUser = FirebaseAuth.instance.currentUser;
      final helpRequest = HelpRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        title: _titleController.text.trim(),
        subject: _selectedSubject!,
        ownerId: currentUser?.uid ?? '',
        ownerName: _ownerNameController.text.trim(),
        description: _descriptionController.text.trim(),
        deadline: deadline,
        attachmentPath: _pickedFile?.path,
        attachmentName: _pickedFile?.name,
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('help_requests')
          .doc(helpRequest.id)
          .set({
            ...helpRequest.toMap(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Help request submitted successfully!')),
        );
        // Clear form or navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit help request: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFEFFBF6),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: const Color(0xFFD6EDE0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: const Color(0xFF78C4A7), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Help Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6FCF9),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: _buildInputDecoration('Title'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedSubject,
                        items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _selectedSubject = v),
                        decoration: _buildInputDecoration('Subject'),
                        validator: (v) => v == null || v.isEmpty ? 'Subject is required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _deadlineController,
                        readOnly: true,
                        onTap: _pickDeadline,
                        decoration: _buildInputDecoration('Deadline', suffixIcon: const Icon(Icons.calendar_today)),
                        validator: (v) => v == null || v.isEmpty ? 'Deadline is required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: _buildInputDecoration('Description'),
                  validator: (v) => v == null || v.trim().length < 10 ? 'Description must be at least 10 characters' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ownerNameController,
                        decoration: _buildInputDecoration('Your Name'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: _buildInputDecoration('Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Email is required';
                          final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
                          if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: _buildInputDecoration('Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone number is required';
                    final digitsOnly = v.replaceAll(RegExp(r'\D'), '');
                    if (digitsOnly.length < 9) return 'Phone number must be at least 9 digits';
                    if (digitsOnly.length > 10) return 'Phone number must not exceed 10 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB7E4D1),
                        foregroundColor: const Color(0xFF0F766E),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Pick Attachment'),
                      onPressed: _pickAttachment,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _pickedFile != null ? _pickedFile!.name : 'No file selected',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(160, 48),
                      backgroundColor: const Color(0xFFDDF5EB),
                      foregroundColor: const Color(0xFF0F766E),
                      elevation: 0,
                    ),
                    onPressed: _isSubmitting ? null : _submitForm,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F766E)),
                          )
                        : const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
