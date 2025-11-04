// Problem 1: A. Holiday Of Equality
// Correct solution
#include <iostream>
#include <algorithm>
using namespace std;

int main() {
    int n;
    cin >> n;
    
    int a[100];
    int maxVal = 0;
    
    for (int i = 0; i < n; i++) {
        cin >> a[i];
        maxVal = max(maxVal, a[i]);
    }
    
    int sum = 0;
    for (int i = 0; i < n; i++) {
        sum += (maxVal - a[i]);
    }
    
    cout << sum << endl;
    
    return 0;
}
