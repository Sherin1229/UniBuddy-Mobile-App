import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/animated_app_background.dart';
import '../../../resource_sharing/data/models/resource_model.dart';
import '../../../resource_sharing/presentation/state/resource_library_provider.dart';

class ResourceAnalyticsPage extends StatefulWidget {
  const ResourceAnalyticsPage({super.key});

  @override
  State<ResourceAnalyticsPage> createState() => _ResourceAnalyticsPageState();
}

class _ResourceAnalyticsPageState extends State<ResourceAnalyticsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final provider = context.read<ResourceLibraryProvider>();
      provider.setFilter('All');
      provider.setSearch('');
      provider.loadResources();
    });
  }

  Future<void> _onEdit(ResourceModel resource) async {
    final titleController = TextEditingController(text: resource.title);
    final subjectController = TextEditingController(text: resource.subject);
    final descriptionController = TextEditingController(
      text: resource.description,
    );
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: Color(0xFF0F766E), size: 28),
            SizedBox(width: 8),
            Text(
              'Edit Resource',
              style: TextStyle(
                color: Color(0xFF134E4A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Resource Title',
                    labelStyle: const TextStyle(color: Color(0xFF0F766E)),
                    filled: true,
                    fillColor: const Color(0xFFF0FDFA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.title,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a title'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    labelStyle: const TextStyle(color: Color(0xFF0F766E)),
                    filled: true,
                    fillColor: const Color(0xFFF0FDFA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.book,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a subject'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: const TextStyle(color: Color(0xFF0F766E)),
                    filled: true,
                    fillColor: const Color(0xFFF0FDFA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.description,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              final provider = this.context.read<ResourceLibraryProvider>();
              final result = await provider.updateResource(
                resource.copyWith(
                  title: titleController.text.trim(),
                  subject: subjectController.text.trim(),
                  description: descriptionController.text.trim(),
                ),
              );

              if (!mounted) {
                return;
              }

              if (result == null) {
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Resource updated successfully'),
                    backgroundColor: Color(0xFF0F766E),
                  ),
                );
              } else {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(result),
                    backgroundColor: const Color(0xFFB91C1C),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _onDelete(ResourceModel resource) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Resource'),
        content: Text('Delete "${resource.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final provider = context.read<ResourceLibraryProvider>();
    final result = await provider.deleteResource(resource.id);
    if (!mounted) {
      return;
    }

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${resource.title}"'),
          backgroundColor: const Color(0xFFB91C1C),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: const Color(0xFFB91C1C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0F766E);
    final provider = context.watch<ResourceLibraryProvider>();
    final state = provider.state;
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    final resources = state.resources
        .where((resource) => resource.uploadedByUid == userUid)
        .toList();

    final totalUploads = resources.length;
    final totalDownloads = resources.fold<int>(
      0,
      (sum, resource) => sum + resource.downloads,
    );
    final totalViews = resources.fold<int>(
      0,
      (sum, resource) => sum + _resourceViewsEstimate(resource),
    );
    final totalLikes = resources.fold<int>(
      0,
      (sum, resource) => sum + resource.likes,
    );
    final totalDislikes = resources.fold<int>(
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
      backgroundColor: const Color(0xFFE6FFFB),
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
                            backgroundColor: Colors.white,
                            accentColor: const Color(0xFF5EEAD4),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          height: 180,
                          child: _analyticsCard(
                            icon: Icons.download_rounded,
                            number: totalDownloads.toString(),
                            label: 'Total Downloads',
                            color: const Color(0xFF0E7490),
                            backgroundColor: Colors.white,
                            accentColor: const Color(0xFF67E8F9),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          height: 180,
                          child: _analyticsCard(
                            icon: Icons.visibility_rounded,
                            number: totalViews.toString(),
                            label: 'Total Views',
                            color: const Color(0xFF047857),
                            backgroundColor: Colors.white,
                            accentColor: const Color(0xFF86EFAC),
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
                  '${resources.length} resources in your library',
                  style: TextStyle(
                    color: Colors.blueGrey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        state.error!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  )
                else
                  ...resources.map(
                    (resource) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _resourceCard(resource),
                    ),
                  ),
                if (!state.isLoading && resources.isEmpty)
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
        color: backgroundColor,
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

  Widget _resourceCard(ResourceModel resource) {
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
                text: '${_resourceViewsEstimate(resource)} views',
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6EE7B7).withOpacity(0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
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
            backgroundColor: const Color(0xFF6EE7B7).withOpacity(0.3),
            radius: 20,
            child: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFF0F766E),
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
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Likes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalLikes total',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1.5,
                height: 50,
                color: const Color(0xFF0E7490).withOpacity(0.3),
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
                          color: Color(0xFF0E7490),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Dislikes',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0E7490),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalDislikes total',
                        style: const TextStyle(fontSize: 11),
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

  int _resourceViewsEstimate(ResourceModel resource) {
    return resource.downloads + resource.likes + resource.dislikes;
  }
}
