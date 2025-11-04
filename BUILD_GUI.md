# Building the C++ Judge GUI

This guide explains how to build the complete bundle with both CLI and GUI versions of the judge.

## 🎯 What You'll Get

After building, you'll have:
- **judge.exe** - Command-line version (simple text interface)
- **judge_gui.exe** - Modern GUI version (drag-drop, code editor, visual results)
- **mingw64/** - Portable compiler toolchain
- Both apps work standalone on any Windows PC

---

## 📋 Prerequisites

### On macOS (Your Build Machine)

1. **Homebrew packages:**
   ```bash
   brew install mingw-w64 p7zip
   ```

2. **Flutter SDK:**
   ```bash
   # Download Flutter from https://flutter.dev/docs/get-started/install/macos
   # Or use:
   git clone https://github.com/flutter/flutter.git -b stable
   export PATH="$PATH:`pwd`/flutter/bin"
   
   # Verify installation
   flutter doctor
   ```

3. **Flutter Windows Desktop Support:**
   ```bash
   flutter config --enable-windows-desktop
   ```

---

## 🚀 Building the Complete Bundle

### Option 1: Build Everything (Recommended)

```bash
cd /Volumes/PortableSSD/Projects/Python/CPP-Judger-main
chmod +x scripts/build_complete_bundle.sh
bash scripts/build_complete_bundle.sh
```

This script will:
1. Build the CLI judge (judge.exe)
2. Build the Flutter GUI (judge_gui.exe)
3. Bundle both with MinGW compiler
4. Create complete documentation

**Output:** `dist/win64/`

### Option 2: Build GUI Only

If you already have the CLI judge built:

```bash
cd cpp_judge
flutter build windows --release
```

**Output:** `cpp_judge/build/windows/x64/runner/Release/`

---

## 📦 Bundle Structure

After building, `dist/win64/` will contain:

```
win64/
├── judge.exe                    # CLI version
├── gui/                         # GUI version folder
│   ├── judge_gui.exe           # Main GUI executable
│   ├── flutter_windows.dll     # Flutter engine
│   ├── *.dll                   # Other required DLLs
│   └── data/                   # Flutter assets
├── mingw64/                     # Portable compiler
│   └── bin/
│       └── g++.exe
├── README.txt                   # CLI instructions
├── README_COMPLETE.txt          # Full bundle guide
└── QUICK_START.txt              # Quick reference

Total size: ~1 GB
```

---

## 🎨 GUI Features

The Flutter GUI (`judge_gui.exe`) includes:

### Problem Statement Tab
- Full problem description
- Input/output format
- Example test cases
- Time and memory limits
- Notes and explanations

### Code Editor Tab
- **Syntax highlighting** for C++
- **Three ways to input code:**
  1. Type directly in the editor
  2. Open file via file picker button
  3. Drag and drop .cpp file onto window
- Reset button to start fresh
- Dark/light theme (auto-detects system)

### Results Tab
- Real-time compilation feedback
- Test case pass/fail status
- Progress bar showing passed tests
- **Detailed failure info:**
  - Input data
  - Expected output
  - Your output
  - Side-by-side comparison
- Compilation errors (if any)

### UI/UX Features
- Modern Material Design 3
- Responsive layout
- Google Fonts (Roboto)
- Icons and visual feedback
- Smooth animations
- Tab-based navigation

---

## 🧪 Testing Before Deployment

### Test the GUI Locally

Since you're on macOS, you can't run the Windows .exe, but you can:

1. **Test on macOS (for development):**
   ```bash
   cd cpp_judge
   flutter run -d macos
   ```

2. **Test on Windows VM or PC:**
   - Copy `dist/win64/` to Windows
   - Run `gui/judge_gui.exe`
   - Try each feature:
     - Select different problems
     - Paste code and submit
     - Drag-drop a .cpp file
     - View results

3. **Use sample solutions:**
   ```bash
   # Test with provided samples
   samples/problem1_correct.cpp
   samples/problem2_correct.cpp
   samples/problem3_correct.cpp
   ```

---

## 📤 Deployment to Students

### Copy to USB Drive
```bash
cp -R dist/win64 /Volumes/YOUR_USB/JoJudge
```

### Create Zip for Cloud
```bash
cd dist
zip -r JoJudge_Complete.zip win64
# Upload to Google Drive, OneDrive, etc.
```

### Network Share
Place `dist/win64` on a shared drive accessible to students.

---

## 🎓 Student Instructions

### For GUI Users (Recommended)

1. Navigate to the judge folder
2. Open `gui` folder
3. Double-click `judge_gui.exe`
4. Use the visual interface:
   - Select problem
   - Read description
   - Write/load code
   - Submit and view results

### For CLI Users

1. Navigate to the judge folder
2. Double-click `judge.exe`
3. Follow text prompts

---

## 🔧 Troubleshooting Build Issues

### Flutter Not Found
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"

# Verify
flutter --version
```

### Windows Build Fails
```bash
# Clean and rebuild
cd cpp_judge
flutter clean
flutter pub get
flutter build windows --release
```

### Missing Dependencies
```bash
cd cpp_judge
flutter pub get
```

### CMake Errors
Ensure you have the latest Flutter:
```bash
flutter upgrade
```

---

## 🔄 Rebuilding After Changes

### If you modify test cases (in main.cpp):
```bash
# Rebuild CLI only
bash scripts/build_bundle.sh
```

### If you modify GUI (Flutter code):
```bash
# Rebuild GUI
cd cpp_judge
flutter build windows --release

# Copy to dist
cp -R build/windows/x64/runner/Release/* ../dist/win64/gui/
```

### If you modify both:
```bash
# Rebuild everything
bash scripts/build_complete_bundle.sh
```

---

## 📊 Development Workflow

### Modify Flutter GUI

1. **Make changes** in `cpp_judge/lib/`
2. **Test on macOS:**
   ```bash
   cd cpp_judge
   flutter run -d macos
   ```
3. **Build for Windows:**
   ```bash
   flutter build windows --release
   ```
4. **Test on Windows PC**

### Modify Judge Logic

Both CLI and GUI use `lib/services/judge_service.dart` for test cases.

To add/modify problems:
1. Edit `lib/models/problem.dart` (problem descriptions)
2. Edit `lib/services/judge_service.dart` (test cases)
3. Rebuild GUI

For CLI:
1. Edit `main.cpp` (test cases in `get_testcases()`)
2. Rebuild with `build_bundle.sh`

---

## 🎨 Customization

### Change Theme Colors

Edit `cpp_judge/lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFF1976D2), // Change this
  primary: const Color(0xFF1976D2),   // And this
```

### Change Window Title

Edit `cpp_judge/windows/runner/main.cpp`:
```cpp
if (!window.Create(L"C++ Judge", origin, size)) {
```

### Change App Icon

Replace `cpp_judge/windows/runner/resources/app_icon.ico`

---

## 📈 Performance Notes

- **First launch:** May take 2-3 seconds (loading Flutter engine)
- **Compilation:** Same speed as CLI (uses same g++)
- **GUI:** Minimal overhead (~50MB RAM)
- **No internet needed** - fully offline

---

## ✅ Pre-Deployment Checklist

- [ ] Both `judge.exe` and `judge_gui.exe` exist
- [ ] MinGW toolchain is bundled
- [ ] All DLLs are present in `gui/` folder
- [ ] Tested on at least one Windows PC
- [ ] README files are included
- [ ] Sample solutions work correctly
- [ ] All three problems are accessible

---

## 🆘 Support

If students encounter issues:

1. **GUI won't start:**
   - Check all .dll files are in gui/ folder
   - Run from Command Prompt to see errors
   - Try the CLI version instead

2. **Compilation fails:**
   - Verify code syntax
   - Check mingw64/ folder exists
   - View compiler errors in results

3. **Tests fail unexpectedly:**
   - Compare output format carefully
   - Check for extra spaces/newlines
   - Test with provided examples

---

## 🎉 Success!

You now have a professional-grade judging system with:
- ✅ Modern GUI alternative
- ✅ Traditional CLI option
- ✅ Portable compiler
- ✅ Comprehensive documentation
- ✅ Ready for student use

Deploy to your lab and let students choose their preferred interface!
