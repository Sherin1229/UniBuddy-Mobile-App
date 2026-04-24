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
        list = list.where((r) => r.status == HelpRequestStatus.open).toList();
        break;
      case 3: // Solved
        list = list.where((r) => r.status == HelpRequestStatus.solved).toList();
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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('help_requests')
                .snapshots(),
            builder: (context, snapshot) {
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

              List<HelpRequest> allRequests = [];
              int myRequestCount = 0;
              int myOpenCount = 0;
              int mySolvedCount = 0;

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                allRequests = snapshot.data!.docs.map((doc) {
                  return HelpRequest.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();

                allRequests.sort(
                  (a, b) => b.createdAt.compareTo(a.createdAt),
                );

                final myRequests = allRequests.where(isCurrentUser);
                myRequestCount = myRequests.length;
                myOpenCount = myRequests
                    .where((r) => r.status == HelpRequestStatus.open)
                    .length;
                mySolvedCount = myRequests
                    .where((r) => r.status == HelpRequestStatus.solved)
                    .length;
              }

              final filtered = _applyFilters(allRequests);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPersonalStatusBar(
                    myRequests: myRequestCount,
                    openRequests: myOpenCount,
                    solvedRequests: mySolvedCount,
                  ),
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

                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: primaryBrand),
                          );
                        }

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

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalStatusBar({
    required int myRequests,
    required int openRequests,
    required int solvedRequests,
  }) {
    final displayName = FirebaseAuth.instance.currentUser?.displayName ?? 'Student';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6F2EE), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFDDF5EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFF0F766E),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $displayName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You have $myRequests requests, $openRequests open, $solvedRequests solved.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF047857),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildCountChip('Total', myRequests, const Color(0xFFE0F2FE)),
                    const SizedBox(width: 6),
                    _buildCountChip('Open', openRequests, const Color(0xFFD9F7FF)),
                    const SizedBox(width: 6),
                    _buildCountChip('Solved', solvedRequests, const Color(0xFFE6F4EA)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountChip(String label, int count, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label $count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey[800],
        ),
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