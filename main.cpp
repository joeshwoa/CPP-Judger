#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include <cstdio>
#include <filesystem>
#include <fstream>
#include <windows.h>
#include <filesystem>
#include <iostream>

std::string getGPPPath() {
    char exePath[MAX_PATH];
    GetModuleFileNameA(NULL, exePath, MAX_PATH);
    std::filesystem::path judgePath(exePath);
    std::filesystem::path judgeDir = judgePath.parent_path();
    std::filesystem::path gppFullPath = judgeDir / "mingw64" / "bin" / "g++.exe";
    return gppFullPath.string();
}

struct TestCase {
    std::string input;
    std::string expected_output;
};

std::vector<TestCase> get_testcases(int problemID) {
    using std::string;
    std::vector<TestCase> tc;
    if (problemID == 1) {
        tc = {
            {"5\n0 1 2 3 4\n", "10\n"},
            {"5\n1 1 0 1 1\n", "1\n"},
            {"3\n1 3 1\n", "4\n"},
            {"1\n12\n", "0\n"},
            {"1\n0\n", "0\n"},
            {"6\n5 5 5 5 5 5\n", "0\n"},
            {"4\n2 2 3 2\n", "3\n"},
            {"7\n0 0 0 0 0 0 0\n", "0\n"},
            {"5\n1000000 0 500000 1000000 1\n", "2499999\n"}
        };
    } else if (problemID == 2) {
        tc = {
            {
                "5\n2\n2 3 4 5\n3\n2 3 4 5 5 5\n1\n2 4\n1\n2 3\n4\n1 5 3 2 6 7 3 4\n",
                "Yes\nNo\nNo\nYes\nNo\n"
            },
            {
                "3\n2\n1 1 2 2\n2\n0 0 0 0\n1\n5 6\n",
                "Yes\nNo\nYes\n"
            },
            {
                "2\n3\n1 2 3 4 5 6\n1\n100 99\n",
                "Yes\nYes\n"
            }
        };
    } else if (problemID == 3) {
        tc = {
            {
                "11\n1 2 3\n3 2 1\n2 9 -7\n3 4 7\n1 1 2\n1 1 0\n3 3 6\n9 9 18\n9 9 0\n1 9 -8\n1 9 10\n",
                "+\n-\n-\n+\n+\n-\n+\n+\n-\n-\n+\n"
            },
            {
                "5\n1 1 1\n2 1 1\n2 1 3\n9 9 18\n9 9 -0\n",
                "-\n-\n+\n+\n-\n"
            },
            {
                "3\n9 1 10\n9 1 8\n5 9 -4\n",
                "+\n-\n-\n"
            }
        };
    } else {
        std::cerr << "Unknown problem ID.\n";
        exit(2);
    }
    return tc;
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
    while (true) {
        std::cout << "Enter problem ID to test (1, 2, or 3): ";
        int problemID = 0;
        std::cin >> problemID;
        std::cin.ignore(); // remove newline

        if (!(problemID == 1 || problemID == 2 || problemID == 3)) {
            std::cerr << "Invalid problem ID. Try again.\n";
            continue;
        }

        std::cout << "Enter path to submitted CPP file (e.g., C:\\Users\\admin\\Desktop\\student.cpp):\n";
        std::string cppPath;
        std::getline(std::cin, cppPath);

        if (!std::filesystem::exists(cppPath)) {
            std::cerr << "CPP source file not found. Try again.\n";
            continue;
        }

        // Compile student code (g++)
        std::string exePath = cppPath + "_submission_build.exe";
        //std::string cmd = "g++ \"" + cppPath + "\" -o \"" + exePath + "\" -O2 -static -std=c++17 2> compile_errors.txt";
        // Find the local mingw64 g++.exe relative to judge.exe location
        std::string mingwGPP = getGPPPath();
        // Now build your compile command as ALWAYS using mingwGPP, NOT a relative path
        std::string raw_cmd = "\"" + mingwGPP + "\" \"" + cppPath + "\" -o \"" + exePath + "\" -O2 -static -std=c++17";
        std::string cmd = "cmd /C \"" + raw_cmd + " 2> compile_errors.txt\"";
        std::cout << "\nCompiling...\n";
        //std::cout << cmd.c_str() << std::endl;
        int compileResult = system(cmd.c_str());
        //std::cout << compileResult << std::endl;
        if (compileResult != 0) {
            std::cout << "Compilation failed. See 'compile_errors.txt' for details.\n";
            // Clean up before asking to continue
            if (std::filesystem::exists(exePath)) std::filesystem::remove(exePath);
        } else if (!std::filesystem::exists(exePath)) {
            std::cerr << "Compilation failed (no .exe was produced). Try again.\n";
        } else {
            std::wcout << L"Compilation successful. Running tests...\n\n";
            // Run test cases
            auto cases = get_testcases(problemID);
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
                    std::filesystem::remove(exePath); // Clean up
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
    std::cout << "Welcome to the C++ Judge!\n";
    run_submission_tester();
    return 0;
}