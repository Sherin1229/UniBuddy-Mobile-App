# 🚀 Deploy Firestore to UniBuddy Backend

## ⚡ Quick Setup (2-3 minutes)

### Step 1: Deploy Security Rules
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select **UniBuddy** project
3. Navigate to **Firestore Database** → **Rules** tab
4. Click **Edit rules**
5. Replace ALL content with contents from `firestore.rules` file in this repo
6. Click **Publish**

### Step 2: Import Study Groups Data
1. In Firebase Console, go to **Firestore Database** → **Data** tab
2. Click **Start Collection** (if first time) or **⋮ (More)** → **Import Collection**
3. Select the file: `firestore_sample_data.json` from this repo
4. Click **Import**
5. Wait for import to complete (~10-30 seconds)

### Step 3: Verify Data
You should now see:
- ✅ `study_groups` collection with 3 groups
- ✅ `users` collection with member data
- ✅ Study sessions and resources under each group

---

## 📊 Expected Data Structure

After import, your Firestore will have:

```
study_groups/
├── sg_001_flutter_basics
│   ├── members/
│   ├── sessions/
│   └── resources/
├── sg_002_web_development
│   ├── members/
│   ├── sessions/
│   └── resources/
└── sg_003_python_programming
    ├── members/
    └── sessions/

users/
├── user_001_alice
├── user_002_bob
└── (+ 6 more users)

notifications/
└── (will be created when app sends notifications)
```

---

## 🐍 Automated Setup (Alternative - if you have service account key)

If you have a Firebase service account JSON key:

1. Save it as `service-account-key.json` in this directory
2. Run: `python deploy_firestore.py`
3. Script will deploy rules and import data automatically

---

## 🔄 Next: Update App Code

After importing data, run:

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

The app will now:
1. Connect to your Firestore
2. Pull study groups from backend
3. Display live data

---

## ✅ Backend Integration Checklist

- [ ] Deploy Firestore security rules
- [ ] Import study groups sample data  
- [ ] Verify data appears in Firebase Console
- [ ] Run app and see study groups load
- [ ] Test creating a new study group
- [ ] Test joining/leaving groups
- [ ] Test session requests

---

## 🆘 Troubleshooting

**"No data appears in app?"**
- Check: Did rules publish successfully?
- Check: Did data import complete?
- Check: Are there any errors in Firebase console?
- Refresh app: `flutter hot reload`

**"Permission denied errors?"**
- Rules may not be published
- Try creating a test document manually first
- Check rule syntax in Firebase console

**"Rules won't publish?"**
- Look for red errors in rules editor
- Make sure all syntax is correct
- Firebase rules must be valid Firestore rule syntax

---

## 📞 Need Help?

See: `FIRESTORE_RULES_DEPLOYMENT.md` and `FIRESTORE_SAMPLE_DATA_SETUP.md` for detailed steps.
