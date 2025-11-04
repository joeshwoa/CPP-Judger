#!/usr/bin/env bash
set -e

echo "=========================================="
echo "  C++ Judge GUI - macOS Testing Setup"
echo "=========================================="
echo ""

# Check if g++ is available
if command -v g++ &> /dev/null; then
    echo "✓ g++ compiler found: $(which g++)"
    g++ --version | head -n1
else
    echo "✗ g++ compiler not found"
    echo ""
    echo "Installing Xcode Command Line Tools..."
    echo "This is required to compile C++ code on macOS."
    echo ""
    xcode-select --install
    echo ""
    echo "After installation completes, run this script again."
    exit 1
fi

echo ""
echo "✓ Ready to test!"
echo ""
echo "To run the app:"
echo "  cd cpp_judge"
echo "  flutter run -d macos"
echo ""
echo "Note: The app will use your macOS g++ compiler."
echo "On Windows, it will automatically use the bundled mingw64."
echo ""
