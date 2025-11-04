#!/usr/bin/env bash
set -euo pipefail

# Build a Windows bundle on macOS using locally downloaded MinGW:
# - Cross-compile judge.exe using Homebrew mingw-w64
# - Copy your local MinGW toolchain next to judge.exe
# - Copy required runtime DLLs next to judge.exe so it runs on any Windows PC

# Requirements:
#   brew install mingw-w64

ROOT_DIR="$(cd "$(dirname "$0")"/.. && pwd)"
OUT_DIR="$ROOT_DIR/dist/win64"
MINGW_DIR="$OUT_DIR/mingw64"
JUDGE_EXE="$OUT_DIR/judge.exe"
MAIN_CPP="$ROOT_DIR/main.cpp"

# Path to your manually downloaded MinGW
LOCAL_MINGW_PATH="/Volumes/PortableSSD/Files/mingw-w64-v11.0.0"

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

echo "Compilation OK: $JUDGE_EXE"

# 2) Copy local MinGW toolchain
if [ ! -d "$MINGW_DIR" ]; then
  echo "[2/3] Copying MinGW toolchain from $LOCAL_MINGW_PATH..."
  
  if [ ! -d "$LOCAL_MINGW_PATH" ]; then
    echo "Error: MinGW not found at $LOCAL_MINGW_PATH" >&2
    echo "Please update LOCAL_MINGW_PATH in this script to point to your MinGW installation." >&2
    exit 1
  fi
  
  # Check if there's a mingw64 subdirectory
  if [ -d "$LOCAL_MINGW_PATH/mingw64" ]; then
    cp -R "$LOCAL_MINGW_PATH/mingw64" "$MINGW_DIR"
  else
    # If the path itself is mingw64, copy its contents
    mkdir -p "$MINGW_DIR"
    cp -R "$LOCAL_MINGW_PATH"/* "$MINGW_DIR/"
  fi
  
  echo "MinGW toolchain copied successfully."
else
  echo "[2/3] Reusing existing $MINGW_DIR"
fi

# Verify g++.exe exists
if [ ! -f "$MINGW_DIR/bin/g++.exe" ]; then
  echo "Error: g++.exe not found at $MINGW_DIR/bin/g++.exe" >&2
  echo "Please check your MinGW installation structure." >&2
  exit 1
fi

# 3) Copy required runtime DLLs next to judge.exe (for portability)
echo "[3/3] Copying runtime DLLs next to judge.exe..."

# List of common runtime DLLs - copy if they exist
RUNTIME_DLLS=(
  libstdc++-6.dll
  libgcc_s_seh-1.dll
  libgcc_s_dw2-1.dll
  libwinpthread-1.dll
)

for dll in "${RUNTIME_DLLS[@]}"; do
  SRC="$MINGW_DIR/bin/$dll"
  if [ -f "$SRC" ]; then
    cp -f "$SRC" "$OUT_DIR/"
    echo "  Copied: $dll"
  fi
done

cat > "$OUT_DIR/README.txt" << 'EOF'
JoJudge Windows Bundle
======================

This folder contains:
- judge.exe (the judger)
- mingw64\bin\g++.exe (portable compiler used by judge.exe)
- Required runtime DLLs next to judge.exe

How to use on Windows:
1) Place student C++ file on the PC (e.g., Desktop\student.cpp).
2) Double-click judge.exe (or run from CMD/PowerShell).
3) Choose problem ID:
   - 1: A. Holiday Of Equality
   - 2: A. Odd Set
   - 3: A. Plus or Minus
4) Paste the full path to the student's .cpp file when prompted.
5) The judger compiles with the bundled mingw64\bin\g++.exe and runs official tests.

Note: judge.exe resolves g++ as .\mingw64\bin\g++.exe relative to its own location.

Problems Description:
---------------------
Problem 1: A. Holiday Of Equality
  Input: n, then n integers (welfare values)
  Output: Minimum cost to equalize all to the maximum value
  
Problem 2: A. Odd Set
  Input: t (test cases), for each: n, then 2n integers
  Output: "Yes" if can pair elements so each pair sums to odd, "No" otherwise
  
Problem 3: A. Plus or Minus
  Input: t (test cases), for each: a, b, c
  Output: "+" if a+b=c, "-" if a-b=c
EOF

echo ""
echo "================================================================"
echo "Bundle complete! Location: $OUT_DIR"
echo "================================================================"
echo ""
echo "To test on Windows:"
echo "1. Copy the entire 'dist/win64' folder to a Windows PC"
echo "2. Run judge.exe"
echo "3. Select problem ID (1, 2, or 3)"
echo "4. Provide student .cpp file path"
echo ""
