import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../models/problem.dart';
import 'judge_service.dart';

class ProblemLoader {
  static String _getProblemsPath() {
    final exePath = Platform.resolvedExecutable;
    final exeDir = path.dirname(exePath);
    
    // Try multiple possible locations for problems folder
    final possiblePaths = [
      path.join(exeDir, 'problems'),              // Same folder as exe
      path.join(exeDir, '..', 'problems'),         // One level up
      path.join(exeDir, '..', '..', 'problems'),   // Two levels up
    ];
    
    for (final problemPath in possiblePaths) {
      final normalized = path.normalize(problemPath);
      if (Directory(normalized).existsSync()) {
        return normalized;
      }
    }
    
    // Return default even if doesn't exist
    return path.join(exeDir, '..', 'problems');
  }
  
  static Future<List<Problem>> loadAllProblems() async {
    final problemsPath = _getProblemsPath();
    final problemsDir = Directory(problemsPath);
    
    if (!await problemsDir.exists()) {
      print('Warning: Problems directory not found at: $problemsPath');
      // Return empty list - fallback to hardcoded problems
      return Problem.getAllProblems();
    }
    
    final List<Problem> problems = [];
    
    // Get all numeric directories
    final entries = await problemsDir.list().toList();
    final problemDirs = entries
        .whereType<Directory>()
        .where((dir) {
          final name = path.basename(dir.path);
          return RegExp(r'^\d+$').hasMatch(name);
        })
        .toList();
    
    // Sort by problem ID
    problemDirs.sort((a, b) {
      final idA = int.parse(path.basename(a.path));
      final idB = int.parse(path.basename(b.path));
      return idA.compareTo(idB);
    });
    
    for (final dir in problemDirs) {
      try {
        final problem = await _loadProblem(dir.path);
        if (problem != null) {
          problems.add(problem);
        }
      } catch (e) {
        print('Error loading problem from ${dir.path}: $e');
      }
    }
    
    // If no problems loaded, return hardcoded ones as fallback
    if (problems.isEmpty) {
      print('No problems loaded from files, using hardcoded problems');
      return Problem.getAllProblems();
    }
    
    return problems;
  }
  
  static Future<Problem?> _loadProblem(String problemDir) async {
    final infoFile = File(path.join(problemDir, 'info.json'));
    
    if (!await infoFile.exists()) {
      return null;
    }
    
    final String jsonContent = await infoFile.readAsString();
    final Map<String, dynamic> json = jsonDecode(jsonContent);
    
    // Load test cases for examples
    final testsDir = Directory(path.join(problemDir, 'tests'));
    final List<Example> examples = [];
    
    if (await testsDir.exists()) {
      final testFiles = await testsDir
          .list()
          .where((file) => file.path.endsWith('.json'))
          .toList();
      
      // Sort test files
      testFiles.sort((a, b) => a.path.compareTo(b.path));
      
      // Take first 4 tests as examples
      for (int i = 0; i < testFiles.length && i < 4; i++) {
        try {
          final testFile = File(testFiles[i].path);
          final testJson = jsonDecode(await testFile.readAsString());
          
          examples.add(Example(
            input: (testJson['input'] as String).replaceAll('\\n', '\n'),
            output: (testJson['output'] as String).replaceAll('\\n', '\n'),
          ));
        } catch (e) {
          print('Error loading test file ${testFiles[i].path}: $e');
        }
      }
    }
    
    // Check for PDF file
    final pdfPath = path.join(problemDir, 'description.pdf');
    final hasPdf = await File(pdfPath).exists();
    
    return Problem(
      id: json['id'] as int,
      title: json['title'] as String,
      timeLimit: json['timeLimit'] as String? ?? '1 second',
      memoryLimit: json['memoryLimit'] as String? ?? '256 megabytes',
      description: json['description'] as String? ?? '',
      inputFormat: json['inputFormat'] as String? ?? '',
      outputFormat: json['outputFormat'] as String? ?? '',
      examples: examples,
      notes: json['notes'] as String?,
      pdfPath: hasPdf ? pdfPath : null,
    );
  }
  
  static Future<List<TestCase>> loadTestCases(int problemId) async {
    final problemsPath = _getProblemsPath();
    final testsDir = Directory(path.join(problemsPath, problemId.toString(), 'tests'));
    
    if (!await testsDir.exists()) {
      print('Warning: Tests directory not found for problem $problemId');
      // Fallback to hardcoded tests
      return JudgeService.getTestCases(problemId);
    }
    
    final testFiles = await testsDir
        .list()
        .where((file) => file.path.endsWith('.json'))
        .toList();
    
    if (testFiles.isEmpty) {
      print('Warning: No test files found for problem $problemId');
      return JudgeService.getTestCases(problemId);
    }
    
    // Sort test files
    testFiles.sort((a, b) => a.path.compareTo(b.path));
    
    final List<TestCase> testCases = [];
    
    for (final fileEntity in testFiles) {
      try {
        final testFile = File(fileEntity.path);
        final jsonContent = await testFile.readAsString();
        final Map<String, dynamic> json = jsonDecode(jsonContent);
        
        testCases.add(TestCase(
          json['input'] as String,
          json['output'] as String,
        ));
      } catch (e) {
        print('Error loading test file ${fileEntity.path}: $e');
      }
    }
    
    return testCases.isNotEmpty ? testCases : JudgeService.getTestCases(problemId);
  }
}
