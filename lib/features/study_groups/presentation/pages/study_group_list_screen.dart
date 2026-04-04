import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibuddy/features/study_groups/presentation/widgets/study_group_app_bar.dart';
import 'package:unibuddy/features/study_groups/presentation/widgets/study_group_search_bar.dart';
import 'package:unibuddy/features/study_groups/presentation/widgets/study_group_filters.dart';
import 'package:unibuddy/features/study_groups/presentation/widgets/study_group_grid.dart';
import 'package:unibuddy/features/study_groups/presentation/pages/create_study_group_screen.dart';
import 'package:unibuddy/features/study_groups/presentation/pages/study_group_detail_screen.dart';
import 'package:unibuddy/core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_app_background.dart';
import '../state/study_group_provider.dart';
import '../../data/models/study_group.dart';

class StudyGroupListScreen extends StatefulWidget {
  const StudyGroupListScreen({super.key});

  @override
  State<StudyGroupListScreen> createState() => _StudyGroupListScreenState();
}

class _StudyGroupListScreenState extends State<StudyGroupListScreen> {
  String _query = '';
  bool _availableOnly = false;
  String _selectedSubject = 'All Subjects';
  bool _mineOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StudyGroupProvider>();
      provider.fetchAllGroups();
      // Fetch session requests for created groups
      for (final group in provider.groups.where((g) => g.isCreator)) {
        provider.fetchSessionRequests(group.id);
      }
    });
  }

  bool _matchesSearch(StudyGroup g, String q) {
    if (q.trim().isEmpty) return true;
    final query = q.trim().toLowerCase();
    return g.name.toLowerCase().contains(query) ||
        g.subject.toLowerCase().contains(query) ||
        g.description.toLowerCase().contains(query);
  }

  List<StudyGroup> _filterGroups(List<StudyGroup> groups) {
    var filtered = groups;
    if (_mineOnly) {
      filtered = filtered.where((g) => g.isJoined).toList();
    }
    if (_selectedSubject != 'All Subjects') {
      filtered = filtered.where((g) => g.subject == _selectedSubject).toList();
    }
    if (_availableOnly) {
      filtered = filtered
          .where((g) => g.currentMembers < g.maxMembers)
          .toList();
    }
    filtered = filtered.where((g) => _matchesSearch(g, _query)).toList();
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyGroupProvider>(
      builder: (context, provider, _) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final heroTitleSize = (screenWidth * 0.021).clamp(28.0, 42.0);
        final heroSubtitleSize = (screenWidth * 0.009).clamp(14.0, 24.0);
        final heroHorizontalPadding = screenWidth < 900 ? 20.0 : 48.0;

        final allGroups = provider.groups;
        final filteredGroups = _filterGroups(allGroups);

        final sessionsScheduled = allGroups.fold<int>(
          0,
          (sum, g) => sum + g.upcomingSessionsCount,
        );
        final groupsJoined = allGroups.where((g) => g.isJoined).length;

        // Calculate notification count - ONLY count actual pending requests
        // Don't count session reminders since we don't have access to actual sessions here
        int pendingRequests = provider.sessionRequests
            .where((r) => r.status == 'pending')
            .length;
        final notificationCount = pendingRequests;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: StudyGroupAppBar(
            isMyGroupsSelected: _mineOnly,
            onStudyGroups: () => setState(() => _mineOnly = false),
            onMyGroups: () => setState(() => _mineOnly = true),
            onCreateGroup: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateStudyGroupScreen(),
                ),
              );
              if (result != null && context.mounted) {
                provider.fetchAllGroups();
              }
            },
            notificationCount: notificationCount,
            onNotificationsPressed: () =>
                _showNotificationsDialog(context, provider, allGroups),
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
              provider.isLoading && allGroups.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: screenWidth < 900 ? 240 : 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.68),
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.border.withValues(
                                    alpha: 0.75,
                                  ),
                                ),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: -80,
                                  top: -40,
                                  child: Container(
                                    width: 360,
                                    height: 300,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F2E9),
                                      borderRadius: BorderRadius.circular(180),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -110,
                                  top: -30,
                                  child: Container(
                                    width: 470,
                                    height: 310,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE9F4F2),
                                      borderRadius: BorderRadius.circular(220),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: heroHorizontalPadding,
                                    vertical: 30,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 7,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Collaborative Learning Starts Here',
                                              style: TextStyle(
                                                fontSize: heroTitleSize,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0A1633),
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'Find your study tribe, collaborate, and ace your courses together.',
                                              style: TextStyle(
                                                fontSize: heroSubtitleSize,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (screenWidth < 900)
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _TopStat(
                                                value: '${allGroups.length}',
                                                label: 'Active Groups',
                                                valueColor:
                                                    AppColors.primaryBrand,
                                                compact: true,
                                              ),
                                              const SizedBox(height: 12),
                                              _TopStat(
                                                value: '$sessionsScheduled',
                                                label: 'Sessions',
                                                valueColor: AppColors.warning,
                                                compact: true,
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Expanded(
                                          flex: 4,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 8,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                _TopStat(
                                                  value: '${allGroups.length}',
                                                  label: 'Active Groups',
                                                  valueColor:
                                                      AppColors.primaryBrand,
                                                  compact: false,
                                                ),
                                                _StatDivider(compact: false),
                                                _TopStat(
                                                  value: '$sessionsScheduled',
                                                  label: 'Sessions Scheduled',
                                                  valueColor: AppColors.warning,
                                                  compact: false,
                                                ),
                                                _StatDivider(compact: false),
                                                _TopStat(
                                                  value: '$groupsJoined',
                                                  label: 'Groups Joined',
                                                  valueColor:
                                                      AppColors.primaryBrand,
                                                  compact: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            color: Colors.white.withValues(alpha: 0.5),
                            padding: EdgeInsets.fromLTRB(
                              heroHorizontalPadding,
                              24,
                              heroHorizontalPadding,
                              24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StudyGroupSearchBar(
                                  query: _query,
                                  availableOnly: _availableOnly,
                                  onQueryChanged: (value) =>
                                      setState(() => _query = value),
                                  onAvailableOnlyChanged: (value) =>
                                      setState(() => _availableOnly = value),
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 1380,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        StudyGroupFilters(
                                          selectedFilter: _selectedSubject,
                                          onSelectedFilter: (value) => setState(
                                            () => _selectedSubject = value,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        StudyGroupGrid(
                                          groups: filteredGroups,
                                          onTapGroup: (g) async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    StudyGroupDetailScreen(
                                                      groupId: g.id,
                                                    ),
                                              ),
                                            );
                                            if (result != null &&
                                                context.mounted) {
                                              provider.fetchAllGroups();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationsDialog(
    BuildContext context,
    StudyGroupProvider provider,
    List<StudyGroup> allGroups,
  ) {
    final pendingRequests = provider.sessionRequests
        .where((r) => r.status == 'pending')
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (pendingRequests.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No pending session requests',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else ...[
                  const Text(
                    'Session Requests from Members',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...pendingRequests.map((req) {
                    final group = allGroups.firstWhere(
                      (g) => g.id == req.groupId,
                      orElse: () => allGroups.first,
                    );
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(
                                  req.requestedByUserAvatar,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      req.requestedByUserName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      group.name,
                                      style: const TextStyle(
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBrand.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  req.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${req.scheduledAt.year}-${req.scheduledAt.month.toString().padLeft(2, '0')}-${req.scheduledAt.day.toString().padLeft(2, '0')} @ ${req.scheduledAt.hour.toString().padLeft(2, '0')}:${req.scheduledAt.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      size: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${req.durationMinutes} minutes',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _TopStat extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final bool compact;

  const _TopStat({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: compact ? 24 : 40,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 12 : 20,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  final bool compact;

  const _StatDivider({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: compact ? 52 : 92,
      color: AppColors.border.withOpacity(0.7),
    );
  }
}
