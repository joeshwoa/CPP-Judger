#!/usr/bin/env bash
set -euo pipefail

# Build a Windows bundle on macOS:
# - Cross-compile judge.exe using Homebrew mingw-w64
# - Download a portable WinLibs MinGW toolchain and place it next to judge.exe
# - Copy required runtime DLLs next to judge.exe so it runs on any Windows PC

# Requirements (install manually if missing):
#   brew install mingw-w64
#   curl or wget, and unzip

ROOT_DIR="$(cd "$(dirname "$0")"/.. && pwd)"
OUT_DIR="$ROOT_DIR/dist/win64"
MINGW_DIR="$OUT_DIR/mingw64"
JUDGE_EXE="$OUT_DIR/judge.exe"
MAIN_CPP="$ROOT_DIR/main.cpp"

mkdir -p "$OUT_DIR"

: "${CROSS_GPP:=x86_64-w64-mingw32-g++}"
: "${WINLIBS_ZIP_URL:=https://github.com/brechtsanders/winlibs_mingw/releases/download/15.2.0posix-13.0.0-ucrt-r3/winlibs-x86_64-posix-seh-gcc-15.2.0-mingw-w64ucrt-13.0.0-r3.zip}" #: "${WINLIBS_ZIP_URL:=https://github.com/brechtsanders/winlibs_mingw/releases/download/13.2.0-rt_9.0.0-20231006/winlibs-x86_64-posix-seh-gcc-13.2.0-llvm-17.0.1-mingw-w64ucrt-11.0.0-r1.zip}"
: "${WINLIBS_ZIP_NAME:=winlibs-mingw64.zip}"

# 1) Cross-compile judge.exe
echo "[1/3] Compiling judge.exe for Windows (x86_64)..."
"$CROSS_GPP" -O2 -std=c++17 -static-libgcc -static-libstdc++ -o "$JUDGE_EXE" "$MAIN_CPP"

echo "Compilation OK: $JUDGE_EXE"

# 2) Download WinLibs portable toolchain containing g++.exe
if [ ! -d "$MINGW_DIR" ]; then
  echo "[2/3] Downloading WinLibs MinGW toolchain..."
  TMP_ZIP="$OUT_DIR/$WINLIBS_ZIP_NAME"
  if command -v curl >/dev/null 2>&1; then
    curl -L "$WINLIBS_ZIP_URL" -o "$TMP_ZIP"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$TMP_ZIP" "$WINLIBS_ZIP_URL"
  else
    echo "Error: curl or wget is required to download WinLibs." >&2
    exit 1
  fi

  echo "Extracting..."
  unzip -q "$TMP_ZIP" -d "$OUT_DIR"
  # Find extracted mingw64 folder
  EXTRACTED_MINGW="$(find "$OUT_DIR" -maxdepth 2 -type d -name mingw64 | head -n1)"
  if [ -z "$EXTRACTED_MINGW" ]; then
    echo "Error: mingw64 directory not found after extraction." >&2
    exit 1
  fi
  mv "$EXTRACTED_MINGW" "$MINGW_DIR"
  # Clean other extracted files/dirs if present
  find "$OUT_DIR" -maxdepth 1 -mindepth 1 -not -name "mingw64" -not -name "judge.exe" -not -name "$(basename "$WINLIBS_ZIP_NAME")" -exec rm -rf {} + || true
  rm -f "$TMP_ZIP"
else
  echo "[2/3] Reusing existing $MINGW_DIR"
fi

# 3) Copy required runtime DLLs next to judge.exe (for portability)
# These names are typical for WinLibs UCRT builds; adjust if needed.
RUNTIME_DLLS=(
  libstdc++-6.dll
  libgcc_s_seh-1.dll
  libwinpthread-1.dll
)

echo "[3/3] Copying runtime DLLs next to judge.exe..."
for dll in "${RUNTIME_DLLS[@]}"; do
  SRC="$MINGW_DIR/bin/$dll"
  if [ -f "$SRC" ]; then
    cp -f "$SRC" "$OUT_DIR/"
  else
    echo "Warning: $dll not found in $MINGW_DIR/bin (judge.exe may still work if statically linked)."
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
   - 2: A. Plus or Minus
4) Paste the full path to the student's .cpp file when prompted.
5) The judger compiles with the bundled mingw64\bin\g++.exe and runs official tests.

Note: judge.exe resolves g++ as .\mingw64\bin\g++.exe relative to its own location.
EOF

echo "Done. Bundle ready at: $OUT_DIR"




