#include <bits/stdc++.h>
using namespace std;

struct node {
    int i, j, step, dir;
};

bool operator<(const node a, const node b) {
    return tuple<int, int, int, int>(a.i, a.j, a.step, a.dir) < tuple<int, int, int, int>(b.i, b.j, b.step, b.dir);
}

#define UP 0
#define DOWN 1
#define LEFT 2
#define RIGHT 3

#define INF 2147483647

int main()
{
    string line;
    vector<vector<char>> loss;

    while (cin >> line)
        loss.push_back(vector<char>(line.begin(), line.end()));

    int n = loss.size(), m = loss[0].size();

    map<node, vector<node>> g;
    for (int i = 0; i < n; i++) for (int j = 0; j < m; j++) for (int step = 1; step <= 3; step++) {
        if (i > 0 && step < 3) g[{i, j, step, UP}].push_back({i-1, j, step+1, UP});
        if (j > 0) g[{i, j, step, UP}].push_back({i, j-1, 1, LEFT});
        if (j+1 < m) g[{i, j, step, UP}].push_back({i, j+1, 1, RIGHT});
        
        if (i+1 < n && step < 3) g[{i, j, step, DOWN}].push_back({i+1, j, step+1, DOWN});
        if (j > 0) g[{i, j, step, DOWN}].push_back({i, j-1, 1, LEFT});
        if (j+1 < m) g[{i, j, step, DOWN}].push_back({i, j+1, 1, RIGHT});

        if (j > 0 && step < 3) g[{i, j, step, LEFT}].push_back({i, j-1, step+1, LEFT});
        if (i > 0) g[{i, j, step, LEFT}].push_back({i-1, j, 1, UP});
        if (i+1 < n) g[{i, j, step, LEFT}].push_back({i+1, j, 1, DOWN});

        if (j+1 < m && step < 3) g[{i, j, step, RIGHT}].push_back({i, j+1, step+1, RIGHT});
        if (i > 0) g[{i, j, step, RIGHT}].push_back({i-1, j, 1, UP});
        if (i+1 < n) g[{i, j, step, RIGHT}].push_back({i+1, j, 1, DOWN});
    }

    node start = {0, 0, 0, RIGHT};
    g[start].push_back({0, 1, 1, RIGHT});
    g[start].push_back({1, 0, 1, DOWN});

    int dist[n][m][4][4];
    for (int i = 0; i < n; i++) for (int j = 0; j < n; j++)
         for (int step = 0; step < 4; step++) for (int dir = 0; dir < 4; dir++)
            dist[i][j][step][dir] = INF;
    dist[0][0][0][RIGHT] = 0;

    auto cmp = [](pair<int, node> a, pair<int, node> b) { return a.first > b.first; };
    priority_queue<pair<int, node>, vector<pair<int, node>>, decltype(cmp)> pq(cmp);
    pq.push({0, start});

    while (!pq.empty()) {
        int d = pq.top().first;
        node v = pq.top().second;
        pq.pop();
        if (d > dist[v.i][v.j][v.step][v.dir]) continue;
        for (node u : g[v]) {
            int new_dist = dist[v.i][v.j][v.step][v.dir] + (loss[u.i][u.j] - '0');
            if (new_dist < dist[u.i][u.j][u.step][u.dir]) {
                dist[u.i][u.j][u.step][u.dir] = new_dist;
                pq.push({new_dist, u});
            }
        }
    }

    int minloss = INF;
    for (int step = 1; step <= 3; step++) for (int dir = DOWN; dir <= RIGHT; dir += 2)
        minloss = min(minloss, dist[n-1][m-1][step][dir]);

    cout << minloss << endl;

    return 0;
}
