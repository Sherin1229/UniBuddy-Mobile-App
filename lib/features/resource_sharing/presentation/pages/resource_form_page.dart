import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/resource_model.dart';
import '../state/resource_library_provider.dart';

const _teal = Color(0xFF3D9E8C);

class ResourceFormPage extends StatefulWidget {
  final ResourceModel? existingResource;

  const ResourceFormPage({super.key, this.existingResource});

  @override
  State<ResourceFormPage> createState() => _ResourceFormPageState();
}

class _ResourceFormPageState extends State<ResourceFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _subjectController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _uploadedByController;
  late final TextEditingController _fileTypeController;
  late final TextEditingController _fileSizeKbController;

  static const _categories = ['Notes', 'Past Papers', 'Lectures'];
  late String _selectedCategory;

  bool get _isEditing => widget.existingResource != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingResource;

    _titleController = TextEditingController(text: existing?.title ?? '');
    _subjectController = TextEditingController(text: existing?.subject ?? '');
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    _uploadedByController = TextEditingController(
      text: existing?.uploadedBy ?? '',
    );
    _fileTypeController = TextEditingController(
      text: existing?.fileType ?? 'PDF',
    );
    _fileSizeKbController = TextEditingController(
      text: (existing?.fileSizeKb ?? 0) == 0 ? '' : '${existing!.fileSizeKb}',
    );
    _selectedCategory = existing?.category ?? _categories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _uploadedByController.dispose();
    _fileTypeController.dispose();
    _fileSizeKbController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ResourceLibraryProvider>();
    final fileSize = int.tryParse(_fileSizeKbController.text.trim()) ?? 0;

    String? result;
    if (_isEditing) {
      final existing = widget.existingResource!;
      result = await provider.updateResource(
        existing.copyWith(
          title: _titleController.text.trim(),
          category: _selectedCategory,
          subject: _subjectController.text.trim(),
          description: _descriptionController.text.trim(),
          uploadedBy: _uploadedByController.text.trim(),
          fileType: _fileTypeController.text.trim().toUpperCase(),
          fileSizeKb: fileSize,
        ),
      );
    } else {
      result = await provider.createResource(
        title: _titleController.text.trim(),
        category: _selectedCategory,
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        uploadedBy: _uploadedByController.text.trim(),
        fileType: _fileTypeController.text.trim().toUpperCase(),
        fileSizeKb: fileSize,
      );
    }

    if (!mounted) {
      return;
    }

    if (result == null) {
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context
        .watch<ResourceLibraryProvider>()
        .state
        .isSubmitting;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        title: Text(_isEditing ? 'Edit Resource' : 'Upload Resource'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: isSubmitting
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                decoration: _inputDecoration('Category'),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _subjectController,
                label: 'Subject',
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Subject is required'
                    : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _uploadedByController,
                label: 'Uploaded By',
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Uploader name is required'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _fileTypeController,
                      label: 'File Type',
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'File type is required'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _fileSizeKbController,
                      label: 'Size (KB)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsed = int.tryParse((value ?? '').trim());
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid size';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isEditing ? 'Update Resource' : 'Upload Resource'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
