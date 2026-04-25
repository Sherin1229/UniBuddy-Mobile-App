import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unibuddy/features/assignment_help/data/models/help_request_model.dart';

void main() {
  group('HelpRequest Model Tests', () {
    
    // Test 1: Create HelpRequest from valid map data
    test('HelpRequest.fromMap creates instance with valid data', () {
      final timestamp = Timestamp.fromDate(DateTime(2026, 5, 15));
      final createdTimestamp = Timestamp.fromDate(DateTime(2026, 4, 22));
      
      final map = {
        'title': 'Database Design Help',
        'subject': 'Database Systems',
        'description': 'Help needed with ER diagrams and normalization',
        'ownerId': 'user123',
        'ownerName': 'Kushani Shaveena',
        'deadline': timestamp,
        'createdAt': createdTimestamp,
        'status': 'open',
        'views': 5,
        'likes': 2,
        'comments': 1,
      };

      final request = HelpRequest.fromMap(map, 'doc123');

      expect(request.id, equals('doc123'));
      expect(request.title, equals('Database Design Help'));
      expect(request.subject, equals('Database Systems'));
      expect(request.ownerId, equals('user123'));
      expect(request.ownerName, equals('Kushani Shaveena'));
      expect(request.views, equals(5));
      expect(request.likes, equals(2));
    });

    // Test 2: HelpRequest status is Open for future deadline
    test('HelpRequest status is Open when deadline is in future', () {
      final futureDate = DateTime.now().add(const Duration(days: 5));
      final timestamp = Timestamp.fromDate(futureDate);
      
      final map = {
        'title': 'Math Help',
        'subject': 'Mathematics',
        'description': 'Calculus problem solving',
        'ownerId': 'user123',
        'ownerName': 'Test User',
        'deadline': timestamp,
        'createdAt': Timestamp.now(),
        'status': 'open',
      };

      final request = HelpRequest.fromMap(map, 'doc123');

      expect(request.status, equals(HelpRequestStatus.open));
    });

    // Test 3: HelpRequest status is Overdue for past deadline
    test('HelpRequest status is Overdue when deadline has passed', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      final timestamp = Timestamp.fromDate(pastDate);
      
      final map = {
        'title': 'Physics Help',
        'subject': 'Physics',
        'description': 'Help with quantum mechanics',
        'ownerId': 'user123',
        'ownerName': 'Test User',
        'deadline': timestamp,
        'createdAt': Timestamp.now(),
      };

      final request = HelpRequest.fromMap(map, 'doc123');

      expect(request.status, equals(HelpRequestStatus.overdue));
    });

    // Test 4: HelpRequest status is Solved when explicitly marked
    test('HelpRequest status is Solved when status field is solved', () {
      final futureDate = DateTime.now().add(const Duration(days: 5));
      final timestamp = Timestamp.fromDate(futureDate);
      
      final map = {
        'title': 'Chemistry Help',
        'subject': 'Chemistry',
        'description': 'Organic chemistry reactions',
        'ownerId': 'user123',
        'ownerName': 'Test User',
        'deadline': timestamp,
        'createdAt': Timestamp.now(),
        'status': 'solved',
      };

      final request = HelpRequest.fromMap(map, 'doc123');

      expect(request.status, equals(HelpRequestStatus.solved));
    });

    // Test 5: HelpRequest.fromJson parses string deadline correctly
    test('HelpRequest.fromJson parses string format deadline', () {
      final json = {
        'id': 'doc123',
        'title': 'English Essay',
        'subject': 'English',
        'description': 'Need help writing argumentative essay with minimum 500 words',
        'ownerId': 'user123',
        'ownerName': 'Test User',
        'deadline': '2026-05-15',
        'createdAt': '2026-04-22',
        'status': 'open',
      };

      final request = HelpRequest.fromJson(json);

      expect(request.title, equals('English Essay'));
      expect(request.subject, equals('English'));
      expect(request.deadline.year, equals(2026));
      expect(request.deadline.month, equals(5));
      expect(request.deadline.day, equals(15));
    });

    // Test 6: HelpRequest.fromJson parses integer timestamp correctly
    test('HelpRequest.fromJson parses integer timestamp deadline', () {
      final millisecondsSinceEpoch = DateTime(2026, 5, 15).millisecondsSinceEpoch;
      
      final json = {
        'id': 'doc123',
        'title': 'Biology Help',
        'subject': 'Biology',
        'description': 'Cell biology and genetics',
        'ownerId': 'user123',
        'ownerName': 'Test User',
        'deadline': millisecondsSinceEpoch,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'status': 'open',
      };

      final request = HelpRequest.fromJson(json);

      expect(request.deadline.year, equals(2026));
      expect(request.deadline.month, equals(5));
    });

    // Test 7: HelpRequest.toMap serializes all required fields
    test('HelpRequest.toMap correctly serializes to map', () {
      final now = DateTime.now();
      final request = HelpRequest(
        id: 'doc123',
        createdAt: now,
        ownerId: 'user123',
        title: 'Programming Help',
        subject: 'Programming',
        ownerName: 'Test User',
        description: 'Flutter widget building help',
        deadline: DateTime(2026, 6, 1),
      );

      final map = request.toMap();

      expect(map['title'], equals('Programming Help'));
      expect(map['subject'], equals('Programming'));
      expect(map['ownerName'], equals('Test User'));
      expect(map['ownerId'], equals('user123'));
      expect(map['description'], equals('Flutter widget building help'));
      expect(map['status'], equals('open'));
    });

    // Test 8: HelpRequest handles null optional fields
    test('HelpRequest handles null optional attachment fields', () {
      final map = {
        'title': 'Math Problem',
        'subject': 'Mathematics',
        'description': 'Calculus integration problem needs at least 10 characters',
        'ownerId': 'user123',
        'ownerName': 'Test User',
        'deadline': Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
        'createdAt': Timestamp.now(),
        'status': 'open',
        'attachmentPath': null,
        'attachmentName': null,
      };

      final request = HelpRequest.fromMap(map, 'doc123');

      expect(request.attachmentPath, isNull);
      expect(request.attachmentName, isNull);
    });

    // Test 9: HelpRequest correctly tracks engagement metrics
    test('HelpRequest correctly assigns views, likes, and comments', () {
      final map = {
        'title': 'Programming',
        'subject': 'Programming',
        'description': 'Help with data structures minimum 10 chars',
        'ownerId': 'user123',
        'ownerName': 'Test User',
        'deadline': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
        'createdAt': Timestamp.now(),
        'views': 15,
        'likes': 7,
        'comments': 3,
      };

      final request = HelpRequest.fromMap(map, 'doc123');

      expect(request.views, equals(15));
      expect(request.likes, equals(7));
      expect(request.comments, equals(3));
    });

    // Test 10: HelpRequest mutable properties can be updated
    test('HelpRequest mutable properties can be modified', () {
      final request = HelpRequest(
        id: 'doc123',
        createdAt: DateTime.now(),
        ownerId: 'user123',
        title: 'Original Title',
        subject: 'Original Subject',
        ownerName: 'Test User',
        description: 'Original description with minimum 10 chars',
        deadline: DateTime.now().add(const Duration(days: 5)),
      );

      request.title = 'Updated Title';
      request.subject = 'Updated Subject';
      request.description = 'Updated description with min 10 chars';

      expect(request.title, equals('Updated Title'));
      expect(request.subject, equals('Updated Subject'));
      expect(request.description, equals('Updated description with min 10 chars'));
    });
  });
}