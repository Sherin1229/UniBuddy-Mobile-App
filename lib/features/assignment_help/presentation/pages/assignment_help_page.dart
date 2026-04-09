import 'package:flutter/material.dart';
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
  int _selectedFilterIndex = 1; // Default to "My Requests"
  final TextEditingController _searchController = TextEditingController();

  // Mock data
  late List<HelpRequest> allRequests;
  late List<HelpRequest> filteredRequests;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _updateFilteredRequests();
  }

  void _initializeMockData() {
    allRequests = [
      HelpRequest(
        title: 'Database Assignment',
        subject: 'Database Systems',
        ownerName: 'Kushani A', // owner
        description: 'I need help understanding JOIN queries for my assignment. Can someone explain with examples?',
        deadline: DateTime(2024, 6, 20),
        status: HelpRequestStatus.open, // set to open
        views: 5,
        likes: 5,
        comments: 2,
        attachmentName: 'Assignment 3.pdf',
      ),
      HelpRequest(
        title: 'SQL Query Optimization',
        subject: 'Database Systems',
        ownerName: 'Ahmed M',
        description: 'Need help optimizing my SQL queries',
        deadline: DateTime(2024, 6, 10),
        status: HelpRequestStatus.solved,
        views: 8,
        likes: 15,
        comments: 3,
      ),
      HelpRequest(
        title: 'Normalization Questions',
        subject: 'Database Design',
        ownerName: 'Priya S',
        description: 'Help with database normalization concepts',
        deadline: DateTime(2024, 6, 5),
        status: HelpRequestStatus.solved,
        views: 10,
        likes: 17,
        comments: 4,
      ),
      HelpRequest(
        title: 'Entity Relationship Diagram Help',
        subject: 'Database Design',
        ownerName: 'Kushani A',
        description: 'Can someone review my ER diagram for the project?',
        deadline: DateTime(2024, 6, 25),
        status: HelpRequestStatus.open,
        views: 3,
        likes: 2,
        comments: 1,
        attachmentName: 'ER_Diagram.jpg',
      ),
      HelpRequest(
        title: 'Transaction Management',
        subject: 'Database Systems',
        ownerName: 'Marcus T',
        description: 'Need clarification on ACID properties',
        deadline: DateTime(2024, 6, 22),
        status: HelpRequestStatus.open,
        views: 6,
        likes: 8,
        comments: 2,
      ),
      HelpRequest(
        title: 'Python Data Structures',
        subject: 'Programming',
        ownerName: 'Lisa R',
        description: 'Help with implementing linked lists',
        deadline: DateTime(2024, 6, 18),
        status: HelpRequestStatus.overdue,
        views: 4,
        likes: 3,
        comments: 1,
      ),
    ];
  }

  void _updateFilteredRequests() {
    final searchQuery = _searchController.text.toLowerCase();

    List<HelpRequest> tempFiltered = allRequests;

    // Apply filter based on selected tab
    switch (_selectedFilterIndex) {
      case 0: // All
        break;
      case 1: // My Requests
        tempFiltered = tempFiltered
            .where((req) => req.ownerName == 'Kushani A')
            .toList();
        break;
      case 2: // Open
        tempFiltered = tempFiltered
            .where((req) => req.status == HelpRequestStatus.open)
            .toList();
        break;
      case 3: // Solved
        tempFiltered = tempFiltered
            .where((req) => req.status == HelpRequestStatus.solved)
            .toList();
        break;
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      tempFiltered = tempFiltered
          .where((req) =>
              req.title.toLowerCase().contains(searchQuery) ||
              req.subject.toLowerCase().contains(searchQuery) ||
              req.description.toLowerCase().contains(searchQuery))
          .toList();
    }

    setState(() {
      filteredRequests = tempFiltered;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                durationSeconds: 14,
                motionScale: 1.2,
                opacityScale: 1.15,
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
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => _updateFilteredRequests(),
                            decoration: InputDecoration(
                              hintText: 'Search help requests...',
                              hintStyle: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF9CA3AF),
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        // Filter Tabs
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: filteredRequests.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 60,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No help requests found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 90),
                            itemCount: filteredRequests.length,
                            itemBuilder: (context, index) {
                              return HelpCard(
                                request: filteredRequests[index],
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => HelpRequestDetailsPage(
                                        request: filteredRequests[index],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Navigate to create help request'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          backgroundColor: primaryBrand,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Post Help Request'),
        ),
      );
  }

  Widget _buildFilterTab(int index, String label) {
    const Color primaryBrand = Color(0xFF0F766E);
    final isSelected = _selectedFilterIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
        _updateFilteredRequests();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
