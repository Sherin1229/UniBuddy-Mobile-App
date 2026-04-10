import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../data/models/resource_model.dart';
import '../state/resource_library_provider.dart';
import '../../../../shared/widgets/animated_app_background.dart';

const _teal = Color(0xFF3D9E8C);

class ResourceFormPage extends StatefulWidget {
  final ResourceModel? existingResource;

  const ResourceFormPage({super.key, this.existingResource});

  @override
  State<ResourceFormPage> createState() => _ResourceFormPageState();
}

class _ResourceFormPageState extends State<ResourceFormPage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  late final TextEditingController _titleController;
  late final TextEditingController _subjectController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _uploadedByController;
  late final TextEditingController _fileTypeController;
  late final TextEditingController _fileSizeKbController;

  static const _categories = ['Notes', 'Past Papers', 'Lectures'];
  static const _allowedFileTypes = ['PDF', 'DOC', 'DOCX', 'PPT', 'PPTX', 'ZIP'];
  late String _selectedCategory;
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;

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
    _fileTypeController = TextEditingController(text: existing?.fileType ?? '');
    _fileSizeKbController = TextEditingController(
      text: (existing?.fileSizeKb ?? 0) == 0 ? '' : '${existing!.fileSizeKb}',
    );
    _selectedFileName = existing == null ? null : 'Existing file metadata';
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
      setState(() => _autoValidateMode = AutovalidateMode.always);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the highlighted fields before uploading.'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
      return;
    }

    if (!_isEditing && _selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please attach a file before uploading.'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
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
        fileBytes: _selectedFileBytes,
        fileName: _selectedFileName,
      );
    }

    if (!mounted) {
      return;
    }

    if (result == null) {
      final successText = _isEditing
          ? 'Resource updated successfully.'
          : 'Resource uploaded successfully.';
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: Text(successText),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result), backgroundColor: const Color(0xFFB91C1C)),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: _allowedFileTypes.map((e) => e.toLowerCase()).toList(),
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final extension = (file.extension ?? '').toUpperCase();
    if (!_allowedFileTypes.contains(extension)) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unsupported file type. Allowed: ${_allowedFileTypes.join(', ')}',
          ),
          backgroundColor: const Color(0xFFB91C1C),
        ),
      );
      return;
    }

    final sizeKb = (file.size / 1024).ceil();

    setState(() {
      _selectedFileName = file.name;
      _selectedFileBytes = file.bytes;
      _fileTypeController.text = extension;
      _fileSizeKbController.text = sizeKb.toString();
    });

    if (_selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not read file bytes. Please choose the file again.',
          ),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
      _removeAttachedFile();
    }
  }

  void _removeAttachedFile() {
    setState(() {
      _selectedFileName = null;
      _selectedFileBytes = null;
      _fileTypeController.clear();
      _fileSizeKbController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context
        .watch<ResourceLibraryProvider>()
        .state
        .isSubmitting;

    return Scaffold(
      backgroundColor: const Color(0xFFE6FFFB),
      appBar: AppBar(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        title: Text(_isEditing ? 'Edit Resource' : 'Upload Resource'),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedAppBackground()),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              autovalidateMode: _autoValidateMode,
              child: Card(
                elevation: 10,
                color: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Share A Learning Resource',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Upload clean, useful material for your classmates.',
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _titleController,
                        label: 'Title',
                        hint: 'e.g. Calculus Limits Cheat Sheet',
                        icon: Icons.title_rounded,
                        validator: _validateTitle,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
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
                        decoration: _inputDecoration(
                          'Category',
                          hint: 'Select a resource category',
                          icon: Icons.category_outlined,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _subjectController,
                        label: 'Subject',
                        hint: 'e.g. Mathematics',
                        icon: Icons.menu_book_rounded,
                        validator: _validateSubject,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Briefly explain what this file contains',
                        icon: Icons.description_outlined,
                        maxLines: 3,
                        validator: _validateDescription,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _uploadedByController,
                        label: 'Uploaded By',
                        hint: 'Your display name',
                        icon: Icons.person_outline_rounded,
                        validator: _validateUploader,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.78),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedFileName == null
                                        ? 'No file attached yet'
                                        : 'Attached: $_selectedFileName',
                                    style: TextStyle(
                                      color: _selectedFileName == null
                                          ? Colors.blueGrey.shade500
                                          : const Color(0xFF0F766E),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  onPressed: isSubmitting ? null : _pickFile,
                                  icon: const Icon(Icons.attach_file_rounded),
                                  label: const Text('Attach File'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _teal,
                                    side: BorderSide(
                                      color: _teal.withOpacity(0.45),
                                    ),
                                  ),
                                ),
                                if (_selectedFileName != null) ...[
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: isSubmitting
                                        ? null
                                        : _removeAttachedFile,
                                    icon: const Icon(Icons.close_rounded),
                                    label: const Text('Remove'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'File type and size are auto-filled from the selected file.',
                              style: TextStyle(
                                color: Colors.blueGrey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedFileName == null
                                    ? Colors.amber.withOpacity(0.12)
                                    : const Color(0xFF22C55E).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _selectedFileName == null
                                      ? Colors.amber.withOpacity(0.45)
                                      : const Color(
                                          0xFF16A34A,
                                        ).withOpacity(0.45),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _selectedFileName == null
                                        ? Icons.info_outline_rounded
                                        : Icons.check_circle_rounded,
                                    color: _selectedFileName == null
                                        ? Colors.amber.shade700
                                        : const Color(0xFF15803D),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedFileName == null
                                          ? 'Attach a file to complete upload metadata.'
                                          : 'File attached successfully. Type and size updated automatically.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _selectedFileName == null
                                            ? Colors.amber.shade800
                                            : const Color(0xFF166534),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _fileTypeController,
                              label: 'File Type',
                              hint: 'PDF / DOCX / PPTX',
                              icon: Icons.insert_drive_file_outlined,
                              textCapitalization: TextCapitalization.characters,
                              validator: _validateFileType,
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _fileSizeKbController,
                              label: 'Size (KB)',
                              hint: 'e.g. 450',
                              icon: Icons.data_usage_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: _validateFileSize,
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allowedFileTypes
                            .map(
                              (type) => Chip(
                                label: Text(type),
                                labelStyle: const TextStyle(fontSize: 11),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: const Color(0xFFE6FFFB),
                                side: BorderSide(
                                  color: const Color(
                                    0xFF0F766E,
                                  ).withOpacity(0.2),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _teal,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
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
                            : Text(
                                _isEditing
                                    ? 'Update Resource'
                                    : 'Upload Resource',
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextFormField _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      readOnly: readOnly,
      decoration: _inputDecoration(label, hint: hint, icon: icon),
    );
  }

  InputDecoration _inputDecoration(
    String label, {
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.86),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _teal, width: 1.8),
      ),
    );
  }

  String? _validateTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Title is required.';
    }
    if (text.length < 5) {
      return 'Title should be at least 5 characters.';
    }
    return null;
  }

  String? _validateSubject(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Subject is required.';
    }
    if (!RegExp(r'^[a-zA-Z&()\-\s]{2,}$').hasMatch(text)) {
      return 'Use only letters and common symbols (&, -, parentheses).';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Description is required.';
    }
    if (text.length < 15) {
      return 'Description should be at least 15 characters.';
    }
    return null;
  }

  String? _validateUploader(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Uploader name is required.';
    }
    if (!RegExp(r'^[a-zA-Z\s.]{2,}$').hasMatch(text)) {
      return 'Use a valid name (letters, spaces, periods).';
    }
    return null;
  }

  String? _validateFileType(String? value) {
    final text = value?.trim().toUpperCase() ?? '';
    if (text.isEmpty) {
      return 'File type is required.';
    }
    if (!_allowedFileTypes.contains(text)) {
      return 'Allowed types: ${_allowedFileTypes.join(', ')}';
    }
    return null;
  }

  String? _validateFileSize(String? value) {
    final size = int.tryParse((value ?? '').trim());
    if (size == null) {
      return 'Enter file size in KB.';
    }
    if (size < 10) {
      return 'File size should be at least 10 KB.';
    }
    if (size > 50000) {
      return 'File size is too large for demo (max 50000 KB).';
    }
    return null;
  }
}
