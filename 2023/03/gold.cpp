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
        // char numbers = 0b00000000;
        // int count = 0;
        // if (i > 0 && DIGIT(schem[i-1][j])) numbers |= 0b00000010, count++;
        // else {
        //     if (i > 0 && j > 0   && DIGIT(schem[i-1][j-1])) numbers |= 0b00000001, count++;
        //     if (i > 0 && j < m-1 && DIGIT(schem[i-1][j+1])) numbers |= 0b00000100, count++;
        // }
        // if (j > 0   && DIGIT(schem[i][j-1])) numbers |= 0b00001000, count++;
        // if (j < m-1 && DIGIT(schem[i][j+1])) numbers |= 0b00010000, count++;
        // if (i < n-1 && DIGIT(schem[i+1][j])) numbers |= 0b01000000, count++;
        // else {
        //     if (i < n-1 && j > 0   && DIGIT(schem[i+1][j-1])) numbers |= 0b00100000, count++;
        //     if (i < n-1 && j < m-1 && DIGIT(schem[i+1][j+1])) numbers |= 0b10000000, count++;
        // }
        //
        // if (count != 2) continue;
        //
        cout << i << ' ' << j << " : ";

        int mult = 1, count = 0;
        for (int ik = i-1; ik <= i+1; ik++) for (int jk = j-1; jk <= j+1; jk++) {
            if (ik >= 0 && jk >= 0 && ik < n && jk < m && DIGIT(schem[ik][jk])) {
                while (jk > 0 && DIGIT(schem[ik][jk-1])) jk--;
                int num = 0;
                while (DIGIT(schem[ik][jk])) num = 10*num + schem[ik][jk] - '0', jk++;
                cout << num << " ";
                mult *= num, count++;
            }
        }

        cout << "-> " << mult << ' ';

        if (count == 2) total += mult;
        if (count == 2) cout << "YES\n"; else cout << "NO\n";
    }

    cout << total << endl;

    return 0;
}
