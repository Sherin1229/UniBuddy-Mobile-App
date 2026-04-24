import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../state/study_group_provider.dart';

class EditStudyGroupScreen extends StatefulWidget {
  final int groupId;

  const EditStudyGroupScreen({super.key, required this.groupId});

  @override
  State<EditStudyGroupScreen> createState() => _EditStudyGroupScreenState();
}

class _EditStudyGroupScreenState extends State<EditStudyGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _maxMembersController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _maxMembersController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<StudyGroupProvider>();
      await provider.fetchGroupById(widget.groupId);
      final group = provider.selectedGroup;
      if (!mounted || group == null) return;
      _nameController.text = group.name;
      _descriptionController.text = group.description;
      _maxMembersController.text = group.maxMembers.toString();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxMembersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x66000000),
      body: SafeArea(
        child: Consumer<StudyGroupProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.selectedGroup == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final group = provider.selectedGroup;
            final currentSubject = group?.subject ?? '';

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Edit Group',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Group Name',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameController,
                              decoration: _inputDecoration(),
                              validator: (value) {
                                final trimmed = value?.trim() ?? '';
                                if (trimmed.isEmpty) {
                                  return 'Please enter group name';
                                }
                                if (trimmed.length < 3) {
                                  return 'Group name must be at least 3 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Description',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 4,
                              decoration: _inputDecoration(),
                              validator: (value) {
                                final trimmed = value?.trim() ?? '';
                                if (trimmed.isEmpty) {
                                  return 'Please enter description';
                                }
                                if (trimmed.length < 10) {
                                  return 'Description must be at least 10 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Member Limit',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _maxMembersController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(),
                              validator: (value) {
                                final trimmed = value?.trim() ?? '';
                                if (trimmed.isEmpty) {
                                  return 'Please enter member limit';
                                }
                                final parsed = int.tryParse(trimmed);
                                if (parsed == null) {
                                  return 'Please enter a valid number';
                                }
                                if (parsed < 2) {
                                  return 'Member limit must be at least 2';
                                }
                                if (parsed > 50) {
                                  return 'Member limit must be 50 or less';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Minimum: 2 members',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      side: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: provider.isLoading
                                        ? null
                                        : () async {
                                            if (!_formKey.currentState!
                                                .validate()) {
                                              return;
                                            }

                                            await provider.updateGroup(
                                              widget.groupId,
                                              name: _nameController.text.trim(),
                                              subject: currentSubject,
                                              description:
                                                  _descriptionController.text
                                                      .trim(),
                                              maxMembers: int.parse(
                                                _maxMembersController.text
                                                    .trim(),
                                              ),
                                            );

                                            if (!context.mounted) {
                                              return;
                                            }

                                            if (provider.error == null) {
                                              Navigator.pop(context, true);
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Error: ${provider.error}',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBrand,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: provider.isLoading
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text('Save Changes'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryBrand, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
