#!/usr/bin/env python3
"""
Firestore Deployment Script for UniBuddy Backend
Deploys security rules and imports sample data to Firebase Cloud Firestore

Requirements:
  - service-account-key.json in the same directory
  - firebase-admin Python package

Usage:
  python deploy_firestore.py
"""

import json
import sys
from pathlib import Path

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    print("❌ firebase-admin not installed. Install with:")
    print("   pip install firebase-admin")
    sys.exit(1)


def load_credentials():
    """Load Firebase service account credentials."""
    cred_path = Path("service-account-key.json")
    if not cred_path.exists():
        print("❌ Error: service-account-key.json not found")
        print("\nTo get your service account key:")
        print("  1. Go to Firebase Console → Project Settings → Service Accounts")
        print("  2. Click 'Generate New Private Key'")
        print("  3. Save it as 'service-account-key.json' in this directory")
        sys.exit(1)
    
    cred = credentials.Certificate(str(cred_path))
    return cred


def deploy_firestore():
    """Deploy Firestore rules and import sample data."""
    print("🚀 Starting Firestore deployment...\n")
    
    # Load credentials
    print("[1/3] Loading Firebase credentials...")
    cred = load_credentials()
    
    # Initialize Firebase
    try:
        firebase_admin.initialize_app(cred)
        print("✅ Firebase initialized\n")
    except ValueError:
        print("✅ Firebase already initialized\n")
    
    # Get Firestore client
    db = firestore.client()
    print("[2/3] Deploying Firestore security rules...")
    print("⚠️  Note: Rules must be deployed manually in Firebase Console")
    print("     See: DEPLOY_FIRESTORE.md for steps\n")
    
    # Load sample data
    print("[3/3] Importing sample data to Firestore...")
    sample_data_path = Path("firestore_sample_data.json")
    
    if not sample_data_path.exists():
        print("❌ Error: firestore_sample_data.json not found")
        sys.exit(1)
    
    with open(sample_data_path, 'r') as f:
        sample_data = json.load(f)
    
    # Import study groups
    study_groups = sample_data.get("study_groups", {})
    print(f"Importing {len(study_groups)} study groups...")
    
    for group_id, group_data in study_groups.items():
        try:
            # Add main group document
            db.collection("study_groups").document(group_id).set(group_data)
            print(f"  ✅ Imported: {group_data.get('name', group_id)}")
        except Exception as e:
            print(f"  ❌ Failed to import {group_id}: {e}")
    
    # Import users
    users = sample_data.get("users", {})
    print(f"\nImporting {len(users)} users...")
    
    for user_id, user_data in users.items():
        try:
            db.collection("users").document(user_id).set(user_data)
            print(f"  ✅ Imported user: {user_data.get('name', user_id)}")
        except Exception as e:
            print(f"  ❌ Failed to import user {user_id}: {e}")
    
    # Import notifications
    notifications = sample_data.get("notifications", {})
    if notifications:
        print(f"\nImporting {len(notifications)} notifications...")
        for notif_id, notif_data in notifications.items():
            try:
                db.collection("notifications").document(notif_id).set(notif_data)
                print(f"  ✅ Imported notification: {notif_id}")
            except Exception as e:
                print(f"  ❌ Failed to import notification {notif_id}: {e}")
    
    print("\n" + "="*60)
    print("✅ Firestore deployment complete!")
    print("="*60)
    print("\n📊 Summary:")
    print(f"  • Study Groups: {len(study_groups)}")
    print(f"  • Users: {len(users)}")
    print(f"  • Sessions: (nested in groups)")
    print(f"  • Resources: (nested in groups)")
    
    print("\n🔐 Important: Don't forget to deploy security rules!")
    print("   See DEPLOY_FIRESTORE.md for manual Firebase Console steps\n")


if __name__ == "__main__":
    try:
        deploy_firestore()
    except Exception as e:
        print(f"❌ Deployment failed: {e}")
        sys.exit(1)
