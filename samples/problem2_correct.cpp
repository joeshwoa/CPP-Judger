// Problem 2: A. Odd Set
// Correct solution
#include <iostream>
using namespace std;

int main() {
    int t;
    cin >> t;
    
    while (t--) {
        int n;
        cin >> n;
        
        int odd_count = 0;
        int even_count = 0;
        
        for (int i = 0; i < 2 * n; i++) {
            int x;
            cin >> x;
            if (x % 2 == 1) {
                odd_count++;
            } else {
                even_count++;
            }
        }
        
        // To form n pairs with odd sums, we need n odd numbers and n even numbers
        if (odd_count == n && even_count == n) {
            cout << "Yes" << endl;
        } else {
            cout << "No" << endl;
        }
    }
    
    return 0;
}
