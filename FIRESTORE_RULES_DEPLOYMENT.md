# Firestore Security Rules Deployment Guide

## Overview
The `firestore.rules` file contains security rules for your Firestore database. These rules control who can read and write data to your database.

## Current Security Rules Structure

### Collections Protected:
1. **study_groups** - Study group documents (public read, authenticated create/update/delete)
   - members (subcollection) - Group members
   - sessions (subcollection) - Study sessions
   - resources (subcollection) - Study materials

2. **users** - User profiles (private read/write)

3. **notifications** - User notifications (private read/write)

## Deploying Security Rules

### Option 1: Firebase Console (GUI - Recommended for first-time setup)

1. **Open Firebase Console:**
   - Go to https://console.firebase.google.com
   - Select your project: `unibuddy-785ab`

2. **Navigate to Firestore Rules:**
   - Click on "Firestore Database" in the left sidebar
   - Click the "Rules" tab at the top

3. **Copy and Paste Rules:**
   - Copy the entire content from `firestore.rules`
   - Delete the default rules in the console
   - Paste the new rules

4. **Publish Rules:**
   - Click the "Publish" button in the top right
   - Wait for confirmation message

### Option 2: Firebase CLI (Command-line - For automation)

1. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase:**
   ```bash
   firebase login
   ```

3. **Initialize Firebase in your project:**
   ```bash
   firebase init firestore
   ```
   - Select your project: `unibuddy-785ab`
   - Keep firestore.rules as the rules filename

4. **Deploy Rules:**
   ```bash
   firebase deploy --only firestore:rules
   ```

### Option 3: Rename File for Firebase CLI

Firebase CLI automatically looks for `firestore.rules` or `firestore.json`:

1. Ensure `firestore.rules` is in your project root
2. Create a `firebase.json` file with:
   ```json
   {
     "firestore": {
       "rules": "firestore.rules"
     }
   }
   ```

## Testing Rules in Development

### Development/Testing Mode:
If you need permissive rules for testing:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // WARNING: ONLY FOR DEVELOPMENT/TESTING
    // Allow read and write for all
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **IMPORTANT**: Always use strict rules in production!

## Production Checklist

Before deploying to production:

- [ ] Test rules with authentication enabled
- [ ] Verify read permissions are restricted appropriately
- [ ] Confirm write permissions require authentication
- [ ] Test with your exact data structure
- [ ] Backup existing rules before deploying
- [ ] Monitor Firestore logs for rule violations

## Firestore Rules Documentation

For more help and advanced rules, see:
- https://firebase.google.com/docs/firestore/security/start
- https://firebase.google.com/docs/firestore/security/rules-query
- https://firebase.google.com/docs/firestore/security/rules-conditions

## Common Issues

### Issue: "Permission denied" when reading/writing

**Solution:** Check if you have authentication uid as request.auth.uid. Ensure:
1. User is logged in (request.auth != null)
2. User ID matches the required field (request.auth.uid)
3. Rules don't have conflicting conditions

### Issue: "Rules rejected" error in console

**Solution:** Check for syntax errors:
1. Validate JSON format
2. Ensure semicolons end statements
3. Check function parameter references

### Issue: Can't create Firestore documents

**Solution:** Ensure:
1. User is authenticated
2. New document has required fields per rules
3. User ID matches createdBy field

## Rules Explanation

### Public Read + Authenticated Write Pattern
```bash
allow read: if true;                    # Anyone can read
allow create: if isAuthenticated();     # Only logged-in users can create
allow update, delete: if isOwner(uid);  # Only owner can modify
```

This is used for study_groups to allow discovery while protecting modifications.

### Private Pattern
```bash
allow read, write: if isOwner(userId);  # Only the user can access their own data
```

This is used for users collection to protect personal profiles.

## Next Steps

1. ✅ Deploy the rules to Firebase Console
2. Test the app on Chrome - rules are already applied
3. Create sample Firestore data (see FIRESTORE_SAMPLE_DATA.md)
4. Update data models in your app to use Firestore services
5. Monitor security rules metrics in Firebase Console
