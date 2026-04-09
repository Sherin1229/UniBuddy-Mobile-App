import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/widgets/animated_app_background.dart';
import '../widgets/help_card.dart';
import '../../data/models/help_request_model.dart';
import 'help_request_details_page.dart';

class AssignmentHelpPage extends StatefulWidget {
  const AssignmentHelpPage({super.key});

  @override
  State<AssignmentHelpPage> createState() => _AssignmentHelpPageState();
}

class _AssignmentHelpPageState extends State<AssignmentHelpPage> {
  int _selectedFilterIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HelpRequest> _applyFilters(List<HelpRequest> all) {
    List<HelpRequest> list = all;
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUid = currentUser?.uid;
    final currentDisplayName = currentUser?.displayName;

    bool isCurrentUser(HelpRequest request) {
      if (currentUid != null && request.ownerId == currentUid) {
        return true;
      }
      if (request.ownerId.isEmpty && currentDisplayName != null) {
        return request.ownerName == currentDisplayName;
      }
      return false;
    }

    switch (_selectedFilterIndex) {
      case 1: // My Requests
        list = list.where(isCurrentUser).toList();
        break;
      case 2: // Open
        list = list.where((r) => r.status == HelpRequestStatus.open && isCurrentUser(r)).toList();
        break;
      case 3: // Solved
        list = list.where((r) => r.status == HelpRequestStatus.solved && isCurrentUser(r)).toList();
        break;
    }

    if (_searchQuery.isNotEmpty) {
      list = list
          .where((r) =>
              r.title.toLowerCase().contains(_searchQuery) ||
              r.subject.toLowerCase().contains(_searchQuery) ||
              r.description.toLowerCase().contains(_searchQuery))
          .toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBrand = Color(0xFF0F766E);
    const Color topBarColor = Color(0xFF3D9E8C);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: topBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.assignment_outlined, size: 22),
            SizedBox(width: 8),
            Text('UniBuddy',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
              durationSeconds: 14,
              motionScale: 1.2,
              opacityScale: 1.15,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Search + Filter box ──
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
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) =>
                              setState(() => _searchQuery = v.toLowerCase()),
                          decoration: const InputDecoration(
                            hintText: 'Search help requests...',
                            hintStyle: TextStyle(
                                color: Color(0xFF9CA3AF), fontSize: 14),
                            prefixIcon: Icon(Icons.search,
                                color: Color(0xFF9CA3AF), size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      // Filter Tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 8),
                          child: Row(
                            children: [
                              _buildFilterTab(0, 'All'),
                              const SizedBox(width: 12),
                              _buildFilterTab(1, 'My Requests'),
                              const SizedBox(width: 12),
                              _buildFilterTab(2, 'Open'),
                              const SizedBox(width: 12),
                              _buildFilterTab(3, 'Solved'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(18, 0, 0, 6),
                child: Text(
                  'Help Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),

              // ── Live Firestore feed ──
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('help_requests')
                      .snapshots(),
                  builder: (context, snapshot) {
                    // Loading
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: primaryBrand),
                      );
                    }

                    // Error
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading requests.\nPlease try again.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8)),
                        ),
                      );
                    }

                    // Empty
                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 60,
                                color: Colors.white.withOpacity(0.6)),
                            const SizedBox(height: 16),
                            Text(
                              'No help requests yet.\nBe the first to post one!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Convert docs to HelpRequest objects
                    final allRequests = snapshot.data!.docs.map((doc) {
                      return HelpRequest.fromMap(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      );
                    }).toList();

                    allRequests.sort(
                      (a, b) => b.createdAt.compareTo(a.createdAt),
                    );

                    // Apply filters + search
                    final filtered = _applyFilters(allRequests);

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 60,
                                color: Colors.white.withOpacity(0.6)),
                            const SizedBox(height: 16),
                            Text(
                              'No requests match your filter.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(12, 0, 12, 90),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return HelpCard(
                          request: filtered[index],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => HelpRequestDetailsPage(
                                  request: filtered[index],
                                ),
                              ),
                            );
                          },
                        );
                      },
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

  Widget _buildFilterTab(int index, String label) {
    const Color primaryBrand = Color(0xFF0F766E);
    final isSelected = _selectedFilterIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryBrand : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryBrand.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color:
                isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}