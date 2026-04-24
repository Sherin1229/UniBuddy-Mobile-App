# 🎯 Complete Firestore Setup Guide for UniBuddy Study Groups

## 📋 Overview
This guide will take you through deploying your Firestore backend in **3 easy steps** (5 minutes total).

---

## ✅ STEP 1: Deploy Security Rules (2 minutes)

### What This Does
Sets up access permissions so users can only see/edit what they should.

### Instructions

1. **Open Firebase Console**
   - Go to: https://console.firebase.google.com/
   - Select your **UniBuddy** project

2. **Navigate to Rules Editor**
   - Sidebar → **Firestore Database**
   - Click **Rules** tab

3. **Replace Rules**
   - Click **Edit** button
   - Select ALL text (Ctrl+A)
   - Delete it
   - Open: `firestore.rules` file in this repo
   - Copy ALL content
   - Paste into Firebase console

4. **Publish**
   - Click **Publish** button
   - Wait for green "Rules Published" message

✅ **Step 1 Complete!**

---

## ✅ STEP 2: Import Study Groups Data (2 minutes)

### What This Does
Populates Firestore with 3 demo study groups, members, and sessions.

### Instructions

1. **Go to Firestore Data**
   - In Firebase Console
   - Click **Data** tab (next to Rules)

2. **Import Collection**
   - Look for **⋮ (three dots)** button near top
   - Click it
   - Select **Import Collection**

3. **Select File**
   - Browse to: `firestore_sample_data.json`
   - This file is in the repo directory
   - Click **Open**

4. **Confirm Import**
   - Click **Import**
   - Confirm on the dialog
   - Wait for "Import complete!" message

✅ **Step 2 Complete!**

---

## ✅ STEP 3: Verify Everything Works (1 minute)

### Check Firestore Console

You should now see in the data tab:

```
Collections:
├── study_groups/         ← 3 groups here
│   ├── sg_001_flutter_basics
│   ├── sg_002_web_development
│   └── sg_003_python_programming
├── users/                ← Multiple users
└── notifications/        ← Will fill when app sends alerts
```

### Check Your Flutter App

1. **Refresh the app** (or hard reload in Chrome)
   ```
   Flutter: Hot reload
   ```

2. **You should see**
   - Study groups loading from Firebase (not mock data)
   - 3 study groups displayed
   - Member counts accurate
   - Session info populated

---

## 🎉 Success Checklist

- [ ] Rules deployed (green checkmark in Firebase Console)
- [ ] Data imported (3 collections visible)
- [ ] App reloaded
- [ ] Study groups appear in app
- [ ] Can click on groups to see details
- [ ] Member list shows (Alice, Bob, Carol, etc.)
- [ ] Sessions are visible

---

## 📊 What Data You Now Have

### Study Groups (3 total)
1. **Flutter Basics** (5 members)
   - Level: Beginner
   - Creator: Alice Johnson
   - Sessions: 2 scheduled
   - Resources: 2 links

2. **Web Development** (3 members)
   - Level: Intermediate
   - Creator: Carol Williams
   - Sessions: 1 scheduled
   - Resources: None yet

3. **Python Programming**
   - Level: Various
   - Multiple sessions
   - Community-built resources

### Users (10+ demo accounts)
- Alice Johnson (admin of Flutter group)
- Bob Smith
- Carol Williams
- David Brown
- Emma Davis
- Frank Miller
- Grace Lee
- + 3 more users

### Real-time Features
- Study sessions with schedules
- Member join timestamps
- Resources library per group
- Notification system ready

---

## 🔧 Troubleshooting

### "I don't see any data in the app"

**Solution:**
1. Make sure rules published (green checkmark)
2. Make sure import finished (no "Importing..." message)
3. Hard refresh browser: `Ctrl+Shift+R` or `Cmd+Shift+R`
4. Check browser console for errors (F12)

### "Rules won't publish - Getting errors"

**Solution:**
- Open the `firestore.rules` file
- Check that it's valid Firestore syntax
- Look at error message in red
- Common errors:
  - Missing semicolons
  - Typos in collection names
  - Missing braces `{}`

### "Import says 'No data imported'"

**Solution:**
- Check file path: `firestore_sample_data.json`
- Make sure file is in correct format (valid JSON)
- Try importing just one collection first
- Check Firebase quota (free tier has limits)

### "App loads but shows 'No groups'"

**Solution:**
1. Check Firestore Console - does data appear?
2. If yes in console but not in app:
   - Clear app cache: `flutter clean`
   - Rebuild: `flutter pub get` then `flutter run -d chrome`

---

## 🚀 Next Steps (Optional)

### Test Live Features

Once importing is done, try:

1. **Create a New Group**
   - Click **+ Create Study Group**
   - Fill in details
   - Check Firestore - new doc should appear

2. **Join a Group**
   - Click a group
   - Click **Join**
   - Member count updates

3. **Request a Session**
   - In group details
   - Click **Request Session**
   - See request in Firestore

### Connect Your Other Team's Features

Now that backend is live, Silomy and Kushani can:
- Query `users` collection for profiles
- Add notifications to `notifications` collection
- Link resources to study groups

---

## 📞 Help & Support

**Still stuck?**

Check these guide files:
- `FIRESTORE_RULES_DEPLOYMENT.md` - Detailed rules guide
- `FIRESTORE_SAMPLE_DATA_SETUP.md` - Detailed import guide
- `DEPLOY_FIRESTORE.md` - For automated deployment

**Firebase Resources:**
- [Firestore Docs](https://firebase.google.com/docs/firestore)
- [Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)
- [Import/Export Data](https://firebase.google.com/docs/firestore/manage-data/export-import)

---

## ✨ You're All Set!

Your UniBuddy Study Groups backend is now **live and ready**! 🎊

The app will now:
- Pull study groups from Firestore
- Display live member counts
- Show real sessions
- Update in real-time
- Integrate with team features

Happy coding! 🚀
