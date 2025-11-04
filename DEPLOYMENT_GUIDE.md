# C++ Judger - Deployment Guide

## 📦 What You Have

A complete, portable Windows application that can run on **any Windows PC** without installation.

**Bundle Size:** ~936 MB  
**Location:** `dist/win64/`

---

## 🎯 Problems Included

### Problem 1: A. Holiday Of Equality
- **Input:** `n`, then `n` integers (welfare values)
- **Output:** Minimum cost to equalize all citizens to the maximum welfare
- **Example:**
  ```
  Input:  5
          0 1 2 3 4
  Output: 10
  ```

### Problem 2: A. Odd Set
- **Input:** `t` test cases, each with `n` and `2n` integers
- **Output:** "Yes" if numbers can be paired so each pair sums to odd, otherwise "No"
- **Example:**
  ```
  Input:  2
          2
          2 3 4 5
          1
          2 4
  Output: Yes
          No
  ```

### Problem 3: A. Plus or Minus
- **Input:** `t` test cases, each with three integers `a`, `b`, `c`
- **Output:** "+" if `a+b=c`, otherwise "-"
- **Example:**
  ```
  Input:  3
          1 2 3
          3 2 1
          2 9 -7
  Output: +
          -
          -
  ```

---

## 🚀 Deployment Steps

### For You (on macOS):

1. **Copy the bundle to a USB drive or cloud storage:**
   ```bash
   # Option 1: USB drive
   cp -R dist/win64 /Volumes/YOUR_USB_DRIVE/JoJudge
   
   # Option 2: Create a zip for cloud upload
   cd dist
   zip -r JoJudge.zip win64
   ```

2. **Transfer to lab computers:**
   - Copy the `win64` folder to each Windows PC
   - Recommended location: `C:\JoJudge\` or Desktop

### For Students (on Windows):

1. **Locate the judger:**
   - Find the `win64` folder (or `JoJudge` folder)
   - Double-click `judge.exe`

2. **Use the judger:**
   ```
   1. Program starts and shows welcome message
   2. Enter problem ID: 1, 2, or 3
   3. Enter full path to your .cpp file
      Example: C:\Users\Student\Desktop\solution.cpp
   4. View test results
   5. Repeat or exit
   ```

---

## ✅ Testing Before Deployment

You can test locally with the sample solutions:

```bash
# The samples are in: samples/
# - problem1_correct.cpp
# - problem2_correct.cpp  
# - problem3_correct.cpp

# To verify the build works, you would need to run judge.exe on Windows
# For now, you can verify the files exist:
ls -lh dist/win64/judge.exe
ls -lh dist/win64/mingw64/bin/g++.exe
```

---

## 📋 What Students Need to Know

### File Requirements:
- File must be a valid `.cpp` file
- File must be saved with proper encoding (UTF-8 or ASCII)
- Path must use backslashes on Windows: `C:\folder\file.cpp`

### Compilation Settings:
- Compiler: `g++ (GCC) 13.2.0`
- Flags: `-O2 -static -std=c++17`
- Students can use modern C++17 features

### Common Issues:

**Problem:** "CPP source file not found"
- **Solution:** Check the file path is correct (use full path, not relative)

**Problem:** "Compilation failed"
- **Solution:** Check `compile_errors.txt` in the same folder as `judge.exe`

**Problem:** "Test case failed"
- **Solution:** Compare "Your Output" vs "Expected Output" carefully
  - Check for extra spaces, missing newlines, wrong formatting

---

## 🛠️ Rebuild Instructions (for you)

If you need to rebuild the bundle in the future:

```bash
cd /Volumes/PortableSSD/Projects/Python/CPP-Judger-main
bash scripts/build_bundle.sh
```

**Prerequisites:**
- `brew install mingw-w64` (cross-compiler)
- `brew install p7zip` (archive extractor)

The script will:
1. Compile `judge.exe` for Windows
2. Download portable MinGW (or reuse existing)
3. Copy runtime DLLs
4. Create README

---

## 📁 Bundle Contents

```
win64/
├── judge.exe                    # Main judger (15 MB)
├── libgcc_s_seh-1.dll          # Runtime library
├── libstdc++-6.dll             # C++ standard library
├── libwinpthread-1.dll         # Threading library
├── README.txt                   # Instructions for students
└── mingw64/                     # Portable compiler (~920 MB)
    └── bin/
        └── g++.exe              # C++ compiler
```

---

## 🎓 Student Workflow Example

1. Write solution in any editor (VS Code, Code::Blocks, etc.)
2. Save as `solution.cpp`
3. Run `judge.exe`
4. Enter problem ID (e.g., `1`)
5. Enter file path: `C:\Users\Student\Desktop\solution.cpp`
6. See results:
   ```
   Compiling...
   Compilation successful. Running tests...
   
   Test case #1: Passed.
   Test case #2: Passed.
   ...
   
   All 9 test cases passed. Congratulations!
   ```

---

## 🔧 Troubleshooting

### If judge.exe doesn't run:
- Ensure all DLL files are in the same folder as `judge.exe`
- Check Windows version is 64-bit (32-bit not supported)
- Try running from Command Prompt to see error messages

### If compilation fails:
- Check student code for syntax errors
- Verify `mingw64/bin/g++.exe` exists
- Check available disk space for temporary files

### If tests fail but code seems correct:
- Check output formatting (spaces, newlines)
- Verify input reading matches problem format
- Compare against sample solutions in `samples/` folder

---

## 📞 Support

For issues:
1. Check `compile_errors.txt` (created when compilation fails)
2. Verify file paths are correct
3. Test with provided sample solutions
4. Check that all bundle files are present

---

## 🔄 Version History

**v1.0** - November 2025
- Problems: Holiday of Equality, Odd Set, Plus or Minus
- Cross-compiled on macOS for Windows deployment
- Portable bundle with embedded MinGW toolchain
