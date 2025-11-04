#!/usr/bin/env bash
set -euo pipefail

# Complete build script that creates both CLI and GUI judges bundled with MinGW

ROOT_DIR="$(cd "$(dirname "$0")"/.. && pwd)"
FLUTTER_DIR="$ROOT_DIR/cpp_judge"
DIST_DIR="$ROOT_DIR/dist/win64"
MINGW_DIR="$DIST_DIR/mingw64"

echo "=========================================="
echo "  C++ Judge - Complete Build Script"
echo "=========================================="
echo ""

# 1) Build CLI judge.exe
echo "[1/4] Building CLI judge (judge.exe)..."
cd "$ROOT_DIR"
bash scripts/build_bundle.sh
echo "✓ CLI judge built successfully"
echo ""

# 2) Build Flutter GUI
echo "[2/4] Building Flutter GUI (judge_gui.exe)..."
cd "$FLUTTER_DIR"

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter not found. Please install Flutter and add it to PATH." >&2
    exit 1
fi

# Build Windows release
flutter build windows --release

if [ ! -f "build/windows/x64/runner/Release/judge_gui.exe" ]; then
    echo "Error: Flutter build failed - judge_gui.exe not found" >&2
    exit 1
fi

echo "✓ Flutter GUI built successfully"
echo ""

# 3) Copy GUI to dist folder
echo "[3/4] Copying GUI to distribution folder..."
mkdir -p "$DIST_DIR/gui"

# Copy all files from Flutter build
cp -R "$FLUTTER_DIR/build/windows/x64/runner/Release/"* "$DIST_DIR/gui/"

echo "✓ GUI copied to $DIST_DIR/gui"
echo ""

# 4) Create unified bundle structure
echo "[4/4] Creating final bundle structure..."

# Create README for the complete bundle
cat > "$DIST_DIR/README_COMPLETE.txt" << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║           C++ Judge - Complete Bundle                        ║
║              CLI + GUI + Compiler                            ║
╚══════════════════════════════════════════════════════════════╝

📦 CONTENTS
-----------
This bundle contains TWO ways to use the judge:

1. GUI Version (Recommended for Students)
   📁 gui/
   └── judge_gui.exe    ← Modern graphical interface

2. CLI Version (Command Line)
   📁 (root folder)
   └── judge.exe        ← Text-based interface

3. Compiler Toolchain
   📁 mingw64/
   └── Portable GCC compiler (used by both versions)

═══════════════════════════════════════════════════════════════

🚀 QUICK START - GUI VERSION
-----------------------------
1. Open the 'gui' folder
2. Double-click 'judge_gui.exe'
3. Enjoy the modern interface with:
   • Drag-and-drop file support
   • Built-in code editor with syntax highlighting
   • Real-time test results
   • Problem statement viewer

Features:
✓ Select problem from dropdown
✓ Read problem description in-app
✓ Write code directly in the editor
✓ OR drag-and-drop your .cpp file
✓ OR use "Open File" button
✓ Click "Submit" to run tests
✓ See detailed results with pass/fail status

═══════════════════════════════════════════════════════════════

🖥️  ALTERNATIVE - CLI VERSION
------------------------------
1. Double-click 'judge.exe' in the root folder
2. Follow the text prompts:
   • Enter problem number (1, 2, or 3)
   • Enter full path to your .cpp file
   • View results

Good for:
• Users who prefer command-line tools
• Automated testing scripts
• Headless/server environments

═══════════════════════════════════════════════════════════════

📚 PROBLEMS AVAILABLE
---------------------
1. A. Holiday Of Equality
   Find minimum cost to equalize welfare
   
2. A. Odd Set
   Check if numbers can be paired with odd sums
   
3. A. Plus or Minus
   Determine if a+b=c or a-b=c

═══════════════════════════════════════════════════════════════

💡 TIPS & TRICKS
----------------
GUI Version:
• Use Ctrl+Z / Ctrl+Y to undo/redo in editor
• Switch between Problem/Code/Results tabs
• Results show exactly where your code failed
• You can keep the app open and resubmit multiple times

CLI Version:
• Use absolute file paths (C:\Users\...)
• Check compile_errors.txt if compilation fails
• Press 'n' to exit after viewing results

Both Versions:
• Work offline (no internet needed)
• No installation required
• Portable - works on any Windows PC
• Same test cases used for fair grading

═══════════════════════════════════════════════════════════════

⚠️  TROUBLESHOOTING
-------------------
If GUI doesn't start:
→ Make sure all .dll files are in gui/ folder
→ Try running from Command Prompt to see errors
→ Check Windows Defender didn't block it

If compilation fails:
→ Check your code syntax
→ Verify mingw64/bin/g++.exe exists
→ Look at compile errors in the results

If tests fail but code seems correct:
→ Check output format (spaces, newlines)
→ Compare with example input/output
→ Test with the provided examples first

═══════════════════════════════════════════════════════════════

📊 SYSTEM REQUIREMENTS
----------------------
• Windows 7/8/10/11 (64-bit)
• ~1 GB free disk space
• No additional software needed

═══════════════════════════════════════════════════════════════

🎓 FOR INSTRUCTORS
------------------
• Both judge.exe and judge_gui.exe use identical test cases
• Results are deterministic and consistent
• You can distribute either version or both
• Students can choose their preferred interface
• All submissions are tested fairly

To add this to lab computers:
1. Copy entire 'win64' folder to C:\JoJudge
2. Tell students to run either:
   - C:\JoJudge\gui\judge_gui.exe (GUI)
   - C:\JoJudge\judge.exe (CLI)

═══════════════════════════════════════════════════════════════

Version 1.0 - Built with ❤️ for C++ students
EOF

echo "✓ Bundle structure created"
echo ""

# Display summary
echo "=========================================="
echo "✓ BUILD COMPLETE!"
echo "=========================================="
echo ""
echo "Bundle location: $DIST_DIR"
echo ""
echo "Contents:"
echo "  • judge.exe           (CLI version)"
echo "  • gui/judge_gui.exe   (GUI version)"
echo "  • mingw64/            (Compiler toolchain)"
echo "  • Documentation files"
echo ""
echo "Bundle size:"
du -sh "$DIST_DIR"
echo ""
echo "Ready to deploy! Copy the 'win64' folder to Windows PCs."
echo ""
echo "Students can use:"
echo "  1. gui/judge_gui.exe  (Recommended - Modern UI)"
echo "  2. judge.exe          (Alternative - CLI)"
echo ""
