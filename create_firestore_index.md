# Firestore Index Creation Guide

## Required Index for Inbox Items Query

Your app is trying to run a query that requires a composite index. The error message provides a direct link to create the index.

### The Query That Needs an Index

The query in `inbox_service.dart` that requires an index:

```dart
return _firestore
    .collection('inbox_items')
    .where('userId', isEqualTo: _userId)
    .where('isProcessed', isEqualTo: false)
    .orderBy('createdAt', descending: true)
    .snapshots()
```

### How to Create the Index

1. **Click the direct link** from the error message:
   ```
   https://console.firebase.google.com/v1/r/project/adhd-svedin/firestore/indexes?create_composite=Ck9wcm9qZWN0cy9hZGhkLXN2ZWRpbi9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvaW5ib3hfaXRlbXMvaW5kZXhlcy9fEAEaDwoLaXNQcm9jZXNzZWQQARoKCgZ1c2VySWQQARoNCgljcmVhdGVkQXQQAhoMCghfX25hbWVfXxAC
   ```

2. **Or manually create the index** in Firebase Console:
   - Go to [Firebase Console](https://console.firebase.google.com/project/adhd-svedin/firestore/indexes)
   - Click "Create Index"
   - Collection ID: `inbox_items`
   - Fields to index:
     - `isProcessed` (Ascending)
     - `userId` (Ascending) 
     - `createdAt` (Descending)
   - Query scope: Collection

### Alternative: Create Index via Firebase CLI

If you have Firebase CLI installed:

```bash
# Install Firebase CLI if you haven't already
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project (if not already done)
firebase init firestore

# Create the index
firebase deploy --only firestore:indexes
```

### Index Configuration

The index should have these settings:
- **Collection**: `inbox_items`
- **Fields**:
  1. `isProcessed` (Ascending)
  2. `userId` (Ascending)
  3. `createdAt` (Descending)

### After Creating the Index

1. Wait for the index to build (this can take a few minutes)
2. The error should disappear once the index is ready
3. Your inbox query will work properly

### Note

- Index building can take 1-5 minutes depending on the size of your collection
- You can monitor the index status in the Firebase Console under Firestore > Indexes
- The index will be automatically used by Firestore once it's built 