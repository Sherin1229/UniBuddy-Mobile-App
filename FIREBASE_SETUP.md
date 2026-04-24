# Firebase Backend Setup - UniBuddy Study Groups

## ✅ Completed

### 1. **Firebase Core Added**
- Added `firebase_core: ^3.1.0` to `pubspec.yaml`
- Firebase is now initialized in `main.dart` before the app runs
- Created `firebase_options.dart` for multi-platform configuration

### 2. **Firebase Initialization**
```dart
// In main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
```

### 3. **Cloud Firestore Available**
- `cloud_firestore: ^5.6.6` already in dependencies
- Ready for database operations

---

## 🔧 Next Steps (To Complete Firebase Integration)

### Step 1: Get Firebase Credentials
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing one
3. Generate credentials for each platform:
   - **Android**: Download `google-services.json`
   - **iOS**: Download `GoogleService-Info.plist`
   - **Web**: Get WEB credentials
   - **Windows/macOS**: Get OAuth credentials

### Step 2: Update `firebase_options.dart`
Replace placeholder values with actual Firebase credentials:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_ANDROID_API_KEY',
  appId: '1:12345:android:...',
  messagingSenderId: '123456789',
  projectId: 'your-firebase-project-id',
  storageBucket: 'your-firebase-project.appspot.com',
);
```

### Step 3: Place Configuration Files
- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`
- **Web**: No extra files needed (use firebase_options.dart)

### Step 4: Convert Models to Firestore-Compatible Format

Add `fromMap()` and `toMap()` methods to models:

```dart
// Example for StudyGroup model
extension StudyGroupExtension on StudyGroup {
  Map<String, dynamic> toFirestore() => {
    'id': id,
    'createdBy': createdBy,
    'name': name,
    'subject': subject,
    'description': description,
    'maxMembers': maxMembers,
    'currentMembers': currentMembers,
    'createdAt': createdAt,
    'isPrivate': isPrivate,
    // ... other fields
  };

  factory StudyGroup.fromFirestore(Map<String, dynamic> doc, String docId) {
    return StudyGroup(
      id: int.parse(docId),
      createdBy: doc['createdBy'] as int,
      // ... other fields
    );
  }
}
```

### Step 5: Create Firestore Services

Create `lib/features/study_groups/data/services/study_group_firestore_service.dart`:

```dart
class StudyGroupFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<StudyGroup>> fetchStudyGroups() {
    return _firestore
        .collection('study_groups')
        .snapshots()
        .map((snap) =>
            snap.docs
                .map((doc) => StudyGroup.fromFirestore(
                      doc.data(),
                      doc.id,
                    ))
                .toList());
  }

  Future<void> createStudyGroup(StudyGroup group) {
    return _firestore
        .collection('study_groups')
        .doc(group.id.toString())
        .set(group.toFirestore());
  }

  // Additional CRUD methods...
}
```

### Step 6: Create Firebase Repository

Implement `StudyGroupRepositoryImpl` to use Firestore:

```dart
class StudyGroupRepositoryImpl implements StudyGroupRepository {
  final StudyGroupFirestoreService _firestoreService;

  @override
  Stream<List<StudyGroup>> getAllGroups() =>
      _firestoreService.fetchStudyGroups();

  @override
  Future<void> createGroup(...) =>
      _firestoreService.createStudyGroup(...);

  // Implement all abstract methods...
}
```

### Step 7: Firestore Database Structure

Set up these collections in Firestore:

```
firestore
├── study_groups/
│   ├── {groupId}
│   │   ├── name: "Advanced Calculus"
│   │   ├── subject: "Mathematics"
│   │   ├── description: "..."
│   │   ├── createdBy: 1
│   │   ├── maxMembers: 10
│   │   ├── currentMembers: 5
│   │   ├── members: ["user1", "user2", ...]
│   │   ├── createdAt: timestamp
│   │   └── isPrivate: false
│   └── {groupId2}
│
├── study_sessions/
│   ├── {sessionId}
│   │   ├── groupId: "{groupId}"
│   │   ├── title: "Session Title"
│   │   ├── scheduledAt: timestamp
│   │   ├── durationMinutes: 90
│   │   └── participants: [...]
│   └── {sessionId2}
│
└── session_requests/
    ├── {requestId}
    │   ├── groupId: "{groupId}"
    │   ├── userId: "user1"
    │   ├── status: "pending"
    │   └── createdAt: timestamp
    └── {requestId2}
```

### Step 8: Add Security Rules

In Firebase Console → Firestore → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own data
    match /study_groups/{groupId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.createdBy;
    }
  }
}
```

---

## 📊 Current Project Status

| Component | Status | Details |
|-----------|--------|---------|
| Firebase Core | ✅ Setup | Version 3.15.2 installed |
| Cloud Firestore | ✅ Available | Version 5.6.12 available |
| Firebase Options | ✅ Created | Template file with placeholder values |
| Firebase Init | ✅ Active | Initializes in main.dart |
| Mock Data | ✅ Working | Currently using for development |
| Firestore Services | ⏳ Pending | Need model extensions |
| Firestore Repository | ⏳ Pending | Need model serialization |

---

## 🚀 Running the App Now

The app will:
1. ✅ Initialize Firebase on startup
2. ✅ Use mock data (from `StudyGroupRepositoryImpl`)
3. ⏳ Be ready to connect to Firestore once credentials are added

**Status**: Ready for Firebase connection migration when credentials are available.

---

## 📝 File Locations

- Firebase Options: `lib/firebase_options.dart`
- Main.dart: `lib/main.dart`
- Study Group Service: `lib/features/study_groups/data/services/` (to create)
- Study Group Repository: `lib/features/study_groups/data/repositories/study_group_repository_impl.dart`

---

## 💡 Tips

- Start with one feature (e.g., fetchStudyGroups) and migrate it to Firestore
- Keep mock data as fallback during development
- Use Firestore Emulator for local testing
- Test security rules before deploying

---

**Last Updated**: April 9, 2026  
**Firebase Status**: Ready for Production Configuration
