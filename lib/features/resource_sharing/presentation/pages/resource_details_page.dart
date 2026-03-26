import 'package:flutter/material.dart';

import '../../data/models/resource_model.dart';
import '../../../../shared/widgets/animated_app_background.dart';

const _teal = Color(0xFF3D9E8C);

class ResourceDetailsPage extends StatefulWidget {
  final ResourceModel resource;

  const ResourceDetailsPage({super.key, required this.resource});

  @override
  State<ResourceDetailsPage> createState() => _ResourceDetailsPageState();
}

class _ResourceDetailsPageState extends State<ResourceDetailsPage> {
  int _likes = 0;
  int _dislikes = 0;
  bool _liked = false;
  bool _disliked = false;

  ResourceModel get resource => widget.resource;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  void _toggleLike() {
    setState(() {
      if (_liked) {
        _liked = false;
        _likes = (_likes - 1).clamp(0, 9999);
      } else {
        _liked = true;
        _likes += 1;
        if (_disliked) {
          _disliked = false;
          _dislikes = (_dislikes - 1).clamp(0, 9999);
        }
      }
    });
  }

  void _toggleDislike() {
    setState(() {
      if (_disliked) {
        _disliked = false;
        _dislikes = (_dislikes - 1).clamp(0, 9999);
      } else {
        _disliked = true;
        _dislikes += 1;
        if (_liked) {
          _liked = false;
          _likes = (_likes - 1).clamp(0, 9999);
        }
      }
    });
  }

  void _downloadMock() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Download started (demo).')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        title: const Text('Resource Details'),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedAppBackground()),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
            children: [
              Card(
                elevation: 8,
                color: Colors.white.withOpacity(0.92),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _teal.withOpacity(0.14),
                              const Color(0xFF14B8A6).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: _teal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                resource.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _infoChip(Icons.school_outlined, resource.subject),
                          _infoChip(Icons.category_outlined, resource.category),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _detailRow(
                        icon: Icons.person_outline,
                        label: 'Uploaded by',
                        value: resource.uploadedBy,
                      ),
                      const SizedBox(height: 10),
                      _detailRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'Uploaded date',
                        value: _formatDate(resource.uploadedAt),
                      ),
                      const SizedBox(height: 10),
                      _detailRow(
                        icon: Icons.file_present_outlined,
                        label: 'File',
                        value:
                            '${resource.fileType} • ${resource.fileSizeKb} KB',
                      ),
                      const SizedBox(height: 10),
                      _detailRow(
                        icon: Icons.download_rounded,
                        label: 'Downloads',
                        value: '${resource.downloads}',
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        resource.description,
                        style: const TextStyle(height: 1.45),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _toggleLike,
                              icon: Icon(
                                _liked
                                    ? Icons.thumb_up_alt
                                    : Icons.thumb_up_alt_outlined,
                              ),
                              label: Text('Like ($_likes)'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _liked
                                    ? const Color(0xFF15803D)
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _toggleDislike,
                              icon: Icon(
                                _disliked
                                    ? Icons.thumb_down_alt
                                    : Icons.thumb_down_alt_outlined,
                              ),
                              label: Text('Dislike ($_dislikes)'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _disliked
                                    ? const Color(0xFFB91C1C)
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'File: ${resource.fileType} • ${resource.fileSizeKb} KB',
                style: TextStyle(color: Colors.blueGrey.shade700),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _downloadMock,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _teal),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: _teal, size: 18),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value)),
      ],
    );
  }
}
