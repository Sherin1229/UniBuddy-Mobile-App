import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/help_request_model.dart';

class HelpRequestApiService {
  static const String baseUrl = 'https://your-backend-api.com/api'; // Replace with your actual backend URL

  Future<List<HelpRequest>> fetchHelpRequests({
    String? filter, // 'all', 'my_requests', 'open', 'solved'
    String? searchQuery,
    String? userId, // For 'my_requests' filter
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (filter != null && filter != 'all') {
        queryParams['filter'] = filter;
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      
      if (userId != null && filter == 'my_requests') {
        queryParams['userId'] = userId;
      }

      final uri = Uri.parse('$baseUrl/help-requests').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          // 'Authorization': 'Bearer ${your_token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => HelpRequest.fromJson(json)).toList();
      } else {
        print('Failed to fetch help requests: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching help requests: $e');
      return [];
    }
  }

  Future<bool> submitHelpRequest({
    required String title,
    required String subject,
    required String description,
    required String deadline,
    required String ownerName,
    required String email,
    required String phone,
    String? attachmentPath,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/help-requests'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          // 'Authorization': 'Bearer ${your_token}',
        },
        body: jsonEncode({
          'title': title,
          'subject': subject,
          'description': description,
          'deadline': deadline,
          'ownerName': ownerName,
          'email': email,
          'phone': phone,
          'attachmentPath': attachmentPath,
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to submit help request: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error submitting help request: $e');
      return false;
    }
  }
}