#!/usr/bin/env bash
set -euo pipefail

# Build a Windows bundle on macOS
# Requirements: brew install mingw-w64

ROOT_DIR="$(cd "$(dirname "$0")"/.. && pwd)"
OUT_DIR="$ROOT_DIR/dist/win64"
MINGW_DIR="$OUT_DIR/mingw64"
JUDGE_EXE="$OUT_DIR/judge.exe"
MAIN_CPP="$ROOT_DIR/main.cpp"

mkdir -p "$OUT_DIR"

: "${CROSS_GPP:=x86_64-w64-mingw32-g++}"

# Check if cross-compiler exists
if ! command -v "$CROSS_GPP" &> /dev/null; then
    echo "Error: $CROSS_GPP not found. Please install with: brew install mingw-w64" >&2
    exit 1
fi

# 1) Cross-compile judge.exe
echo "[1/3] Compiling judge.exe for Windows (x86_64)..."
"$CROSS_GPP" -O2 -std=c++17 -static-libgcc -static-libstdc++ -o "$JUDGE_EXE" "$MAIN_CPP"

if [ ! -f "$JUDGE_EXE" ]; then
    echo "Error: Compilation failed!" >&2
    exit 1
fi

echo "✓ Compilation OK: $JUDGE_EXE"

# 2) Download portable MinGW toolchain if not exists
if [ ! -d "$MINGW_DIR" ]; then
  echo "[2/3] Downloading portable MinGW toolchain (WinLibs)..."
  
  # Use a working download link - WinLibs UCRT runtime
  MINGW_URL="https://github.com/niXman/mingw-builds-binaries/releases/download/13.2.0-rt_v11-rev0/winlibs-x86_64-posix-seh-gcc-13.2.0-mingw-w64ucrt-11.0.0-r0.7z"
  MINGW_ARCHIVE="$OUT_DIR/mingw.7z"
  
  echo "  Downloading from GitHub releases..."
  if command -v curl >/dev/null 2>&1; then
    curl -L "$MINGW_URL" -o "$MINGW_ARCHIVE"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$MINGW_ARCHIVE" "$MINGW_URL"
  else
    echo "Error: curl or wget is required." >&2
    exit 1
  fi
  
  # Check if download succeeded (file should be larger than 100KB)
  if [ ! -f "$MINGW_ARCHIVE" ] || [ $(stat -f%z "$MINGW_ARCHIVE") -lt 100000 ]; then
    echo "Error: Download failed or file is too small." >&2
    echo "Please download MinGW manually from:" >&2
    echo "  https://github.com/niXman/mingw-builds-binaries/releases" >&2
    exit 1
  fi
  
  echo "  Extracting (using 7z or unzip)..."
  
  # Try to extract with 7z (if available)
  if command -v 7z >/dev/null 2>&1; then
    7z x "$MINGW_ARCHIVE" -o"$OUT_DIR" -y
  elif command -v 7za >/dev/null 2>&1; then
    7za x "$MINGW_ARCHIVE" -o"$OUT_DIR" -y
  else
    echo "Error: 7z not found. Install with: brew install p7zip" >&2
    exit 1
  fi
  
  # Find extracted mingw64 folder
  if [ ! -d "$MINGW_DIR" ]; then
    EXTRACTED=$(find "$OUT_DIR" -maxdepth 2 -name "mingw64" -type d | head -n1)
    if [ -n "$EXTRACTED" ]; then
      mv "$EXTRACTED" "$MINGW_DIR"
    else
      echo "Error: mingw64 directory not found after extraction." >&2
      exit 1
    fi
  fi
  
  # Clean up
  rm -f "$MINGW_ARCHIVE"
  # Remove any extra extracted folders
  find "$OUT_DIR" -maxdepth 1 -type d -not -name "mingw64" -not -path "$OUT_DIR" -exec rm -rf {} + 2>/dev/null || true
  
  echo "✓ MinGW toolchain installed"
else
  echo "[2/3] ✓ Reusing existing MinGW at $MINGW_DIR"
fi

# Verify g++.exe exists
if [ ! -f "$MINGW_DIR/bin/g++.exe" ]; then
  echo "Error: g++.exe not found at $MINGW_DIR/bin/g++.exe" >&2
  exit 1
fi

# 3) Copy runtime DLLs next to judge.exe
echo "[3/3] Copying runtime DLLs..."

RUNTIME_DLLS=(
  libstdc++-6.dll
  libgcc_s_seh-1.dll
  libwinpthread-1.dll
)

for dll in "${RUNTIME_DLLS[@]}"; do
  SRC="$MINGW_DIR/bin/$dll"
  if [ -f "$SRC" ]; then
    cp -f "$SRC" "$OUT_DIR/"
    echo "  ✓ Copied: $dll"
  fi
done

# Create README
cat > "$OUT_DIR/README.txt" << 'EOF'
===============================================
       JoJudge - C++ Problem Judger
===============================================

CONTENTS:
---------
- judge.exe         : The main judger application
- mingw64/          : Portable GCC compiler toolchain
- *.dll             : Required runtime libraries

USAGE ON WINDOWS:
-----------------
1. Copy this entire folder to any Windows PC
2. Double-click judge.exe (or run from Command Prompt)
3. Select problem ID (1, 2, or 3)
4. Enter the full path to student's .cpp file
5. View test results

PROBLEMS:
---------
Problem 1: A. Holiday Of Equality
  • Input: n, then n welfare values
  • Output: Minimum cost to equalize all to max

Problem 2: A. Odd Set  
  • Input: t test cases, each with n and 2n integers
  • Output: "Yes" if pairs can sum to odd, else "No"

Problem 3: A. Plus or Minus
  • Input: t test cases, each with a, b, c
  • Output: "+" if a+b=c, else "-"

NOTES:
------
- No installation needed
- Works on any Windows 7/8/10/11 (64-bit)
- judge.exe automatically uses bundled compiler
- Compiled student code is temporary and auto-deleted

For issues, check that:
  ✓ mingw64/bin/g++.exe exists
  ✓ All DLL files are present
  ✓ Student .cpp file path is correct
EOF

echo ""
echo "=========================================="
echo "✓ BUILD COMPLETE!"
echo "=========================================="
echo ""
echo "Bundle location: $OUT_DIR"
echo ""
echo "Next steps:"
echo "  1. Copy 'dist/win64' folder to Windows PC"
echo "  2. Run judge.exe"
echo "  3. Test with student solutions"
echo ""
echo "The bundle includes:"
echo "  - judge.exe"
echo "  - mingw64/ (portable compiler)"
echo "  - Runtime DLLs"
echo "  - README.txt"
echo ""
