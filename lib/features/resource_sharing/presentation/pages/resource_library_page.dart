import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/resource_library_provider.dart';
import '../widgets/resource_card.dart';
import '../widgets/resource_search_bar.dart';
import '../widgets/subject_filter_chips.dart';
import '../widgets/empty_resources_view.dart';
import '../widgets/loading_resources_view.dart';
import '../widgets/error_resources_view.dart';

const _teal = Color(0xFF3D9E8C);

class ResourceLibraryPage extends StatefulWidget {
  const ResourceLibraryPage({super.key});

  @override
  State<ResourceLibraryPage> createState() => _ResourceLibraryPageState();
}

class _ResourceLibraryPageState extends State<ResourceLibraryPage> {
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
      backgroundColor: Colors.grey[50],
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResourceSearchBar(onChanged: provider.setSearch),
          const SizedBox(height: 4),
          SubjectFilterChips(
            filters: ResourceLibraryProvider.filters,
            selected: state.selectedFilter,
            onSelected: provider.setFilter,
          ),
          const SizedBox(height: 8),
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
                            itemCount: state.resources.length,
                            itemBuilder: (_, i) =>
                                ResourceCard(resource: state.resources[i]),
                          ),
          ),
        ],
      ),
    );
  }
}
