#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include <cstdio>
#include <filesystem>
#include <fstream>
#include <windows.h>
#include <algorithm>
#include <map>

std::string getGPPPath() {
    char exePath[MAX_PATH];
    GetModuleFileNameA(NULL, exePath, MAX_PATH);
    std::filesystem::path judgePath(exePath);
    std::filesystem::path judgeDir = judgePath.parent_path();
    std::filesystem::path gppFullPath = judgeDir / "mingw64" / "bin" / "g++.exe";
    return gppFullPath.string();
}

std::string getProblemsPath() {
    char exePath[MAX_PATH];
    GetModuleFileNameA(NULL, exePath, MAX_PATH);
    std::filesystem::path judgePath(exePath);
    std::filesystem::path judgeDir = judgePath.parent_path();
    std::filesystem::path problemsPath = judgeDir / "problems";
    return problemsPath.string();
}

struct TestCase {
    std::string input;
    std::string expected_output;
};

struct ProblemInfo {
    int id;
    std::string title;
    std::string timeLimit;
    std::string memoryLimit;
};

// Simple JSON string parser for our specific format
std::string parseJsonString(const std::string& json, const std::string& key) {
    size_t keyPos = json.find("\"" + key + "\"");
    if (keyPos == std::string::npos) return "";
    
    size_t colonPos = json.find(":", keyPos);
    if (colonPos == std::string::npos) return "";
    
    size_t startQuote = json.find("\"", colonPos);
    if (startQuote == std::string::npos) return "";
    
    size_t endQuote = startQuote + 1;
    while (endQuote < json.size()) {
        if (json[endQuote] == '\"' && json[endQuote-1] != '\\') {
            break;
        }
        endQuote++;
    }
    
    std::string result = json.substr(startQuote + 1, endQuote - startQuote - 1);
    
    // Replace escaped newlines
    size_t pos = 0;
    while ((pos = result.find("\\n", pos)) != std::string::npos) {
        result.replace(pos, 2, "\n");
        pos += 1;
    }
    
    return result;
}

int parseJsonInt(const std::string& json, const std::string& key) {
    size_t keyPos = json.find("\"" + key + "\"");
    if (keyPos == std::string::npos) return 0;
    
    size_t colonPos = json.find(":", keyPos);
    if (colonPos == std::string::npos) return 0;
    
    size_t numStart = json.find_first_of("0123456789", colonPos);
    if (numStart == std::string::npos) return 0;
    
    size_t numEnd = json.find_first_not_of("0123456789", numStart);
    
    std::string numStr = json.substr(numStart, numEnd - numStart);
    return std::stoi(numStr);
}

ProblemInfo loadProblemInfo(int problemID) {
    ProblemInfo info;
    info.id = problemID;
    info.title = "Problem " + std::to_string(problemID);
    info.timeLimit = "1 second";
    info.memoryLimit = "256 megabytes";
    
    std::string problemsPath = getProblemsPath();
    std::filesystem::path infoPath = std::filesystem::path(problemsPath) / std::to_string(problemID) / "info.json";
    
    if (!std::filesystem::exists(infoPath)) {
        return info;
    }
    
    std::ifstream file(infoPath);
    if (!file.is_open()) {
        return info;
    }
    
    std::stringstream buffer;
    buffer << file.rdbuf();
    std::string json = buffer.str();
    file.close();
    
    info.id = parseJsonInt(json, "id");
    std::string title = parseJsonString(json, "title");
    if (!title.empty()) info.title = title;
    
    std::string timeLimit = parseJsonString(json, "timeLimit");
    if (!timeLimit.empty()) info.timeLimit = timeLimit;
    
    std::string memLimit = parseJsonString(json, "memoryLimit");
    if (!memLimit.empty()) info.memoryLimit = memLimit;
    
    return info;
}

std::vector<TestCase> get_testcases(int problemID) {
    std::vector<TestCase> tc;
    
    std::string problemsPath = getProblemsPath();
    std::filesystem::path testsDir = std::filesystem::path(problemsPath) / std::to_string(problemID) / "tests";
    
    if (!std::filesystem::exists(testsDir)) {
        std::cerr << "Error: Tests directory not found for problem " << problemID << "\n";
        std::cerr << "Looking in: " << testsDir << "\n";
        return tc;
    }
    
    // Get all test files and sort them
    std::vector<std::filesystem::path> testFiles;
    for (const auto& entry : std::filesystem::directory_iterator(testsDir)) {
        if (entry.path().extension() == ".json") {
            testFiles.push_back(entry.path());
        }
    }
    
    std::sort(testFiles.begin(), testFiles.end());
    
    // Load each test file
    for (const auto& testFile : testFiles) {
        std::ifstream file(testFile);
        if (!file.is_open()) continue;
        
        std::stringstream buffer;
        buffer << file.rdbuf();
        std::string json = buffer.str();
        file.close();
        
        TestCase test;
        test.input = parseJsonString(json, "input");
        test.expected_output = parseJsonString(json, "output");
        
        if (!test.input.empty() && !test.expected_output.empty()) {
            tc.push_back(test);
        }
    }
    
    return tc;
}

std::vector<int> getAvailableProblems() {
    std::vector<int> problems;
    std::string problemsPath = getProblemsPath();
    
    if (!std::filesystem::exists(problemsPath)) {
        std::cerr << "Warning: Problems directory not found at: " << problemsPath << "\n";
        // Return default problems as fallback
        return {1, 2, 3};
    }
    
    for (const auto& entry : std::filesystem::directory_iterator(problemsPath)) {
        if (entry.is_directory()) {
            std::string dirName = entry.path().filename().string();
            // Check if directory name is a number
            if (std::all_of(dirName.begin(), dirName.end(), ::isdigit)) {
                int problemID = std::stoi(dirName);
                problems.push_back(problemID);
            }
        }
    }
    
    std::sort(problems.begin(), problems.end());
    return problems;
}

std::string trim(const std::string& s) {
    size_t first = s.find_first_not_of(" \r\n\t");
    if (first == std::string::npos) return "";
    size_t last = s.find_last_not_of(" \r\n\t");
    return s.substr(first, (last - first + 1));
}

std::string trim_newlines(const std::string& s) {
    size_t end = s.find_last_not_of("\r\n");
    return (end == std::string::npos) ? "" : s.substr(0, end + 1);
}

void run_submission_tester() {
    std::vector<int> availableProblems = getAvailableProblems();
    
    if (availableProblems.empty()) {
        std::cerr << "Error: No problems found!\n";
        std::cerr << "Please ensure the 'problems' folder exists next to judge.exe\n";
        return;
    }
    
    while (true) {
        std::cout << "Available problems: ";
        for (size_t i = 0; i < availableProblems.size(); ++i) {
            std::cout << availableProblems[i];
            if (i < availableProblems.size() - 1) std::cout << ", ";
        }
        std::cout << "\n";
        
        std::cout << "Enter problem ID to test: ";
        int problemID = 0;
        std::cin >> problemID;
        std::cin.ignore(); // remove newline

        if (std::find(availableProblems.begin(), availableProblems.end(), problemID) == availableProblems.end()) {
            std::cerr << "Invalid problem ID. Try again.\n";
            continue;
        }
        
        // Load and display problem info
        ProblemInfo info = loadProblemInfo(problemID);
        std::cout << "\n=== " << info.title << " ===\n";
        std::cout << "Time Limit: " << info.timeLimit << "\n";
        std::cout << "Memory Limit: " << info.memoryLimit << "\n\n";

        std::cout << "Enter path to submitted CPP file (e.g., C:\\Users\\admin\\Desktop\\student.cpp):\n";
        std::string cppPath;
        std::getline(std::cin, cppPath);

        if (!std::filesystem::exists(cppPath)) {
            std::cerr << "CPP source file not found. Try again.\n";
            continue;
        }

        // Compile student code (g++)
        std::string exePath = cppPath + "_submission_build.exe";
        std::string mingwGPP = getGPPPath();
        std::string raw_cmd = "\"" + mingwGPP + "\" \"" + cppPath + "\" -o \"" + exePath + "\" -O2 -static -std=c++17";
        std::string cmd = "cmd /C \"" + raw_cmd + " 2> compile_errors.txt\"";
        std::cout << "\nCompiling...\n";
        int compileResult = system(cmd.c_str());
        
        if (compileResult != 0) {
            std::cout << "Compilation failed. See 'compile_errors.txt' for details.\n";
            if (std::filesystem::exists(exePath)) std::filesystem::remove(exePath);
        } else if (!std::filesystem::exists(exePath)) {
            std::cerr << "Compilation failed (no .exe was produced). Try again.\n";
        } else {
            std::wcout << L"Compilation successful. Running tests...\n\n";
            
            // Run test cases
            auto cases = get_testcases(problemID);
            
            if (cases.empty()) {
                std::cerr << "Error: No test cases found for problem " << problemID << "\n";
                std::cerr << "Please check the problems/" << problemID << "/tests/ folder.\n";
            } else {
                std::cout << "Loaded " << cases.size() << " test case(s)\n\n";
                
                int passed = 0;
                bool had_failure = false;
                for (size_t i = 0; i < cases.size(); ++i) {
                    std::string result;
                    try {
                        // Write input to file
                        std::ofstream inFile("input.txt");
                        inFile << cases[i].input;
                        inFile.close();
                        
                        // Prepare output file name
                        std::string outFileName = "output.txt";
                        std::string runCmd = "\"" + exePath + "\" < input.txt > " + outFileName;

                        // Run it
                        std::system(runCmd.c_str());

                        // Read the output
                        std::ifstream outFile(outFileName);
                        std::stringstream buffer;
                        buffer << outFile.rdbuf();
                        result = buffer.str();

                        // Compare output:
                        result = trim(result);
                        outFile.close();
                    } catch (const std::exception& e) {
                        std::cerr << "\nExecution error: " << e.what() << std::endl;
                        std::cerr << "Input was:\n" << cases[i].input << std::endl;
                        std::filesystem::remove(exePath);
                        had_failure = true;
                        break;
                    }
                    
                    auto trimmed_result = trim_newlines(result);
                    auto trimmed_expected = trim_newlines(cases[i].expected_output);
                    
                    if (trimmed_result == trimmed_expected) {
                        std::cout << "Test case #" << (i + 1) << ": Passed.\n";
                        ++passed;
                    } else {
                        std::cout << "\nNot Passed!\n";
                        std::cout << "Fails on test case #" << (i + 1) << ":\n";
                        std::cout << "Input:\n" << cases[i].input;
                        std::cout << "Your Output:\n" << result << "\n";
                        std::cout << "Expected Output:\n" << cases[i].expected_output << "\n";
                        had_failure = true;
                        break;
                    }
                }
                
                if (!had_failure) {
                    std::cout << "\nAll " << passed << " test cases passed. Congratulations!\n";
                }
            }
            
            // Clean up build file and temporary files
            if (std::filesystem::exists(exePath)) std::filesystem::remove(exePath);
            if (std::filesystem::exists("input.txt")) std::filesystem::remove("input.txt");
            if (std::filesystem::exists("output.txt")) std::filesystem::remove("output.txt");
            if (std::filesystem::exists("compile_errors.txt")) std::filesystem::remove("compile_errors.txt");
        }

        // Ask user to continue or exit
        std::cout << "\nWould you like to test another submission? (y/n): ";
        std::string answer;
        std::getline(std::cin, answer);
        if (answer.empty() || answer[0] == 'n' || answer[0] == 'N') {
            std::cout << "Thank you for using the JoJudge. Goodbye!\n";
            break;
        }
        std::cout << "\n========== New Submission ==========\n";
    }
}

int main() {
    std::cout << "                                                  \n";
    std::cout << "   |@@@@@@@@@|        |$|            |$|          \n";
    std::cout << "   |@@|               |$|            |$|          \n";
    std::cout << "   |@@|           $$$$$$$$$$$    $$$$$$$$$$$      \n";
    std::cout << "   |@@|               |$|            |$|          \n";
    std::cout << "   |@@@@@@@@@|        |$|            |$|          \n";
    std::cout << "                                                  \n";
    std::cout << "__________________________________________________\n";
    std::cout << "Welcome to the C++ Judge (Dynamic Version)!\n";
    std::cout << "Test cases loaded from 'problems' folder\n\n";
    run_submission_tester();
    return 0;
}
