import 'package:flutter/material.dart';
import '../../data/models/resource_model.dart';

const _teal = Color(0xFF3D9E8C);

class ResourceCard extends StatelessWidget {
  final ResourceModel resource;
  const ResourceCard({super.key, required this.resource});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours > 0) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: _teal.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.description_outlined, color: _teal),
        ),
        title: Text(resource.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(resource.subject, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 2),
            Text('Posted by ${resource.uploadedBy} · ${_timeAgo(resource.uploadedAt)}',
                style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
        trailing: Icon(Icons.download_outlined, color: _teal),
      ),
    );
  }
}
