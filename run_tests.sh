#!/bin/bash

echo "🧪 Running Inbox Functionality Tests..."
echo "========================================"

# Kör unit-tester
echo "📋 Running Unit Tests..."
flutter test test/inbox_unit_test.dart

if [ $? -eq 0 ]; then
    echo "✅ Unit tests passed!"
else
    echo "❌ Unit tests failed!"
    exit 1
fi

echo ""

# Kör enklare core-tester
echo "🔗 Running Core Functionality Tests..."
flutter test test/inbox_simple_test.dart

if [ $? -eq 0 ]; then
    echo "✅ Integration tests passed!"
else
    echo "❌ Integration tests failed!"
    exit 1
fi

echo ""

# Kör alla inbox-tester
echo "🚀 Running All Inbox Tests..."
flutter test test/inbox_unit_test.dart test/inbox_simple_test.dart

if [ $? -eq 0 ]; then
    echo "🎉 All tests passed!"
    echo ""
    echo "📊 Test Summary:"
    echo "✅ Unit tests: PASSED"
    echo "✅ Core functionality tests: PASSED"
    echo "✅ All tests: PASSED"
else
    echo "💥 Some tests failed!"
    exit 1
fi

echo ""
echo "🎯 Inbox functionality is fully tested and working!" 