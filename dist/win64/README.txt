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
