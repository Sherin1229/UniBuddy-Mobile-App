
import 'package:flutter/material.dart';
import 'package:unibuddy/core/theme/app_colors.dart';

class StudyGroupStats extends StatelessWidget {
  final int activeGroups;
  final int sessionsScheduled;
  final int groupsJoined;

  const StudyGroupStats({
    super.key,
    required this.activeGroups,
    required this.sessionsScheduled,
    required this.groupsJoined,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(count: '$activeGroups', label: 'Active Groups'),
        _StatItem(count: '$sessionsScheduled', label: 'Sessions Scheduled'),
        _StatItem(count: '$groupsJoined', label: 'Groups Joined'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.count, required this.label});

  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBrand,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
