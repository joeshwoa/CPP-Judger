class Problem {
  final int id;
  final String title;
  final String timeLimit;
  final String memoryLimit;
  final String description;
  final String inputFormat;
  final String outputFormat;
  final List<Example> examples;
  final String? notes;
  final String? pdfPath;

  Problem({
    required this.id,
    required this.title,
    required this.timeLimit,
    required this.memoryLimit,
    required this.description,
    required this.inputFormat,
    required this.outputFormat,
    required this.examples,
    this.notes,
    this.pdfPath,
  });

  static List<Problem> getAllProblems() {
    return [
      Problem(
        id: 1,
        title: 'A. Holiday Of Equality',
        timeLimit: '1 second',
        memoryLimit: '256 megabytes',
        description:
            'In Berland it is the holiday of equality. In honor of the holiday the king decided to equalize the welfare of all citizens in Berland by the expense of the state treasury.\n\n'
            'Totally in Berland there are n citizens, the welfare of each of them is estimated as the integer in aᵢ burles (burle is the currency in Berland).\n\n'
            'You are the royal treasurer, which needs to count the minimum charges of the kingdom on the king\'s present. The king can only give money, he hasn\'t a power to take away them.',
        inputFormat:
            'The first line contains the integer n (1 ≤ n ≤ 100) — the number of citizens in the kingdom.\n\n'
            'The second line contains n integers a₁, a₂, ..., aₙ, where aᵢ (0 ≤ aᵢ ≤ 10⁶) — the welfare of the i-th citizen.',
        outputFormat:
            'In the only line print the integer S — the minimum number of burles which are had to spend.',
        examples: [
          Example(input: '5\n0 1 2 3 4', output: '10'),
          Example(input: '5\n1 1 0 1 1', output: '1'),
          Example(input: '3\n1 3 1', output: '4'),
          Example(input: '1\n12', output: '0'),
        ],
        notes:
            'In the first example if we add to the first citizen 4 burles, to the second 3, to the third 2 and to the fourth 1, then the welfare of all citizens will equal 4.\n\n'
            'In the second example it is enough to give one burle to the third citizen.\n\n'
            'In the third example it is necessary to give two burles to the first and the third citizens to make the welfare of citizens equal 3.\n\n'
            'In the fourth example it is possible to give nothing to everyone because all citizens have 12 burles.',
      ),
      Problem(
        id: 2,
        title: 'A. Odd Set',
        timeLimit: '1 second',
        memoryLimit: '256 megabytes',
        description:
            'You are given a multiset (i.e. a set that can contain multiple equal integers) containing 2n integers. '
            'Determine if you can split it into exactly n pairs (i.e. each element should be in exactly one pair) '
            'so that the sum of the two elements in each pair is odd (i.e. when divided by 2, the remainder is 1).',
        inputFormat:
            'The input consists of multiple test cases. The first line contains an integer t (1≤t≤100) — the number of test cases. The description of the test cases follows.\n\n'
            'The first line of each test case contains an integer n (1≤n≤100).\n\n'
            'The second line of each test case contains 2n integers a₁,a₂,…,a₂ₙ (0≤aᵢ≤100) — the numbers in the set.',
        outputFormat:
            'For each test case, print "Yes" if it can be split into exactly n pairs so that the sum of the two elements in each pair is odd, and "No" otherwise. You can print each letter in any case.',
        examples: [
          Example(input: '5\n2\n2 3 4 5\n3\n2 3 4 5 5 5\n1\n2 4\n1\n2 3\n4\n1 5 3 2 6 7 3 4', output: 'Yes\nNo\nNo\nYes\nNo'),
        ],
        notes:
            'In the first test case, a possible way of splitting the set is (2,3), (4,5).\n\n'
            'In the second, third and fifth test case, we can prove that there isn\'t any possible way.\n\n'
            'In the fourth test case, a possible way of splitting the set is (2,3).',
      ),
      Problem(
        id: 3,
        title: 'A. Plus or Minus',
        timeLimit: '1 second',
        memoryLimit: '256 megabytes',
        description:
            'You are given three integers a, b, and c such that exactly one of these two equations is true:\n'
            '  • a+b=c\n'
            '  • a−b=c\n\n'
            'Output + if the first equation is true, and - otherwise.',
        inputFormat:
            'The first line contains a single integer t (1≤t≤162) — the number of test cases.\n\n'
            'The description of each test case consists of three integers a, b, c (1≤a,b≤9, −8≤c≤18). '
            'The additional constraint on the input: it will be generated so that exactly one of the two equations will be true.',
        outputFormat:
            'For each test case, output either + or - on a new line, representing the correct equation.',
        examples: [
          Example(
            input: '11\n1 2 3\n3 2 1\n2 9 -7\n3 4 7\n1 1 2\n1 1 0\n3 3 6\n9 9 18\n9 9 0\n1 9 -8\n1 9 10',
            output: '+\n-\n-\n+\n+\n-\n+\n+\n-\n-\n+',
          ),
        ],
        notes:
            'In the first test case, 1+2=3.\n\n'
            'In the second test case, 3−2=1.\n\n'
            'In the third test case, 2−9=−7. Note that c can be negative.',
      ),
    ];
  }

  static Problem? getProblemById(int id) {
    try {
      return getAllProblems().firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}

class Example {
  final String input;
  final String output;

  Example({required this.input, required this.output});
}
