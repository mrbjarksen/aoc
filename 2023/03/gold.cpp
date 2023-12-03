#include <bits/stdc++.h>
using namespace std;

#define DIGIT(c) ('0' <= (c) && (c) <= '9')

int main()
{
    vector<vector<char>> schem;
    string line;
    while (cin >> line)
        schem.push_back(vector<char>(line.begin(), line.end()));

    int n = schem.size(), m = schem[0].size();

    int total = 0;

    for (int i = 0; i < n; i++) for (int j = 0; j < m; j++) if (schem[i][j] == '*') {
        int mult = 1, count = 0;
        for (int ik = i-1; ik <= i+1; ik++) for (int jk = j-1; jk <= j+1; jk++) {
            if (ik >= 0 && jk >= 0 && ik < n && jk < m && DIGIT(schem[ik][jk])) {
                while (jk > 0 && DIGIT(schem[ik][jk-1])) jk--;
                int num = 0;
                while (DIGIT(schem[ik][jk])) num = 10*num + schem[ik][jk] - '0', jk++;
                mult *= num, count++;
            }
        }
        if (count == 2) total += mult;
    }

    cout << total << endl;

    return 0;
}
