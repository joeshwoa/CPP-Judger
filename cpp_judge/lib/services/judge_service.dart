import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:process_run/shell.dart';
import 'problem_loader.dart';

class TestCase {
  final String input;
  final String expectedOutput;

  TestCase(this.input, this.expectedOutput);
}

class TestResult {
  final int testNumber;
  final bool passed;
  final String? input;
  final String? expectedOutput;
  final String? actualOutput;
  final String? error;

  TestResult({
    required this.testNumber,
    required this.passed,
    this.input,
    this.expectedOutput,
    this.actualOutput,
    this.error,
  });
}

class JudgeResult {
  final bool compilationSuccess;
  final String? compilationError;
  final List<TestResult> testResults;
  final int passedTests;
  final int totalTests;

  JudgeResult({
    required this.compilationSuccess,
    this.compilationError,
    required this.testResults,
    required this.passedTests,
    required this.totalTests,
  });
}

class JudgeService {
  static List<TestCase> getTestCases(int problemId) {
    switch (problemId) {
      case 1:
        // Problem 1: Holiday Of Equality
        return [
          TestCase("5\n0 1 2 3 4\n", "10\n"),
          TestCase("5\n1 1 0 1 1\n", "1\n"),
          TestCase("3\n1 3 1\n", "4\n"),
          TestCase("1\n12\n", "0\n"),
          TestCase("1\n0\n", "0\n"),
          TestCase("6\n5 5 5 5 5 5\n", "0\n"),
          TestCase("4\n2 2 3 2\n", "1\n"),
          TestCase("7\n0 0 0 0 0 0 0\n", "0\n"),
          TestCase("5\n1000000 0 500000 1000000 1\n", "1499999\n"),
        ];
      case 2:
        // Problem 2: Odd Set
        return [
          TestCase(
            "5\n2\n2 3 4 5\n3\n2 3 4 5 5 5\n1\n2 4\n1\n2 3\n4\n1 5 3 2 6 7 3 4\n",
            "Yes\nNo\nNo\nYes\nNo\n",
          ),
          TestCase(
            "3\n2\n1 1 2 2\n2\n0 0 0 0\n1\n5 6\n",
            "Yes\nNo\nYes\n",
          ),
          TestCase(
            "2\n3\n1 2 3 4 5 6\n1\n100 99\n",
            "Yes\nYes\n",
          ),
        ];
      case 3:
        // Problem 3: Plus or Minus
        return [
          TestCase(
            "11\n1 2 3\n3 2 1\n2 9 -7\n3 4 7\n1 1 2\n1 1 0\n3 3 6\n9 9 18\n9 9 0\n1 9 -8\n1 9 10\n",
            "+\n-\n-\n+\n+\n-\n+\n+\n-\n-\n+\n",
          ),
          TestCase(
            "5\n1 1 1\n2 1 1\n2 1 3\n9 9 18\n9 9 -0\n",
            "-\n-\n+\n+\n-\n",
          ),
          TestCase(
            "3\n9 1 10\n9 1 8\n5 9 -4\n",
            "+\n-\n-\n",
          ),
        ];
      default:
        return [];
    }
  }

  static Future<JudgeResult> judgeSubmission(
    String sourceCode,
    int problemId,
  ) async {
    try {
      // Create temp directory for compilation
      final tempDir = await Directory.systemTemp.createTemp('judge_');
      final sourceFile = File(path.join(tempDir.path, 'solution.cpp'));
      final exeFile = File(path.join(
        tempDir.path,
        Platform.isWindows ? 'solution.exe' : 'solution',
      ));

      // Write source code to file
      await sourceFile.writeAsString(sourceCode);

      // Find g++ compiler
      String gppPath = await _findCompiler(tempDir.path);

      // Compile
      final shell = Shell(workingDirectory: tempDir.path);
      try {
        if (Platform.isWindows) {
          await shell.run(
            '"$gppPath" solution.cpp -o solution.exe -O2 -static -std=c++17',
          );
        } else {
          await shell.run(
            'g++ solution.cpp -o solution -O2 -std=c++17',
          );
        }
      } catch (e) {
        // Compilation failed
        await tempDir.delete(recursive: true);
        return JudgeResult(
          compilationSuccess: false,
          compilationError: e.toString(),
          testResults: [],
          passedTests: 0,
          totalTests: 0,
        );
      }

      // Check if exe was created
      if (!await exeFile.exists()) {
        await tempDir.delete(recursive: true);
        return JudgeResult(
          compilationSuccess: false,
          compilationError: 'Compilation failed: executable not produced',
          testResults: [],
          passedTests: 0,
          totalTests: 0,
        );
      }

      // Run test cases - load from files dynamically
      final testCases = await ProblemLoader.loadTestCases(problemId);
      final List<TestResult> testResults = [];
      int passedCount = 0;

      for (int i = 0; i < testCases.length; i++) {
        final testCase = testCases[i];
        try {
          // Run the program with input
          final process = await Process.start(exeFile.path, []);
          
          // Write input to stdin
          process.stdin.write(testCase.input);
          await process.stdin.close();
          
          // Read output
          final stdoutFuture = process.stdout.transform(utf8.decoder).join();
          final stderrFuture = process.stderr.transform(utf8.decoder).join();
          
          await process.exitCode;
          final actualOutput = await stdoutFuture;
          final trimmedActual = _trimNewlines(actualOutput);
          final trimmedExpected = _trimNewlines(testCase.expectedOutput);

          final passed = trimmedActual == trimmedExpected;
          if (passed) passedCount++;

          testResults.add(TestResult(
            testNumber: i + 1,
            passed: passed,
            input: testCase.input,
            expectedOutput: testCase.expectedOutput,
            actualOutput: actualOutput,
          ));

          if (!passed) break; // Stop on first failure
        } catch (e) {
          testResults.add(TestResult(
            testNumber: i + 1,
            passed: false,
            input: testCase.input,
            expectedOutput: testCase.expectedOutput,
            error: e.toString(),
          ));
          break;
        }
      }

      // Clean up
      await tempDir.delete(recursive: true);

      return JudgeResult(
        compilationSuccess: true,
        testResults: testResults,
        passedTests: passedCount,
        totalTests: testCases.length,
      );
    } catch (e) {
      return JudgeResult(
        compilationSuccess: false,
        compilationError: 'Unexpected error: $e',
        testResults: [],
        passedTests: 0,
        totalTests: 0,
      );
    }
  }

  static String _trimNewlines(String s) {
    return s.replaceAll(RegExp(r'[\r\n]+$'), '');
  }

  static Future<String> _findCompiler(String workingDir) async {
    if (Platform.isWindows) {
      // Try to find bundled mingw64
      final exePath = Platform.resolvedExecutable;
      final exeDir = path.dirname(exePath);
      
      // Try multiple possible locations for mingw64
      final possiblePaths = [
        path.join(exeDir, 'mingw64', 'bin', 'g++.exe'),           // Same folder
        path.join(exeDir, '..', 'mingw64', 'bin', 'g++.exe'),     // One level up
        path.join(exeDir, '..', '..', 'mingw64', 'bin', 'g++.exe'), // Two levels up
      ];
      
      for (final gppPath in possiblePaths) {
        final normalized = path.normalize(gppPath);
        if (await File(normalized).exists()) {
          return normalized;
        }
      }

      // Try system g++ as fallback
      return 'g++';
    } else {
      // On macOS/Linux, use system g++
      return 'g++';
    }
  }
}
