# Dynamic Problems System - Implementation Guide

## 🎯 Overview

I've created a **dynamic problem loading system** that allows you to add/modify problems without recompiling!

### Key Features
- ✅ **JSON-based test cases** - Easy to edit
- ✅ **Auto-discovery** - Problems loaded from `problems/` folder  
- ✅ **PDF support** (GUI only) - Full problem statements
- ✅ **Hot-reload** - Changes take effect on restart
- ✅ **Both CLI & GUI** - Same test cases, fair grading

---

## 📁 Folder Structure

```
dist/win64/
├── judge.exe                    # CLI judge (dynamic)
├── gui/
│   └── judge_gui.exe           # GUI judge (dynamic)
├── mingw64/                     # Compiler
└── problems/                    # ← NEW: Dynamic problem data
    ├── README.txt              # Instructions
    ├── 1/                      # Problem ID 1
    │   ├── info.json          # Metadata (title, limits)
    │   ├── description.pdf    # Full problem (GUI only)
    │   └── tests/
    │       ├── test1.json
    │       ├── test2.json
    │       └── ...
    ├── 2/                      # Problem ID 2
    │   ├── info.json
    │   ├── description.pdf
    │   └── tests/
    │       └── ...
    └── 3/                      # Problem ID 3
        └── ...
```

---

## 📄 File Formats

### 1. `info.json` - Problem Metadata

```json
{
  "id": 1,
  "title": "A. Holiday Of Equality",
  "timeLimit": "1 second",
  "memoryLimit": "256 megabytes",
  "inputFormat": "Description of input format...",
  "outputFormat": "Description of output format...",
  "notes": "Optional explanatory notes..."
}
```

### 2. `tests/testN.json` - Test Cases

```json
{
  "input": "5\n0 1 2 3 4\n",
  "output": "10\n"
}
```

**Important:** Use `\n` for newlines in JSON strings!

### 3. `description.pdf` - Full Problem Statement (GUI Only)

- Standard PDF file
- Must be named exactly `description.pdf`
- Displayed in GUI's Problem tab
- Optional (if missing, shows info.json text)

---

## ✅ What's Been Created

### 1. CLI - New Dynamic Version

**File:** `main_dynamic.cpp`

**Features:**
- Auto-detects problems from `problems/` folder
- Loads test cases from JSON files
- Shows available problem IDs
- Displays problem title and limits

**To build:**
```bash
# Replace old main.cpp with dynamic version
cp main_dynamic.cpp main.cpp

# Then rebuild as usual
bash scripts/build_bundle.sh
```

### 2. GUI - Dynamic Loader Service

**File:** `cpp_judge/lib/services/problem_loader.dart`

**Features:**
- Loads problems from JSON files
- Finds `problems/` folder (multiple locations)
- Loads test cases dynamically
- Supports PDF file detection
- Fallback to hardcoded problems if files missing

**Already integrated** - just needs dependencies installed.

### 3. Test Data Files

**Created:** All 3 problems with JSON test cases
- `problems/1/` - Holiday of Equality (9 tests)
- `problems/2/` - Odd Set (3 tests)
- `problems/3/` - Plus or Minus (3 tests)

---

## 🔧 Setup Instructions

### For CLI (Windows)

1. **Replace main.cpp:**
   ```bash
   cp main_dynamic.cpp main.cpp
   ```

2. **Rebuild:**
   ```bash
   bash scripts/build_bundle.sh
   ```

3. **Ensure problems folder exists:**
   ```
   dist/win64/problems/
   ```

4. **Test:**
   - Run `judge.exe`
   - Should show: "Available problems: 1, 2, 3"

### For GUI (Flutter)

1. **Install PDF viewer dependency:**
   ```bash
   cd cpp_judge
   flutter pub get
   ```

2. **Update judge_screen.dart imports:**
   ```dart
   import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
   import '../services/problem_loader.dart';
   ```

3. **Load problems dynamically in initState:**
   ```dart
   List<Problem> _availableProblems = [];
   
   @override
   void initState() {
     super.initState();
     _loadProblems();
     // ... rest of init
   }
   
   Future<void> _loadProblems() async {
     final problems = await ProblemLoader.loadAllProblems();
     setState(() {
       _availableProblems = problems;
       if (problems.isNotEmpty) {
         _currentProblem = problems.first;
         _selectedProblemId = problems.first.id;
       }
     });
   }
   ```

4. **Show PDF if available:**
   ```dart
   Widget _buildProblemView() {
     if (_currentProblem?.pdfPath != null) {
       return SfPdfViewer.file(
         File(_currentProblem!.pdfPath!),
       );
     }
     // ... else show text version
   }
   ```

---

## ➕ Adding a New Problem

### Example: Adding Problem 4

1. **Create folder structure:**
   ```bash
   mkdir -p dist/win64/problems/4/tests
   ```

2. **Create info.json:**
   ```json
   {
     "id": 4,
     "title": "B. Your New Problem",
     "timeLimit": "2 seconds",
     "memoryLimit": "512 megabytes",
     "inputFormat": "First line: integer n...",
     "outputFormat": "Single line: the answer",
     "notes": "Example explanation..."
   }
   ```

3. **Add test cases:**
   
   `problems/4/tests/test1.json`:
   ```json
   {
     "input": "3\n1 2 3\n",
     "output": "6\n"
   }
   ```
   
   `problems/4/tests/test2.json`:
   ```json
   {
     "input": "5\n5 4 3 2 1\n",
     "output": "15\n"
   }
   ```

4. **(Optional) Add PDF:**
   - Create problem statement PDF
   - Save as `problems/4/description.pdf`

5. **Restart judge** - Problem 4 appears automatically!

---

## ✏️ Modifying Existing Problems

### Change Test Cases

**Add a test:**
```bash
# Create new test file
echo '{"input":"10\\n","output":"55\\n"}' > problems/1/tests/test10.json
```

**Remove a test:**
```bash
rm problems/1/tests/test5.json
```

**Edit a test:**
```bash
# Just edit the JSON file
nano problems/1/tests/test1.json
```

### Change Problem Info

```bash
# Edit info.json
nano problems/1/info.json
```

### Update PDF

```bash
# Replace the PDF file
cp new_problem_statement.pdf problems/1/description.pdf
```

**Changes take effect immediately** - just restart the judge!

---

## 🔄 Migration from Hardcoded to Dynamic

### CLI Migration

**Old (main.cpp):**
```cpp
std::vector<TestCase> get_testcases(int problemID) {
    if (problemID == 1) {
        tc = {
            {"5\n0 1 2 3 4\n", "10\n"},
            // ... hardcoded tests
        };
    }
}
```

**New (main_dynamic.cpp):**
```cpp
std::vector<TestCase> get_testcases(int problemID) {
    // Reads from problems/{id}/tests/*.json
    // Auto-discovers and sorts test files
    // Returns test cases dynamically
}
```

### GUI Migration

**Old:**
```dart
final testCases = JudgeService.getTestCases(problemId);
```

**New:**
```dart
final testCases = await ProblemLoader.loadTestCases(problemId);
```

---

## 🎨 GUI PDF Viewer

When `description.pdf` exists, the GUI shows:

```
┌─────────────────────────────────────┐
│ Problem Tab                         │
├─────────────────────────────────────┤
│                                     │
│   [PDF Viewer showing full problem] │
│                                     │
│   - Zoom controls                   │
│   - Page navigation                 │
│   - Search functionality            │
│                                     │
└─────────────────────────────────────┘
```

If no PDF, falls back to text display from `info.json`.

---

## 🐛 Troubleshooting

### "No problems found"

**Cause:** `problems/` folder not found

**Solution:**
- Check folder exists at `dist/win64/problems/`
- Ensure folder contains numbered directories (1/, 2/, etc.)
- Check folder permissions

### "No test cases loaded"

**Cause:** Missing or invalid `tests/` folder

**Solution:**
- Ensure `problems/{id}/tests/` exists
- Verify `.json` files are valid JSON
- Check file permissions

### "JSON parse error"

**Cause:** Invalid JSON syntax

**Solution:**
- Use JSON validator: https://jsonlint.com/
- Check for unescaped quotes
- Verify newlines are `\n` not actual newlines

### PDF not showing (GUI)

**Cause:** Missing PDF file or syncfusion dependency

**Solution:**
- Verify file named exactly `description.pdf`
- Run `flutter pub get` to install dependencies
- Check file path permissions

---

## 📊 Comparison: Hardcoded vs Dynamic

| Aspect | Hardcoded | Dynamic |
|--------|-----------|---------|
| **Adding problems** | Recompile | Add JSON files |
| **Modifying tests** | Recompile | Edit JSON files |
| **Deploy updates** | Redistribute exe | Replace JSON files |
| **Student can see?** | No | No (hidden from students) |
| **Backup/version** | In code | JSON files in git |
| **Easy to share?** | No | Yes (send JSON files) |

---

## ✅ Implementation Checklist

### CLI
- [x] Create `main_dynamic.cpp`
- [x] Add JSON parsing functions
- [x] Add problem auto-discovery
- [x] Create test data files
- [ ] Replace `main.cpp` with dynamic version
- [ ] Rebuild `judge.exe`
- [ ] Test with sample problems

### GUI  
- [x] Create `problem_loader.dart`
- [x] Add PDF viewer dependency
- [x] Update `Problem` model for PDF path
- [x] Update `judge_service.dart` to use loader
- [ ] Update `judge_screen.dart` for dynamic loading
- [ ] Add PDF viewer widget
- [ ] Rebuild `judge_gui.exe`
- [ ] Test with sample problems

### Deployment
- [x] Create `problems/` folder structure
- [x] Add all 3 problems with tests
- [x] Create README for problems folder
- [ ] Add PDF files for each problem
- [ ] Test complete bundle on Windows

---

## 🎯 Next Steps

1. **Build CLI with dynamic support:**
   ```bash
   cp main_dynamic.cpp main.cpp
   bash scripts/build_bundle.sh
   ```

2. **Build GUI with dynamic support:**
   ```bash
   cd cpp_judge
   flutter pub get
   # Update judge_screen.dart (see code snippets above)
   flutter build windows --release
   ```

3. **Create PDFs** for each problem (use any tool)

4. **Test everything:**
   - Add test problem
   - Modify existing tests
   - Remove a problem
   - Verify both CLI and GUI work

5. **Deploy to students** with documentation!

---

## 📖 Documentation Files

- `problems/README.txt` - For instructors
- `DYNAMIC_PROBLEMS_GUIDE.md` - This file (technical)
- `dist/win64/README_COMPLETE.txt` - For students (updated)

---

## 🎉 Benefits

- ✅ **No recompilation** needed for new problems
- ✅ **Easy problem management** via JSON files
- ✅ **Version control** friendly (track JSON in git)
- ✅ **PDF support** for rich problem statements
- ✅ **Auto-discovery** of new problems
- ✅ **Fallback** to hardcoded if files missing
- ✅ **Both CLI & GUI** read same data

---

**Last Updated:** November 2025  
**Version:** 2.0 (Dynamic Problems System)
