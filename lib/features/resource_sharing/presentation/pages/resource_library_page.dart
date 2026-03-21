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
import 'resource_form_page.dart';

const _teal = Color(0xFF3D9E8C);

class ResourceLibraryPage extends StatefulWidget {
  const ResourceLibraryPage({super.key});

  @override
  State<ResourceLibraryPage> createState() => _ResourceLibraryPageState();
}

class _ResourceLibraryPageState extends State<ResourceLibraryPage> {
  Future<void> _openCreateForm() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ResourceFormPage()));
  }

  Future<void> _openDetails(ResourceModel resource) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResourceDetailsPage(resource: resource),
      ),
    );
  }

  Future<void> _openEdit(ResourceModel resource) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResourceFormPage(existingResource: resource),
      ),
    );
  }

  Future<void> _deleteResource(ResourceModel resource) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Resource'),
        content: Text('Delete "${resource.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final message = await context
        .read<ResourceLibraryProvider>()
        .deleteResource(resource.id);
    if (!mounted || message == null) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateForm,
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file_outlined),
        label: const Text('Upload'),
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
                    itemBuilder: (_, i) {
                      final resource = state.resources[i];
                      return ResourceCard(
                        resource: resource,
                        onTap: () => _openDetails(resource),
                        onEdit: () => _openEdit(resource),
                        onDelete: () => _deleteResource(resource),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
