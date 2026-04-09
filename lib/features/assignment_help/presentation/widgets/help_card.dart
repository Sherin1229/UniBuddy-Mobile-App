import 'package:flutter/material.dart';
import '../../data/models/help_request_model.dart';

class HelpCard extends StatelessWidget {
  final HelpRequest request;
  final VoidCallback onTap;

  const HelpCard({
    required this.request,
    required this.onTap,
    super.key,
  });

  Color _getStatusColor(HelpRequestStatus status) {
    switch (status) {
      case HelpRequestStatus.overdue:
        return const Color(0xFFDC2626); // Red
      case HelpRequestStatus.open:
        return const Color(0xFF2563EB); // Blue
      case HelpRequestStatus.solved:
        return const Color(0xFF059669); // Green
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

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      return 'Due ${date.day} ${_getMonthName(date.month)}';
    }
  }

  String _getMonthName(int month) {
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
      'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'By ${request.ownerName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStatusText(request.status),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Subject
            Text(
              'Subject: ${request.subject}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Footer with Date and Interaction counts
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: const Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Text(
                  _formatDate(request.deadline),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 16),
                if (request.views > 0)
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 14, color: const Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text(
                        '${request.views}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                if (request.likes > 0)
                  Row(
                    children: [
                      Icon(Icons.thumb_up_alt_outlined, size: 14, color: const Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text(
                        '${request.likes}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                if (request.comments > 0)
                  Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 14, color: const Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text(
                        '${request.comments}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
