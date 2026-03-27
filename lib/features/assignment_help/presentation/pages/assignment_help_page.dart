import 'package:flutter/material.dart';
import '../../../../app_colors.dart';
import '../widgets/help_card.dart';

class AssignmentHelpPage extends StatelessWidget {
  const AssignmentHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = [
      {
        'title': 'Java Assignment Help',
        'subject': 'OOP concepts',
        'status': 'OPEN',
      },
      {
        'title': 'Flutter UI Help',
        'subject': 'Need help with layouts',
        'status': 'SOLVED',
      },
      {
        'title': 'Database ER Diagram',
        'subject': 'Urgent support needed',
        'status': 'OVERDUE',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'KUSHANI TEST PAGE',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search assignments...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final item = requests[index];
                return HelpCard(
                  title: item['title']!,
                  subject: item['subject']!,
                  status: item['status']!,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item['title']} clicked'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}