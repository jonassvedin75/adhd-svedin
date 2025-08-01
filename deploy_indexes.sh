#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Deploy Firestore indexes
echo "Deploying Firestore indexes..."
firebase deploy --only firestore:indexes

echo "✅ Firestore indexes deployed successfully."
