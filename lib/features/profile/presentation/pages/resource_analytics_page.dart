import 'package:flutter/material.dart';
import '../../../../shared/widgets/animated_app_background.dart';

class ResourceAnalyticsPage extends StatefulWidget {
  const ResourceAnalyticsPage({super.key});

  @override
  State<ResourceAnalyticsPage> createState() => _ResourceAnalyticsPageState();
}

class _ResourceAnalyticsPageState extends State<ResourceAnalyticsPage> {
  final List<_UploadedResource> _resources = [
    _UploadedResource(
      title: 'OOP Midterm Past Paper 2023',
      subject: 'Object Oriented Programming',
      views: 312,
      downloads: 148,
      likes: 84,
      dislikes: 12,
    ),
    _UploadedResource(
      title: 'Database Normalization Cheat Sheet',
      subject: 'Database Systems',
      views: 255,
      downloads: 126,
      likes: 72,
      dislikes: 8,
    ),
    _UploadedResource(
      title: 'Networking Layer Model Summary',
      subject: 'Computer Networks',
      views: 184,
      downloads: 92,
      likes: 58,
      dislikes: 5,
    ),
    _UploadedResource(
      title: 'Flutter State Management Notes',
      subject: 'Mobile Application Development',
      views: 228,
      downloads: 109,
      likes: 91,
      dislikes: 7,
    ),
  ];

  void _onEdit(_UploadedResource resource) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit tapped for "${resource.title}"')),
    );
  }

  void _onDelete(_UploadedResource resource) {
    setState(() {
      _resources.remove(resource);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${resource.title}"'),
        backgroundColor: const Color(0xFFB91C1C),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0F766E);

    final totalUploads = _resources.length;
    final totalDownloads = _resources.fold<int>(
      0,
      (sum, resource) => sum + resource.downloads,
    );
    final totalViews = _resources.fold<int>(
      0,
      (sum, resource) => sum + resource.views,
    );
    final totalLikes = _resources.fold<int>(
      0,
      (sum, resource) => sum + resource.likes,
    );
    final totalDislikes = _resources.fold<int>(
      0,
      (sum, resource) => sum + resource.dislikes,
    );
    final totalEngagement = totalLikes + totalDislikes;
    final likesPercentage = totalEngagement > 0
        ? ((totalLikes / totalEngagement) * 100).toStringAsFixed(1)
        : '0.0';
    final dislikesPercentage = totalEngagement > 0
        ? ((totalDislikes / totalEngagement) * 100).toStringAsFixed(1)
        : '0.0';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Contributions'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedAppBackground(
              durationSeconds: 26,
              motionScale: 0.75,
              opacityScale: 0.9,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF134E4A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF115E59).withOpacity(0.22),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0x3322D3EE),
                        child: Icon(
                          Icons.insights_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Resource Impact',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Monitor how students engage with what you upload.',
                              style: TextStyle(
                                color: Color(0xFFCCFBF1),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 700;
                    final itemWidth = isWide
                        ? (constraints.maxWidth - 16) / 3
                        : (constraints.maxWidth - 12) / 2;

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          height: 180,
                          child: _analyticsCard(
                            icon: Icons.upload_file_rounded,
                            number: totalUploads.toString(),
                            label: 'Total Uploads',
                            color: const Color(0xFF0F766E),
                            backgroundColor: const Color(0xFFE6FFFB),
                            accentColor: const Color(0xFF99F6E4),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          height: 180,
                          child: _analyticsCard(
                            icon: Icons.download_rounded,
                            number: totalDownloads.toString(),
                            label: 'Total Downloads',
                            color: const Color(0xFF1E40AF),
                            backgroundColor: const Color(0xFFEFF6FF),
                            accentColor: const Color(0xFFBFDBFE),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          height: 180,
                          child: _analyticsCard(
                            icon: Icons.visibility_rounded,
                            number: totalViews.toString(),
                            label: 'Total Views',
                            color: const Color(0xFFC2410C),
                            backgroundColor: const Color(0xFFFEF3C7),
                            accentColor: const Color(0xFFFCD34D),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          height: 180,
                          child: _engagementPercentageCard(
                            likesPercentage: likesPercentage,
                            dislikesPercentage: dislikesPercentage,
                            totalLikes: totalLikes,
                            totalDislikes: totalDislikes,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                const Text(
                  'My Uploaded Resources',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF134E4A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_resources.length} resources in your library',
                  style: TextStyle(
                    color: Colors.blueGrey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                ..._resources.map(
                  (resource) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _resourceCard(resource),
                  ),
                ),
                if (_resources.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 30,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCCFBF1)),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 42,
                          color: Color(0xFF0F766E),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No uploaded resources yet.',
                          style: TextStyle(fontWeight: FontWeight.w600),
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
  }

  Widget _analyticsCard({
    required IconData icon,
    required String number,
    required String label,
    required Color color,
    required Color backgroundColor,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            radius: 20,
            child: Icon(icon, color: color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resourceCard(_UploadedResource resource) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCCFBF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resource.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            resource.subject,
            style: TextStyle(
              color: Colors.blueGrey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _statPill(
                icon: Icons.visibility_outlined,
                text: '${resource.views} views',
              ),
              const SizedBox(width: 8),
              _statPill(
                icon: Icons.download_outlined,
                text: '${resource.downloads} downloads',
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _onEdit(resource),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                color: const Color(0xFF0F766E),
              ),
              IconButton(
                onPressed: () => _onDelete(resource),
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                color: const Color(0xFFB91C1C),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statPill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0F766E)),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _engagementPercentageCard({
    required String likesPercentage,
    required String dislikesPercentage,
    required int totalLikes,
    required int totalDislikes,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFCD34D).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFCD34D).withOpacity(0.3),
            radius: 20,
            child: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFFC2410C),
              size: 22,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$likesPercentage%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF15803D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Likes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1.5,
                height: 50,
                color: const Color(0xFFD97706).withOpacity(0.25),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$dislikesPercentage%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Dislikes',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UploadedResource {
  final String title;
  final String subject;
  final int views;
  final int downloads;
  final int likes;
  final int dislikes;

  const _UploadedResource({
    required this.title,
    required this.subject,
    required this.views,
    required this.downloads,
    required this.likes,
    required this.dislikes,
  });
}
