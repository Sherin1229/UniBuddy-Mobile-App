import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_app_background.dart';
import 'live_session_room_page.dart';
import '../state/study_group_provider.dart';

class StudyGroupDetailScreen extends StatefulWidget {
  final int groupId;

  const StudyGroupDetailScreen({super.key, required this.groupId});

  @override
  State<StudyGroupDetailScreen> createState() => _StudyGroupDetailScreenState();
}

class _StudyGroupDetailScreenState extends State<StudyGroupDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudyGroupProvider>().fetchGroupById(widget.groupId);
      context.read<StudyGroupProvider>().fetchSessionRequests(widget.groupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedAppBackground(
              durationSeconds: 28,
              motionScale: 0.55,
              opacityScale: 0.85,
            ),
          ),
          Consumer<StudyGroupProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.selectedGroup == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.selectedGroup == null) {
                return const Center(child: Text('Group not found'));
              }

              final group = provider.selectedGroup!;
              const currentUserId = 1;

              final isFull = group.currentMembers >= group.maxMembers;
              final spotsLeft = (group.maxMembers - group.currentMembers).clamp(
                0,
                1 << 30,
              );
              final isCreator = group.isCreator;
              final isJoined = group.isJoined;
              final isPrivate = group.isPrivate;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GroupHeroHeader(
                      coverImageUrl: group.coverImageUrl,
                      title: group.name,
                      subject: group.subject,
                      creatorName: group.creatorName,
                      creatorAvatarUrl: group.creatorAvatarUrl,
                      currentMembers: group.currentMembers,
                      maxMembers: group.maxMembers,
                      isCreator: isCreator,
                      onBack: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      onEdit: isCreator
                          ? () => _showEditDialog(context, provider, group)
                          : null,
                      onDelete: isCreator
                          ? () => _showDeleteConfirmation(context, provider)
                          : null,
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Membership summary + join/leave
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${group.currentMembers} of ${group.maxMembers} members',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        isFull
                                            ? 'Full'
                                            : '$spotsLeft spots left',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryBrand,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: Container(
                                      height: 8,
                                      color: AppColors.border,
                                      child: FractionallySizedBox(
                                        widthFactor: group.maxMembers == 0
                                            ? 0
                                            : (group.currentMembers /
                                                      group.maxMembers)
                                                  .clamp(0, 1),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryBrand,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (isCreator)
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.amber.withOpacity(
                                              0.35,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'You are the Group Creator',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (!isCreator) ...[
                                    const SizedBox(height: 12),
                                    if (!isJoined)
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed:
                                              (isFull ||
                                                  (isPrivate && !isCreator))
                                              ? null
                                              : () async {
                                                  await provider.joinGroup(
                                                    widget.groupId,
                                                  );
                                                  if (context.mounted) {
                                                    final msg = provider.error;
                                                    if (msg == null) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Joined group successfully',
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Error: $msg',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          child: Text(
                                            (isPrivate && !isCreator)
                                                ? 'Invite Only'
                                                : isFull
                                                ? 'Group Full'
                                                : 'Join Group',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            await provider.leaveGroup(
                                              widget.groupId,
                                            );
                                            if (context.mounted) {
                                              final msg = provider.error;
                                              if (msg == null) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Left group'),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Error: $msg',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          child: const Text(
                                            'Leave Group',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // About
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'About This Group',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    group.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent.withOpacity(
                                            0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          group.subject,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryBrand,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Upcoming sessions
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Upcoming Sessions',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: isCreator
                                            ? () => _showAddSessionDialog(
                                                context,
                                                provider,
                                              )
                                            : () => _showRequestSessionDialog(
                                                context,
                                                provider,
                                                widget.groupId,
                                              ),
                                        icon: const Icon(Icons.add, size: 16),
                                        label: Text(
                                          isCreator
                                              ? (provider
                                                        .upcomingSessions
                                                        .isEmpty
                                                    ? 'Start Session'
                                                    : 'Add Session')
                                              : 'Request Session',
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              AppColors.primaryBrand,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (provider.upcomingSessions.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'No upcoming sessions yet.',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          if (isCreator) ...[
                                            const SizedBox(height: 10),
                                            ElevatedButton.icon(
                                              onPressed: () =>
                                                  _showAddSessionDialog(
                                                    context,
                                                    provider,
                                                  ),
                                              icon: const Icon(
                                                Icons.videocam,
                                                size: 16,
                                              ),
                                              label: const Text(
                                                'Start Session',
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primaryBrand,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    )
                                  else
                                    Column(
                                      spacing: 12,
                                      children: provider.upcomingSessions
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                            final s = entry.value;
                                            return _SessionRow(
                                              session: s,
                                              onTap: () =>
                                                  _showSessionPreviewDialog(
                                                    context,
                                                    provider,
                                                    s,
                                                    isCreator: isCreator,
                                                  ),
                                            );
                                          })
                                          .toList(),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Session requests (for creators only)
                          if (isCreator)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Session Requests',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (provider.sessionRequests
                                        .where((r) => r.status == 'pending')
                                        .isEmpty)
                                      const Text(
                                        'No pending requests',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      )
                                    else
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: provider.sessionRequests
                                            .where((r) => r.status == 'pending')
                                            .length,
                                        itemBuilder: (context, index) {
                                          final req = provider.sessionRequests
                                              .where(
                                                (r) => r.status == 'pending',
                                              )
                                              .toList()[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            child: _SessionRequestRow(
                                              request: req,
                                              onApprove: () async {
                                                await provider
                                                    .approveSessionRequest(
                                                      req.id,
                                                      widget.groupId,
                                                    );
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Session request approved',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              onDecline: () async {
                                                await provider
                                                    .declineSessionRequest(
                                                      req.id,
                                                      widget.groupId,
                                                    );
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Session request declined',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Members
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Members (${provider.groupMembers.length})',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (provider.groupMembers.isEmpty)
                                    const Text(
                                      'No members yet',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    )
                                  else
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: provider.groupMembers.length,
                                      itemBuilder: (context, index) {
                                        final member =
                                            provider.groupMembers[index];
                                        final isYou =
                                            member.userId == currentUserId;
                                        final isMemberCreator =
                                            member.userId == group.createdBy;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: _MemberRow(
                                            member: member,
                                            isYou: isYou,
                                            isCreator: isMemberCreator,
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    StudyGroupProvider provider,
    dynamic group,
  ) {
    final minAllowedMembers = group.currentMembers > 2
        ? group.currentMembers as int
        : 2;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: group.name);
    final descriptionController = TextEditingController(
      text: group.description,
    );
    final maxMembersController = TextEditingController(
      text: group.maxMembers.toString(),
    );

    showGeneralDialog(
      context: context,
      barrierLabel: 'Edit Group',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      pageBuilder: (dialogContext, _, _) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            final isSaving = provider.isLoading;
            return Stack(
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(color: const Color(0x33000000)),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
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
                                  controller: nameController,
                                  decoration: _dialogInputDecoration(),
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
                                  controller: descriptionController,
                                  maxLines: 4,
                                  minLines: 4,
                                  decoration: _dialogInputDecoration(),
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
                                  controller: maxMembersController,
                                  keyboardType: TextInputType.number,
                                  decoration: _dialogInputDecoration(),
                                  validator: (value) {
                                    final trimmed = value?.trim() ?? '';
                                    if (trimmed.isEmpty) {
                                      return 'Please enter member limit';
                                    }
                                    final parsed = int.tryParse(trimmed);
                                    if (parsed == null) {
                                      return 'Please enter a valid number';
                                    }
                                    if (parsed < minAllowedMembers) {
                                      if (group.currentMembers > 2) {
                                        return 'Member limit cannot be below joined members (${group.currentMembers})';
                                      }
                                      return 'Member limit must be at least 2';
                                    }
                                    if (parsed > 50) {
                                      return 'Member limit must be 50 or less';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Minimum allowed now: $minAllowedMembers',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: isSaving
                                            ? null
                                            : () =>
                                                  Navigator.pop(dialogContext),
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
                                        onPressed: isSaving
                                            ? null
                                            : () async {
                                                if (!formKey.currentState!
                                                    .validate()) {
                                                  return;
                                                }

                                                await provider.updateGroup(
                                                  widget.groupId,
                                                  name: nameController.text
                                                      .trim(),
                                                  subject: group.subject,
                                                  description:
                                                      descriptionController.text
                                                          .trim(),
                                                  maxMembers: int.parse(
                                                    maxMembersController.text
                                                        .trim(),
                                                  ),
                                                );

                                                if (!context.mounted) return;

                                                if (provider.error == null) {
                                                  Navigator.pop(dialogContext);
                                                  await provider.fetchGroupById(
                                                    widget.groupId,
                                                  );
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Group updated successfully',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  setState(() {});
                                                  if (context.mounted) {
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
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryBrand,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                        ),
                                        child: isSaving
                                            ? const SizedBox(
                                                height: 18,
                                                width: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
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
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      nameController.dispose();
      descriptionController.dispose();
      maxMembersController.dispose();
    });
  }

  void _showAddSessionDialog(
    BuildContext context,
    StudyGroupProvider provider,
  ) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final durationController = TextEditingController(text: '60');
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showGeneralDialog(
      context: context,
      barrierLabel: 'Add Session',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      pageBuilder: (dialogContext, _, _) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            final isSaving = provider.isLoading;
            return Stack(
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(color: const Color(0x33000000)),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Add Session',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Session Title',
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: titleController,
                                  decoration: _dialogInputDecoration(),
                                  validator: (value) {
                                    final trimmed = value?.trim() ?? '';
                                    if (trimmed.isEmpty) {
                                      return 'Please enter session title';
                                    }
                                    if (trimmed.length < 3) {
                                      return 'Session title must be at least 3 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Date',
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: isSaving
                                      ? null
                                      : () async {
                                          final picked = await showDatePicker(
                                            context: dialogContext,
                                            initialDate: selectedDate,
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime.now().add(
                                              const Duration(days: 365),
                                            ),
                                          );
                                          if (picked != null) {
                                            setState(
                                              () => selectedDate = picked,
                                            );
                                          }
                                        },
                                  child: InputDecorator(
                                    decoration: _dialogInputDecoration(),
                                    child: Text(
                                      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Duration (minutes)',
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: durationController,
                                  keyboardType: TextInputType.number,
                                  decoration: _dialogInputDecoration(),
                                  validator: (value) {
                                    final trimmed = value?.trim() ?? '';
                                    if (trimmed.isEmpty) {
                                      return 'Please enter duration';
                                    }
                                    final parsed = int.tryParse(trimmed);
                                    if (parsed == null) {
                                      return 'Please enter a valid number';
                                    }
                                    if (parsed < 15 || parsed > 240) {
                                      return 'Duration must be between 15 and 240 minutes';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: isSaving
                                            ? null
                                            : () =>
                                                  Navigator.pop(dialogContext),
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
                                        onPressed: isSaving
                                            ? null
                                            : () async {
                                                if (!formKey.currentState!
                                                    .validate()) {
                                                  return;
                                                }

                                                final scheduledAt = DateTime(
                                                  selectedDate.year,
                                                  selectedDate.month,
                                                  selectedDate.day,
                                                  18,
                                                  0,
                                                );

                                                await provider.addSession(
                                                  widget.groupId,
                                                  title: titleController.text
                                                      .trim(),
                                                  scheduledAt: scheduledAt,
                                                  durationMinutes: int.parse(
                                                    durationController.text
                                                        .trim(),
                                                  ),
                                                );

                                                if (!context.mounted) return;

                                                if (provider.error == null) {
                                                  Navigator.pop(dialogContext);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Session added successfully',
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  setState(() {});
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
                                          backgroundColor:
                                              AppColors.primaryBrand,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                        ),
                                        child: isSaving
                                            ? const SizedBox(
                                                height: 18,
                                                width: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                            : const Text('Save Session'),
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
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      titleController.dispose();
      durationController.dispose();
    });
  }

  void _showSessionPreviewDialog(
    BuildContext context,
    StudyGroupProvider provider,
    dynamic session, {
    required bool isCreator,
  }) {
    final scheduledAt = session.scheduledAt as DateTime;
    final durationMinutes = session.durationMinutes as int;
    final endsAt = scheduledAt.add(Duration(minutes: durationMinutes));
    final now = DateTime.now();
    final isHappening = now.isAfter(scheduledAt) && now.isBefore(endsAt);

    String formatDuration(int minutes) {
      final hours = minutes ~/ 60;
      final rem = minutes % 60;
      if (hours == 0) return '${minutes}min';
      if (rem == 0) return '${hours}h';
      return '${hours}h ${rem}min';
    }

    String weekdayShort(DateTime dt) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final idx = dt.weekday - 1;
      if (idx < 0 || idx >= days.length) return '';
      return days[idx];
    }

    String monthShort(int month) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      if (month < 1 || month > 12) return '';
      return months[month - 1];
    }

    Widget actionButton({
      required String label,
      required IconData icon,
      required bool primary,
      required VoidCallback? onTap,
      Color? color,
    }) {
      final borderColor = color ?? AppColors.border;
      return Expanded(
        child: SizedBox(
          height: 42,
          child: primary
              ? ElevatedButton.icon(
                  onPressed: onTap,
                  icon: Icon(icon, size: 14),
                  label: Text(label),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color ?? AppColors.primaryBrand,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: onTap,
                  icon: Icon(icon, size: 14),
                  label: Text(label),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderColor),
                    foregroundColor: color ?? AppColors.textPrimary,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
      );
    }

    showGeneralDialog(
      context: context,
      barrierLabel: 'Session details',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      pageBuilder: (dialogContext, _, _) {
        return Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(color: const Color(0x33000000)),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: (MediaQuery.of(dialogContext).size.width - 40)
                        .clamp(0, isHappening ? 560 : 620),
                  ),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: isHappening
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBrand,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${scheduledAt.day}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            monthShort(scheduledAt.month),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'LIVE TODAY',
                                            style: TextStyle(
                                              color: Colors.green.shade600,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            weekdayShort(
                                              scheduledAt,
                                            ).toUpperCase(),
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            session.title as String,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${monthShort(scheduledAt.month)} ${scheduledAt.day}, ${scheduledAt.year}',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      icon: const Icon(Icons.close, size: 18),
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _InfoChip(
                                      label: formatDuration(durationMinutes),
                                      icon: Icons.schedule,
                                    ),
                                    _InfoChip(
                                      label: weekdayShort(scheduledAt),
                                      icon: Icons.calendar_today,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    actionButton(
                                      label: isCreator
                                          ? 'Start Session'
                                          : 'Join Session',
                                      icon: Icons.videocam,
                                      primary: true,
                                      onTap: () {
                                        Navigator.pop(dialogContext);
                                        _openLiveSessionRoom(
                                          context,
                                          provider,
                                          session,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    actionButton(
                                      label: 'Remind me',
                                      icon: Icons.alarm,
                                      primary: false,
                                      onTap: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Reminder added'),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    actionButton(
                                      label: 'Share',
                                      icon: Icons.share,
                                      primary: false,
                                      onTap: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Share link copied'),
                                          ),
                                        );
                                      },
                                    ),
                                    if (isCreator) ...[
                                      const SizedBox(width: 8),
                                      actionButton(
                                        label: 'Edit',
                                        icon: Icons.edit_outlined,
                                        primary: false,
                                        onTap: () {
                                          Navigator.pop(dialogContext);
                                          _showEditSessionDialog(
                                            context,
                                            provider,
                                            session,
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      actionButton(
                                        label: 'Delete',
                                        icon: Icons.delete_outline,
                                        primary: false,
                                        color: Colors.red.shade400,
                                        onTap: () {
                                          Navigator.pop(dialogContext);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Delete session not implemented yet',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBrand,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${scheduledAt.day}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            monthShort(scheduledAt.month),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            weekdayShort(
                                              scheduledAt,
                                            ).toUpperCase(),
                                            style: TextStyle(
                                              color: Colors.green.shade600,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            session.title as String,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${monthShort(scheduledAt.month)} ${scheduledAt.day}, ${scheduledAt.year}',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      icon: const Icon(Icons.close, size: 18),
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _InfoChip(
                                      label: formatDuration(durationMinutes),
                                      icon: Icons.schedule,
                                    ),
                                    const _InfoChip(
                                      label: 'Library Room B2',
                                      icon: Icons.location_on_outlined,
                                      highlighted: true,
                                    ),
                                    _InfoChip(
                                      label: weekdayShort(scheduledAt),
                                      icon: Icons.calendar_today,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Session Notes',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Bring your practice sheets. We will work through ${session.title.toString().toLowerCase()} with examples and Q&A.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Agenda',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                const _AgendaItem(
                                  number: 1,
                                  text: 'Quick concept recap',
                                ),
                                const SizedBox(height: 6),
                                const _AgendaItem(
                                  number: 2,
                                  text: 'Guided problem solving',
                                ),
                                const SizedBox(height: 6),
                                const _AgendaItem(
                                  number: 3,
                                  text: 'Collaborative exercises',
                                ),
                                const SizedBox(height: 6),
                                const _AgendaItem(
                                  number: 4,
                                  text: 'Q&A + next steps',
                                ),
                                const SizedBox(height: 16),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        height: 42,
                                        child: actionButton(
                                          label: isCreator
                                              ? 'Start Session'
                                              : 'Not Live Yet',
                                          icon: isCreator
                                              ? Icons.videocam
                                              : Icons.videocam_off,
                                          primary: isCreator,
                                          onTap: isCreator
                                              ? () {
                                                  Navigator.pop(dialogContext);
                                                  _openLiveSessionRoom(
                                                    context,
                                                    provider,
                                                    session,
                                                  );
                                                }
                                              : null,
                                          color: isCreator ? null : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 110,
                                        height: 42,
                                        child: actionButton(
                                          label: 'Remind me',
                                          icon: Icons.alarm,
                                          primary: false,
                                          onTap: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text('Reminder added'),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 100,
                                        height: 42,
                                        child: actionButton(
                                          label: 'Share',
                                          icon: Icons.share,
                                          primary: false,
                                          onTap: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Share link copied',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      if (isCreator) ...[
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 90,
                                          height: 42,
                                          child: actionButton(
                                            label: 'Edit',
                                            icon: Icons.edit_outlined,
                                            primary: false,
                                            onTap: () {
                                              Navigator.pop(dialogContext);
                                              _showEditSessionDialog(
                                                context,
                                                provider,
                                                session,
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 100,
                                          height: 42,
                                          child: actionButton(
                                            label: 'Delete',
                                            icon: Icons.delete_outline,
                                            primary: false,
                                            color: Colors.red.shade400,
                                            onTap: () {
                                              Navigator.pop(dialogContext);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Delete session not implemented yet',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditSessionDialog(
    BuildContext context,
    StudyGroupProvider provider,
    dynamic session,
  ) {
    final titleController = TextEditingController(
      text: session.title.toString(),
    );
    final durationController = TextEditingController(
      text: '${session.durationMinutes}',
    );
    DateTime selectedDate = session.scheduledAt as DateTime;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Edit Session'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Session Title'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: _dialogInputDecoration(),
                    ),
                    const SizedBox(height: 12),
                    const Text('Date'),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked == null) return;
                        setLocalState(() => selectedDate = picked);
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('Duration (minutes)'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: _dialogInputDecoration(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final duration = int.tryParse(
                      durationController.text.trim(),
                    );
                    if (title.isEmpty || duration == null || duration <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a valid title and duration',
                          ),
                        ),
                      );
                      return;
                    }

                    final original = session.scheduledAt as DateTime;
                    final scheduledAt = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      original.hour,
                      original.minute,
                    );

                    await provider.updateSession(
                      widget.groupId,
                      session.id as int,
                      title: title,
                      scheduledAt: scheduledAt,
                      durationMinutes: duration,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(dialogContext);

                    if (provider.error == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Session updated successfully'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${provider.error}')),
                      );
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      titleController.dispose();
      durationController.dispose();
    });
  }

  InputDecoration _dialogInputDecoration() {
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

  void _showDeleteConfirmation(BuildContext context, dynamic provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text(
          'Are you sure you want to delete this group? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteGroup(widget.groupId);
              if (!context.mounted) return;
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return to list
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openLiveSessionRoom(
    BuildContext context,
    StudyGroupProvider provider,
    dynamic session,
  ) {
    final group = provider.selectedGroup;
    if (group == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveSessionRoomPage(
          groupName: group.name,
          subject: group.subject,
          joinedCount: group.currentMembers,
          sessionTitle: session.title.toString(),
        ),
      ),
    );
  }
}

class _GroupHeroHeader extends StatelessWidget {
  final String coverImageUrl;
  final String title;
  final String subject;
  final String creatorName;
  final String creatorAvatarUrl;
  final int currentMembers;
  final int maxMembers;
  final bool isCreator;
  final VoidCallback onBack;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _GroupHeroHeader({
    required this.coverImageUrl,
    required this.title,
    required this.subject,
    required this.creatorName,
    required this.creatorAvatarUrl,
    required this.currentMembers,
    required this.maxMembers,
    required this.isCreator,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              coverImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, _, _) =>
                  Container(color: AppColors.cardBackground),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black45,
                    Color.fromARGB(150, 0, 0, 0),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Back',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.18),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        if (onEdit != null)
                          TextButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Edit',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.18),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        if (onDelete != null)
                          TextButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(
                              Icons.delete,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.7),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    subject,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.lightGreenAccent.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            backgroundImage: creatorAvatarUrl.isEmpty
                                ? null
                                : NetworkImage(creatorAvatarUrl),
                            child: creatorAvatarUrl.isEmpty
                                ? Text(
                                    creatorName.isNotEmpty
                                        ? creatorName[0]
                                        : '?',
                                  )
                                : null,
                          ),
                          Text(
                            'Created by $creatorName',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isCreator)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "You're the Creator",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF5A3B00),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$currentMembers/$maxMembers',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'members',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final dynamic session;
  final VoidCallback onTap;

  const _SessionRow({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheduled = session.scheduledAt as DateTime;
    final day = scheduled.day;
    final month = _monthShort(scheduled.month);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBrand,
                      ),
                    ),
                    Text(
                      month,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_weekdayShort(scheduled)} · $month ${scheduled.day}, ${scheduled.year}  •  ${session.durationMinutes} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${session.participantCount}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _monthShort(int month) {
    if (month < 1 || month > 12) return '';
    return _months[month - 1];
  }

  static String _weekdayShort(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // DateTime weekday: 1=Mon .. 7=Sun in Dart.
    final idx = dt.weekday - 1;
    if (idx < 0 || idx >= days.length) return '';
    return days[idx];
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool highlighted;

  const _InfoChip({
    required this.label,
    required this.icon,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFFEF3C7) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgendaItem extends StatelessWidget {
  final int number;
  final String text;

  const _AgendaItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xFFD1FAE5),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF047857),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SessionRequestRow extends StatelessWidget {
  final dynamic request;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  const _SessionRequestRow({
    required this.request,
    required this.onApprove,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final title = request.title as String;
    final scheduledAt = request.scheduledAt as DateTime;
    final durationMinutes = request.durationMinutes as int;
    final requesterName = request.requestedByUserName as String;
    final requesterAvatar = request.requestedByUserAvatar as String?;

    String formatDuration(int minutes) {
      final hours = minutes ~/ 60;
      final rem = minutes % 60;
      if (hours == 0) return '${minutes}m';
      if (rem == 0) return '${hours}h';
      return '${hours}h ${rem}m';
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.border,
                backgroundImage:
                    requesterAvatar == null || requesterAvatar.isEmpty
                    ? null
                    : NetworkImage(requesterAvatar),
                child: requesterAvatar == null || requesterAvatar.isEmpty
                    ? Text(requesterName.isNotEmpty ? requesterName[0] : '?')
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requesterName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Requested ${scheduledAt.toString().split(' ').first}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBrand.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${scheduledAt.year}-${scheduledAt.month.toString().padLeft(2, '0')}-${scheduledAt.day.toString().padLeft(2, '0')} @ ${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.timer, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      formatDuration(durationMinutes),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text(
                    'Decline',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Approve', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _showRequestSessionDialog(
  BuildContext dialogContext,
  StudyGroupProvider provider,
  int groupId,
) {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final durationController = TextEditingController(text: '60');
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

  showGeneralDialog(
    context: dialogContext,
    barrierLabel: 'Request Session',
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    pageBuilder: (context, _, _) {
      return StatefulBuilder(
        builder: (context, setState) {
          final isSaving = provider.isLoading;
          return Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: const Color(0x33000000)),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Request Session',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Session Title',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: titleController,
                                decoration: _dialogInputDecoration(),
                                validator: (value) {
                                  final trimmed = value?.trim() ?? '';
                                  if (trimmed.isEmpty) {
                                    return 'Please enter session title';
                                  }
                                  if (trimmed.length < 3) {
                                    return 'Session title must be at least 3 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Date',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: isSaving
                                    ? null
                                    : () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: selectedDate,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now().add(
                                            const Duration(days: 365),
                                          ),
                                        );
                                        if (picked != null) {
                                          setState(() => selectedDate = picked);
                                        }
                                      },
                                child: InputDecorator(
                                  decoration: _dialogInputDecoration(),
                                  child: Text(
                                    '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Duration (minutes)',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: durationController,
                                keyboardType: TextInputType.number,
                                decoration: _dialogInputDecoration(),
                                validator: (value) {
                                  final trimmed = value?.trim() ?? '';
                                  if (trimmed.isEmpty) {
                                    return 'Please enter duration';
                                  }
                                  final parsed = int.tryParse(trimmed);
                                  if (parsed == null) {
                                    return 'Please enter a valid number';
                                  }
                                  if (parsed < 15 || parsed > 240) {
                                    return 'Duration must be between 15 and 240 minutes';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: isSaving
                                          ? null
                                          : () => Navigator.pop(context),
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
                                      onPressed: isSaving
                                          ? null
                                          : () async {
                                              if (!formKey.currentState!
                                                  .validate()) {
                                                return;
                                              }

                                              final scheduledAt = DateTime(
                                                selectedDate.year,
                                                selectedDate.month,
                                                selectedDate.day,
                                                18,
                                                0,
                                              );

                                              await provider.requestSession(
                                                groupId,
                                                title: titleController.text
                                                    .trim(),
                                                scheduledAt: scheduledAt,
                                                durationMinutes: int.parse(
                                                  durationController.text
                                                      .trim(),
                                                ),
                                              );

                                              if (!dialogContext.mounted) {
                                                return;
                                              }

                                              if (provider.error == null) {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(
                                                  dialogContext,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Session request sent to group creator',
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                setState(() {});
                                                ScaffoldMessenger.of(
                                                  dialogContext,
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
                                      child: isSaving
                                          ? const SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : const Text('Send Request'),
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
              ),
            ],
          );
        },
      );
    },
  ).then((_) {
    titleController.dispose();
    durationController.dispose();
  });
}

InputDecoration _dialogInputDecoration() {
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
  );
}

class _MemberRow extends StatelessWidget {
  final dynamic member;
  final bool isYou;
  final bool isCreator;

  const _MemberRow({
    required this.member,
    required this.isYou,
    required this.isCreator,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = member.avatarUrl as String?;
    final name = member.userName as String;
    final joinedAt = member.joinedAt as DateTime;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.border,
                backgroundImage: avatar == null || avatar.isEmpty
                    ? null
                    : NetworkImage(avatar),
                child: avatar == null || avatar.isEmpty
                    ? Text(name.isNotEmpty ? name[0] : '?')
                    : null,
              ),
              if (isCreator)
                Positioned(
                  right: -8,
                  bottom: -6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.95),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Joined ${joinedAt.toString().split(' ').first}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isYou)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBrand.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'You',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F766E),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
