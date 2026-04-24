# Firestore Sample Data Setup Guide

## Overview
This guide explains how to create and import the sample data into your Firestore database. The sample data includes:
- **3 Study Groups** with members, sessions, and resources
- **8 User Profiles** with preferences
- **3 Sample Notifications** for testing

## Sample Data Contents

### Study Groups (3 groups)
1. **Flutter Basics Study Group** (`sg_001_flutter_basics`)
   - 5 members, 2 sessions, 2 resources
   - "Beginner" level group led by Alice

2. **Web Development Study Group** (`sg_002_web_development`)
   - 3 members, 1 session
   - "Intermediate" level group led by Carol

3. **Python Programming Study Group** (`sg_003_python_programming`)
   - 2 members
   - "Beginner" level group led by David

### Users (8 profiles)
- Alice Johnson (Flutter enthusiast, admin)
- Bob Smith (Software Engineer)
- Carol Williams (Web developer)
- David Brown (Python mentor)
- Emma Davis (Data scientist)
- Frank Miller (Full-stack developer)
- Grace Lee (UI/UX specialist)
- Henry Johnson (Python learner)

### Notifications (3 samples)
- Session reminder notifications
- Member joined notifications
- Resource shared notifications

## Method 1: Firebase Console GUI (Recommended)

### Step 1: Open Firebase Console
1. Go to https://console.firebase.google.com
2. Select project: **unibuddy-785ab**
3. Click on **Firestore Database** in the left sidebar

### Step 2: Create Collections and Documents Manually

#### Creating Study Groups Collection

1. **Click "Create Collection"**
   - Collection name: `study_groups`
   - Click "Next"

2. **Create first document:**
   - Document ID: `sg_001_flutter_basics`
   - Add the following fields:
     - `id`: String = `sg_001_flutter_basics`
     - `name`: String = `Flutter Basics Study Group`
     - `description`: String = `Learn Flutter fundamentals together`
     - `subject`: String = `Flutter`
     - `level`: String = `Beginner`
     - `maxMembers`: Number = `20`
     - `currentMembers`: Number = `5`
     - `createdBy`: String = `user_001_alice`
     - `createdAt`: Timestamp = `Apr 1, 2026 10:00:00`
     - `imageUrl`: String = `https://via.placeholder.com/400x300?text=Flutter+Basics`
     - `tags`: Array = [`flutter`, `mobile`, `beginner`]
   - Click "Save"

3. **Repeat for other study groups** using the sample data file

#### Creating Users Collection

1. **Click "Create Collection"** at the root level
   - Collection name: `users`
   - Click "Next"

2. **Create user documents** with their respective data
   - Document ID: Same as user's uid (e.g., `user_001_alice`)

#### Creating Notifications Collection

1. **Click "Create Collection"** at the root level
   - Collection name: `notifications`
   - Click "Next"

2. **Create notification documents** with the sample data

### Step 3: Create Subcollections (for Study Groups)

For each study group document, add subcollections:

1. **For `sg_001_flutter_basics`:**
   - Click on the document
   - Scroll down and click "Create subcollection"
   
   **Create `members` subcollection:**
   - Subcollection ID: `members`
   - First document ID: `user_001_alice`
   - Add member fields (id, name, email, role, joinedAt)
   - Repeat for other members

   **Create `sessions` subcollection:**
   - Subcollection ID: `sessions`
   - Document ID: `session_001`
   - Add session fields

   **Create `resources` subcollection:**
   - Subcollection ID: `resources`
   - Document ID: `res_001`
   - Add resource fields

## Method 2: Firebase CLI with Firestore Extension

### Prerequisites
```bash
npm install -g firebase-tools
firebase login
```

### Import Data via CLI

The Firebase CLI doesn't have a direct JSON import for Firestore, but you can:

1. **Use `firebase functions` to bulk import:**
   
   Create a Cloud Function that reads your JSON and imports it:
   ```typescript
   // functions/src/importData.ts
   import * as admin from 'firebase-admin';
   
   admin.initializeApp();
   const db = admin.firestore();
   
   export const importStudyGroups = async (req: any, res: any) => {
     try {
       const data = require('./firestore_sample_data.json');
       
       // Import study groups
       for (const [key, group] of Object.entries(data.study_groups)) {
         await db.collection('study_groups').doc(key).set(group);
       }
       
       // Import users
       for (const [key, user] of Object.entries(data.users)) {
         await db.collection('users').doc(key).set(user);
       }
       
       // Import notifications
       for (const [key, notif] of Object.entries(data.notifications)) {
         await db.collection('notifications').doc(key).set(notif);
       }
       
       res.json({ success: true, message: 'Data imported successfully' });
     } catch (error) {
       res.status(500).json({ error: error.message });
     }
   };
   ```

2. **Deploy the function:**
   ```bash
   firebase deploy --only functions:importStudyGroups
   ```

3. **Call the function via HTTP:**
   - Go to Cloud Functions in Firebase Console
   - Find `importStudyGroups`
   - Copy the trigger URL
   - Open it in your browser or use curl

## Method 3: Python Script (With Firebase Admin SDK)

### Install Dependencies
```bash
pip install firebase-admin
```

### Create Import Script

```python
# import_firestore_data.py
import json
import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase (download JSON from Firebase Console)
cred = credentials.Certificate('path/to/serviceAccountKey.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

with open('firestore_sample_data.json', 'r') as f:
    data = json.load(f)

# Import study groups
for group_id, group_data in data['study_groups'].items():
    db.collection('study_groups').document(group_id).set(group_data)
    print(f"✓ Created study group: {group_id}")

# Import users
for user_id, user_data in data['users'].items():
    db.collection('users').document(user_id).set(user_data)
    print(f"✓ Created user: {user_id}")

# Import notifications
for notif_id, notif_data in data['notifications'].items():
    db.collection('notifications').document(notif_id).set(notif_data)
    print(f"✓ Created notification: {notif_id}")

print("\n✅ All sample data imported successfully!")
```

### Run the Script
```bash
python import_firestore_data.py
```

## Method 4: Use in Your Flutter App

Modify your repository to import this data when the app first runs:

```dart
// lib/features/study_groups/data/repositories/study_group_repository_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class StudyGroupRepositoryFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> importSampleData() async {
    try {
      // Add sample study groups
      await _firestore
          .collection('study_groups')
          .doc('sg_001_flutter_basics')
          .set({
            'id': 'sg_001_flutter_basics',
            'name': 'Flutter Basics Study Group',
            'description': 'Learn Flutter fundamentals together',
            'subject': 'Flutter',
            'level': 'Beginner',
            'maxMembers': 20,
            'currentMembers': 5,
            'createdBy': 'user_001_alice',
            'createdAt': Timestamp.now(),
            'imageUrl': 'https://via.placeholder.com/400x300?text=Flutter+Basics',
            'tags': ['flutter', 'mobile', 'beginner'],
          });
      
      print('✅ Sample data imported successfully');
    } catch (e) {
      print('❌ Error importing sample data: $e');
    }
  }
}
```

Call this method in your app initialization:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Import sample data (call once at app startup)
  // final repo = StudyGroupRepositoryFirebase();
  // await repo.importSampleData();
  
  runApp(const MyApp());
}
```

## Verifying Data Import

After importing, verify in Firebase Console:

1. Go to **Firestore Database** → **Data** tab
2. Check each collection:
   - ✅ `study_groups` - should have 3 documents
   - ✅ `users` - should have 8 documents
   - ✅ `notifications` - should have 3 documents

3. Expand `study_groups` to verify subcollections exist:
   - ✅ `members` (under each group)
   - ✅ `sessions` (under each group)
   - ✅ `resources` (under each group)

## Testing the Data

### Test Reading Study Groups
```dart
final studyGroups = await _firestore.collection('study_groups').get();
print('Study Groups: ${studyGroups.docs.length}');
```

### Test Reading Users
```dart
final users = await _firestore.collection('users').get();
print('Users: ${users.docs.length}');
```

### Test Notifications
```dart
final notifications = 
    await _firestore.collection('notifications').get();
print('Notifications: ${notifications.docs.length}');
```

## Firestore Data Structure

```
Firestore/
├── study_groups/
│   ├── sg_001_flutter_basics/
│   │   ├── members/ (subcollection)
│   │   ├── sessions/ (subcollection)
│   │   └── resources/ (subcollection)
│   ├── sg_002_web_development/
│   │   ├── members/ (subcollection)
│   │   ├── sessions/ (subcollection)
│   │   └── resources/ (subcollection)
│   └── sg_003_python_programming/
│       ├── members/ (subcollection)
│       ├── sessions/ (subcollection)
│       └── resources/ (subcollection)
├── users/
│   ├── user_001_alice/
│   ├── user_002_bob/
│   └── ... (8 users total)
└── notifications/
    ├── notif_001/
    ├── notif_002/
    └── notif_003/
```

## Next Steps

1. ✅ Import sample data using one of the methods above
2. Create Firestore services in your app (see FIRESTORE_SERVICES_GUIDE.md)
3. Update data models to include toFirestore()/fromFirestore() methods
4. Test data retrieval in your Flutter app
5. Connect UI to Firestore queries
6. Set up real-time listeners with StreamProviders

## Troubleshooting

### Issue: "Permission denied" when importing

**Solution:** 
- Check Security Rules allow write operations
- Ensure authenticated user has proper permissions
- For testing, temporarily use permissive rules

### Issue: Duplicate data appears

**Solution:**
- Check if you've run the import multiple times
- Delete existing collections and start fresh
- Use conditional logic to check if data exists before importing

### Issue: Timestamp format is incorrect

**Solution:**
- Use Firebase Console's timestamp picker
- Or use ISO 8601 format: `2026-04-01T10:00:00Z`
- In code, use `Timestamp.now()` for current time

## Additional Resources

- https://firebase.google.com/docs/firestore/manage-data/add-data
- https://firebase.google.com/docs/firestore/quickstart
- https://firebase.google.com/docs/firestore/solutions/organize-data
- https://firebase.google.com/docs/firestore/best-practices

## Quick Checklist

- [ ] Created `study_groups` collection with 3 documents
- [ ] Added subcollections (members, sessions, resources) to study groups
- [ ] Created `users` collection with 8 user documents
- [ ] Created `notifications` collection with 3 notification documents
- [ ] Verified all data appears in Firebase Console
- [ ] Tested reading data from Firestore in app
- [ ] Security rules allow reads on sample data
- [ ] Ready to connect data to Flutter UI
