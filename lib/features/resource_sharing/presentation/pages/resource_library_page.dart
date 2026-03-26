import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/resource_model.dart';
import '../state/resource_library_provider.dart';
import '../widgets/resource_card.dart';
import '../widgets/resource_search_bar.dart';
import '../widgets/subject_filter_chips.dart';
import '../widgets/empty_resources_view.dart';
import '../widgets/loading_resources_view.dart';
import '../widgets/error_resources_view.dart';
import 'resource_details_page.dart';
import '../../../../shared/widgets/animated_app_background.dart';

const _teal = Color(0xFF3D9E8C);

class ResourceLibraryPage extends StatefulWidget {
  const ResourceLibraryPage({super.key});

  @override
  State<ResourceLibraryPage> createState() => _ResourceLibraryPageState();
}

class _ResourceLibraryPageState extends State<ResourceLibraryPage> {
  Future<void> _openDetails(ResourceModel resource) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResourceDetailsPage(resource: resource),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResourceLibraryProvider>().loadResources();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResourceLibraryProvider>();
    final state = provider.state;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.school, size: 22),
            SizedBox(width: 8),
            Text('UniBuddy', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_outlined),
          ),
        ],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withOpacity(0.62),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.75),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ResourceSearchBar(onChanged: provider.setSearch),
                      const SizedBox(height: 2),
                      SubjectFilterChips(
                        filters: ResourceLibraryProvider.filters,
                        selected: state.selectedFilter,
                        onSelected: provider.setFilter,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: state.isLoading
                    ? const LoadingResourcesView()
                    : state.error != null
                    ? ErrorResourcesView(
                        message: state.error!,
                        onRetry: provider.loadResources,
                      )
                    : state.resources.isEmpty
                    ? const EmptyResourcesView()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: state.resources.length,
                        itemBuilder: (_, i) {
                          final resource = state.resources[i];
                          return _AnimatedResourceTile(
                            index: i,
                            child: ResourceCard(
                              resource: resource,
                              onTap: () => _openDetails(resource),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedResourceTile extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedResourceTile({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: 260 + (index * 28).clamp(0, 260));

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}
