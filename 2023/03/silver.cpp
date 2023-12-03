#include <bits/stdc++.h>
using namespace std;

#define DIGIT(c) ('0' <= (c) && (c) <= '9')
#define SYMBOL(c) ((c) != '.' && !DIGIT(c))

int main()
{
    vector<vector<char>> schem;
    string line;
    while (cin >> line)
        schem.push_back(vector<char>(line.begin(), line.end()));

    int n = schem.size(), m = schem[0].size();

    int total = 0;

    for (int i = 0; i < n; i++) for (int j = 0; j < m; j++) {
        if (DIGIT(schem[i][j])) {
            int number = schem[i][j] - '0';
            
            bool counts = false;
            counts = counts
                || (i > 0 && j > 0 && SYMBOL(schem[i-1][j-1]))
                || (j > 0 && SYMBOL(schem[i][j-1]))
                || (i < n-1 && j > 0 && SYMBOL(schem[i+1][j-1]))
                || (i > 0 && SYMBOL(schem[i-1][j]))
                || (i < n-1 && SYMBOL(schem[i+1][j]));

            while (++j < m && DIGIT(schem[i][j])) {
                number = 10*number + schem[i][j] - '0';
                counts = counts
                    || (i > 0 && SYMBOL(schem[i-1][j]))
                    || (i < n-1 && SYMBOL(schem[i+1][j]));
            }
            
            if (j < m) counts = counts
                || (i > 0 && SYMBOL(schem[i-1][j]))
                || SYMBOL(schem[i][j])
                || (i < n-1 && SYMBOL(schem[i+1][j]));

            if (counts) total += number;
        }
    }

    cout << total << endl;

    return 0;
}
