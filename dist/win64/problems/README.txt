═══════════════════════════════════════════════════════════
  Problems Folder - Dynamic Test Cases & Descriptions
═══════════════════════════════════════════════════════════

This folder contains all problem data for the C++ Judge.
You can add, modify, or remove problems without recompiling!

───────────────────────────────────────────────────────────

📁 FOLDER STRUCTURE

problems/
├── 1/                      # Problem ID 1
│   ├── info.json          # Problem metadata
│   ├── description.pdf    # Full problem (GUI only)
│   └── tests/
│       ├── test1.json
│       ├── test2.json
│       └── ...
├── 2/                      # Problem ID 2
│   └── ...
└── 3/                      # Problem ID 3
    └── ...

───────────────────────────────────────────────────────────

📄 FILE FORMATS

1. info.json - Problem Metadata
{
  "id": 1,
  "title": "A. Problem Title",
  "timeLimit": "1 second",
  "memoryLimit": "256 megabytes",
  "inputFormat": "Description...",
  "outputFormat": "Description...",
  "notes": "Optional notes..."
}

2. tests/testN.json - Individual Test Cases
{
  "input": "5\n0 1 2 3 4\n",
  "output": "10\n"
}

3. description.pdf (GUI only)
- Full problem statement as PDF
- Will be displayed in the GUI's Problem tab
- File name must be "description.pdf"

───────────────────────────────────────────────────────────

➕ ADDING A NEW PROBLEM

1. Create a new folder: problems/4/

2. Create info.json:
   {
     "id": 4,
     "title": "Your Problem Title",
     "timeLimit": "2 seconds",
     "memoryLimit": "512 megabytes",
     "inputFormat": "...",
     "outputFormat": "...",
     "notes": "..."
   }

3. Create tests/ folder and add test cases:
   problems/4/tests/test1.json
   problems/4/tests/test2.json
   etc.

4. (GUI only) Add description.pdf:
   problems/4/description.pdf

5. Restart the judge - new problem appears automatically!

───────────────────────────────────────────────────────────

✏️  MODIFYING A PROBLEM

To change test cases:
- Edit existing testN.json files
- Add new testN.json files
- Delete unwanted test files

To change problem info:
- Edit info.json
- Update description.pdf (GUI)

Changes take effect immediately on next run!

───────────────────────────────────────────────────────────

🗑️  REMOVING A PROBLEM

Simply delete or rename the problem folder.
Example: Rename "1/" to "_1_disabled/"

───────────────────────────────────────────────────────────

⚠️  IMPORTANT NOTES

1. Problem IDs are determined by folder names (must be numbers)
2. Test files are loaded in alphabetical order
3. Both CLI and GUI read the same test cases
4. PDF files are only used by GUI (CLI doesn't need them)
5. JSON files must be valid (use a JSON validator)
6. Use \n for newlines in input/output strings

───────────────────────────────────────────────────────────

🎯 EXAMPLES

Valid input strings:
  "5\n0 1 2 3 4\n"
  "3\n1 3 1\n"
  "1\n12\n"

Valid output strings:
  "10\n"
  "Yes\n"
  "+\n-\n+\n"

═══════════════════════════════════════════════════════════

Last Updated: November 2025
Version: 2.0 (Dynamic Problems)
