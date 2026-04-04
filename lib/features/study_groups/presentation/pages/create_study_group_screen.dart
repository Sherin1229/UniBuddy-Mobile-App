import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibuddy/core/theme/app_colors.dart';
import 'package:unibuddy/features/study_groups/presentation/widgets/study_group_app_bar.dart';
import '../../../../shared/widgets/animated_app_background.dart';
import '../state/study_group_provider.dart';
import '../../data/models/study_session_draft.dart';

class CreateStudyGroupScreen extends StatefulWidget {
  const CreateStudyGroupScreen({super.key});

  @override
  State<CreateStudyGroupScreen> createState() => _CreateStudyGroupScreenState();
}

class _CreateStudyGroupScreenState extends State<CreateStudyGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _memberLimitController;
  late final TextEditingController _sessionTitleController;
  late final TextEditingController _sessionDateController;

  final List<String> _subjects = const [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'Data Structures',
    'Algorithms',
    'Machine Learning',
    'Statistics',
    'Economics',
    'History',
    'Literature',
    'Engineering',
    'Psychology',
    'Philosophy',
  ];

  String _selectedSubject = 'Mathematics';
  bool _isPrivate = false;

  DateTime? _sessionDate;
  int _sessionDurationMinutes = 60;
  final List<StudySessionDraft> _scheduledSessions = [];
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _memberLimitController = TextEditingController(text: '10');
    _sessionTitleController = TextEditingController();
    _sessionDateController = TextEditingController(text: '');

    _nameController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
    _memberLimitController.addListener(_onFormChanged);
    _sessionTitleController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _memberLimitController.dispose();
    _sessionTitleController.dispose();
    _sessionDateController.dispose();
    super.dispose();
  }

  int _memberLimitValue() {
    final parsed = int.tryParse(_memberLimitController.text.trim());
    if (parsed == null) return 0;
    return parsed;
  }

  String _formatDate(DateTime dt) {
    // Keep it simple: YYYY-MM-DD
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  bool get _canAddSession {
    final title = _sessionTitleController.text.trim();
    return title.isNotEmpty &&
        _sessionDate != null &&
        _sessionDurationMinutes > 0;
  }

  Future<void> _pickSessionDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _sessionDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      _sessionDate = picked;
      _sessionDateController.text = _formatDate(picked);
    });
  }

  Widget _requiredLabel(String text) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        children: [
          TextSpan(text: text),
          const TextSpan(text: ' '),
          const TextSpan(
            text: '*',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memberLimit = _memberLimitValue();
    final spotsLeft = memberLimit > 0 ? (memberLimit - 1) : 0;
    final progress = memberLimit > 0 ? (1 / memberLimit).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: StudyGroupAppBar(
        isMyGroupsSelected: false,
        onStudyGroups: () => Navigator.pop(context),
        onMyGroups: () => Navigator.pop(context),
        onCreateGroup: () {},
        onProfilePressed: () {},
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedAppBackground(
              durationSeconds: 28,
              motionScale: 0.55,
              opacityScale: 0.85,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 900;

                    Widget leftColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back + header (mirrors the HTML)
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text(
                            'Back to Study Groups',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create a New Study Group',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Set up your group and invite students to collaborate.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Basic Information
                              Card(
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Basic Information',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textSecondary,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                      const SizedBox(height: 14),

                                      // Group Name
                                      _requiredLabel('Group Name'),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _nameController,
                                        maxLength: 80,
                                        decoration: InputDecoration(
                                          hintText:
                                              'e.g. Advanced Calculus Study Circle',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
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
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const SizedBox(width: 10),
                                          Text(
                                            '${_nameController.text.length}/80',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 14),

                                      // Description
                                      _requiredLabel('Description'),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _descriptionController,
                                        maxLength: 500,
                                        maxLines: 4,
                                        decoration: InputDecoration(
                                          hintText:
                                              'What is this group about? What will you study together?',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
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
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const SizedBox(width: 10),
                                          Text(
                                            '${_descriptionController.text.length}/500',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 16),

                                      // Subject + Member Limit
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                right: 10,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Subject Area',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  DropdownButtonFormField<
                                                    String
                                                  >(
                                                    initialValue:
                                                        _selectedSubject,
                                                    items: _subjects
                                                        .map(
                                                          (s) =>
                                                              DropdownMenuItem(
                                                                value: s,
                                                                child: Text(s),
                                                              ),
                                                        )
                                                        .toList(),
                                                    onChanged: (v) {
                                                      if (v == null) return;
                                                      setState(
                                                        () => _selectedSubject =
                                                            v,
                                                      );
                                                    },
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please select a subject';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Member Limit',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                TextFormField(
                                                  controller:
                                                      _memberLimitController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    final v = int.tryParse(
                                                      (value ?? '').trim(),
                                                    );
                                                    if (v == null) {
                                                      return 'Please enter member limit';
                                                    }
                                                    if (v < 2 || v > 50) {
                                                      return 'Member limit must be between 2 and 50';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 14),

                                      // Private Group toggle row
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Private Group',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                const Text(
                                                  'Only invited students can join',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Switch(
                                              value: _isPrivate,
                                              onChanged: (v) => setState(
                                                () => _isPrivate = v,
                                              ),
                                              activeThumbColor:
                                                  AppColors.primaryBrand,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Schedule Study Sessions
                              Card(
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Schedule Study Sessions',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textSecondary,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                      const SizedBox(height: 14),

                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                right: 10,
                                              ),
                                              child: TextFormField(
                                                controller:
                                                    _sessionTitleController,
                                                decoration: InputDecoration(
                                                  hintText: 'Session title...',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                right: 10,
                                              ),
                                              child: TextFormField(
                                                readOnly: true,
                                                controller:
                                                    _sessionDateController,
                                                onTap: _pickSessionDate,
                                                decoration: InputDecoration(
                                                  hintText: 'Date',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                right: 10,
                                              ),
                                              child: DropdownButtonFormField<int>(
                                                initialValue:
                                                    _sessionDurationMinutes,
                                                items:
                                                    const [
                                                          30,
                                                          60,
                                                          90,
                                                          120,
                                                          150,
                                                          180,
                                                        ]
                                                        .map(
                                                          (
                                                            d,
                                                          ) => DropdownMenuItem(
                                                            value: d,
                                                            child: Text(
                                                              d == 120
                                                                  ? '2 hrs'
                                                                  : d == 150
                                                                  ? '2.5 hrs'
                                                                  : d == 180
                                                                  ? '3 hrs'
                                                                  : '$d min',
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                onChanged: (v) {
                                                  if (v == null) return;
                                                  setState(
                                                    () =>
                                                        _sessionDurationMinutes =
                                                            v,
                                                  );
                                                },
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: ElevatedButton(
                                              onPressed: _canAddSession
                                                  ? () {
                                                      final title =
                                                          _sessionTitleController
                                                              .text
                                                              .trim();
                                                      if (title.isEmpty ||
                                                          _sessionDate == null) {
                                                        return;
                                                      }

                                                      final scheduledAt =
                                                          DateTime(
                                                            _sessionDate!.year,
                                                            _sessionDate!.month,
                                                            _sessionDate!.day,
                                                            18,
                                                            0,
                                                          );

                                                      setState(() {
                                                        _scheduledSessions.add(
                                                          StudySessionDraft(
                                                            title: title,
                                                            scheduledAt:
                                                                scheduledAt,
                                                            durationMinutes:
                                                                _sessionDurationMinutes,
                                                          ),
                                                        );
                                                        _sessionTitleController
                                                            .clear();
                                                        _sessionDate = null;
                                                        _sessionDateController
                                                                .text =
                                                            '';
                                                      });
                                                    }
                                                  : null,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors
                                                    .accent
                                                    .withOpacity(0.15),
                                                foregroundColor:
                                                    AppColors.primaryBrand,
                                                disabledBackgroundColor:
                                                    AppColors.accent
                                                        .withOpacity(0.15),
                                                disabledForegroundColor:
                                                    AppColors.primaryBrand,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                '+ Add',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.border.withOpacity(
                                              0.9,
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: _scheduledSessions.isEmpty
                                            ? const Center(
                                                child: Text(
                                                  'No sessions scheduled yet. Add your first session above.',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                    ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: _scheduledSessions.map((
                                                    s,
                                                  ) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 8,
                                                          ),
                                                      child: Text(
                                                        '${s.title} • ${s.durationMinutes} min',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: AppColors
                                                              .textPrimary,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // Footer actions
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 22,
                                        vertical: 12,
                                      ),
                                      side: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Consumer<StudyGroupProvider>(
                                    builder: (context, provider, _) {
                                      return ElevatedButton.icon(
                                        onPressed:
                                            (provider.isLoading || _isCreating)
                                            ? null
                                            : () async {
                                                if (!_formKey.currentState!
                                                    .validate()) {
                                                  return;
                                                }
                                                setState(
                                                  () => _isCreating = true,
                                                );
                                                try {
                                                  await provider.createGroup(
                                                    name: _nameController.text
                                                        .trim(),
                                                    description:
                                                        _descriptionController
                                                            .text
                                                            .trim(),
                                                    subject: _selectedSubject,
                                                    maxMembers:
                                                        _memberLimitValue(),
                                                    isPrivate: _isPrivate,
                                                    sessions:
                                                        _scheduledSessions,
                                                  );
                                                } finally {
                                                  if (context.mounted) {
                                                    setState(
                                                      () => _isCreating = false,
                                                    );
                                                  }
                                                }

                                                if (!context.mounted) return;
                                                if (provider.error == null) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Group created successfully',
                                                      ),
                                                    ),
                                                  );
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
                                          backgroundColor:
                                              AppColors.primaryBrand,
                                          foregroundColor: AppColors.textOnDark,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 26,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          disabledBackgroundColor: AppColors
                                              .primaryBrand
                                              .withOpacity(0.5),
                                        ),
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          'Create Group',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    Widget rightColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 8),
                          child: Card(
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Live Preview',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textSecondary,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.18),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: Colors.amber.withOpacity(
                                              0.25,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Preview',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  Container(
                                    height: 110,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFE0F2FE),
                                          Color(0xFFECFDF5),
                                        ],
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.image,
                                        color: Color(0xFF2DD4BF),
                                        size: 44,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(
                                              0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            _selectedSubject,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primaryBrand,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _nameController.text.trim().isEmpty
                                              ? 'Group name will appear here'
                                              : _nameController.text.trim(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _descriptionController.text
                                                  .trim()
                                                  .isEmpty
                                              ? 'Description will appear here...'
                                              : _descriptionController.text
                                                    .trim(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 10),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '1/${memberLimit > 0 ? memberLimit : 0} members',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            Text(
                                              memberLimit > 0
                                                  ? '${spotsLeft < 0 ? 0 : spotsLeft} spots left'
                                                  : '0 spots left',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF0F766E),
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(
                                              0.25,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: FractionallySizedBox(
                                            widthFactor: progress,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryBrand,
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.12),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.25),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tips',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.amber.shade700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const _TipRow(
                                text: 'Keep the name short and descriptive',
                              ),
                              const SizedBox(height: 6),
                              const _TipRow(
                                text:
                                    'Smaller groups (8-12) are often more productive',
                              ),
                              const SizedBox(height: 6),
                              const _TipRow(
                                text:
                                    'Schedule sessions upfront to attract members',
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: leftColumn),
                          const SizedBox(width: 28),
                          Expanded(flex: 1, child: rightColumn),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        leftColumn,
                        const SizedBox(height: 16),
                        rightColumn,
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;

  const _TipRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lightbulb, size: 14, color: Colors.amber),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.amber.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
