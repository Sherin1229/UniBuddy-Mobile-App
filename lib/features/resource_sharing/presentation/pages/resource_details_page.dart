import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/resource_model.dart';
import '../../data/services/resource_firestore_service.dart';
import '../../../../shared/widgets/animated_app_background.dart';

const _teal = Color(0xFF3D9E8C);

class ResourceDetailsPage extends StatefulWidget {
  final ResourceModel resource;

  const ResourceDetailsPage({super.key, required this.resource});

  @override
  State<ResourceDetailsPage> createState() => _ResourceDetailsPageState();
}

class _ResourceDetailsPageState extends State<ResourceDetailsPage> {
  final ResourceFirestoreService _service = ResourceFirestoreService();
  late ResourceModel _resource;
  int _downloads = 0;
  int _likes = 0;
  int _dislikes = 0;
  ResourceReaction? _myReaction;
  bool _isReacting = false;
  bool _isDownloading = false;

  ResourceModel get resource => _resource;

  bool get _liked => _myReaction == ResourceReaction.like;
  bool get _disliked => _myReaction == ResourceReaction.dislike;

  @override
  void initState() {
    super.initState();
    _resource = widget.resource;
    _downloads = _resource.downloads;
    _likes = resource.likes;
    _dislikes = resource.dislikes;
    _loadMyReaction();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Future<void> _loadMyReaction() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      final reaction = await _service.getUserReaction(
        resourceId: resource.id,
        userId: user.uid,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _myReaction = reaction;
      });
    } catch (_) {
      // Keep page usable even if reaction read fails.
    }
  }

  Future<void> _submitReaction(ResourceReaction next) async {
    if (_isReacting) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to react to resources.')),
      );
      return;
    }

    final target = _myReaction == next ? null : next;

    setState(() => _isReacting = true);
    try {
      final summary = await _service.setUserReaction(
        resourceId: resource.id,
        userId: user.uid,
        reaction: target,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _likes = summary.likes;
        _dislikes = summary.dislikes;
        _myReaction = summary.userReaction;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update reaction. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isReacting = false);
      }
    }
  }

  Future<void> _downloadFile() async {
    if (_isDownloading) {
      return;
    }

    setState(() => _isDownloading = true);
    try {
      final fileUrl = await _service.resolveDownloadUrl(resource);
      final uri = _buildDownloadUri(fileUrl);
      if (uri == null) {
        throw const FormatException('Invalid URL');
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not launch URL');
      }

      await _service.incrementDownloadCount(resource.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _downloads += 1;
        _resource = _resource.copyWith(downloads: _downloads, fileUrl: fileUrl);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start download. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Uri? _buildDownloadUri(String rawUrl) {
    final parsed = Uri.tryParse(rawUrl.trim());
    if (parsed == null) {
      return null;
    }

    final cloudinaryOriginal = _toOriginalCloudinaryUrl(
      parsed,
      fileName: resource.fileName,
    );
    if (cloudinaryOriginal != null) {
      return cloudinaryOriginal;
    }

    final host = parsed.host.toLowerCase();
    if (host.contains('drive.google.com')) {
      final id = _googleDriveFileId(parsed);
      if (id != null) {
        return Uri.parse('https://drive.google.com/uc?export=download&id=$id');
      }
    }

    if (host.contains('dropbox.com')) {
      return parsed.replace(
        queryParameters: {...parsed.queryParameters, 'dl': '1'},
      );
    }

    return parsed;
  }

  Uri? _toOriginalCloudinaryUrl(Uri uri, {String? fileName}) {
    if (!uri.host.toLowerCase().contains('res.cloudinary.com')) {
      return null;
    }

    final segments = uri.pathSegments;
    final uploadIndex = segments.indexOf('upload');
    if (uploadIndex == -1 || uploadIndex + 1 >= segments.length) {
      return uri;
    }

    var versionIndex = -1;
    for (var i = uploadIndex + 1; i < segments.length; i++) {
      if (RegExp(r'^v\d+$').hasMatch(segments[i])) {
        versionIndex = i;
        break;
      }
    }

    final normalizedSegments = <String>[...segments.take(uploadIndex + 1)];

    // fl_attachment forces browser/app to download instead of preview.
    final safeName = (fileName ?? '').trim();
    final attachmentSegment = safeName.isEmpty
        ? 'fl_attachment'
        : 'fl_attachment:${safeName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';
    normalizedSegments.add(attachmentSegment);

    if (versionIndex == -1) {
      normalizedSegments.addAll(segments.skip(uploadIndex + 1));
    } else {
      normalizedSegments.addAll(segments.skip(versionIndex));
    }

    final path = '/${normalizedSegments.join('/')}';
    final query = uri.hasQuery ? '?${uri.query}' : '';
    final fragment = uri.hasFragment ? '#${uri.fragment}' : '';

    return Uri.parse('${uri.scheme}://${uri.authority}$path$query$fragment');
  }

  String? _googleDriveFileId(Uri uri) {
    final idFromQuery = uri.queryParameters['id'];
    if (idFromQuery != null && idFromQuery.isNotEmpty) {
      return idFromQuery;
    }

    final segments = uri.pathSegments;
    final fileIndex = segments.indexOf('d');
    if (fileIndex != -1 && fileIndex + 1 < segments.length) {
      return segments[fileIndex + 1];
    }

    return null;
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
                        value: '$_downloads',
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
                              onPressed: _isReacting
                                  ? null
                                  : () =>
                                        _submitReaction(ResourceReaction.like),
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
                              onPressed: _isReacting
                                  ? null
                                  : () => _submitReaction(
                                      ResourceReaction.dislike,
                                    ),
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
                'File: ${resource.fileName ?? 'Attached file'} • ${resource.fileSizeKb} KB',
                style: TextStyle(color: Colors.blueGrey.shade700),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isDownloading ? null : _downloadFile,
                  icon: const Icon(Icons.download_rounded),
                  label: Text(_isDownloading ? 'Downloading...' : 'Download'),
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
