const std = @import("std");
const grid = @import("grid.zig");

// ---- Shared ---- //

// ---- Part 1 ---- //

pub fn part1(filename: []const u8, allocator: std.mem.Allocator) !u32 {
    _ = allocator;

    var buf: [1024 * 1024]u8 = undefined;
    const input = try std.fs.cwd().readFile(filename, &buf);
    const wordsearch = grid.Grid(u8).init(input, "\n");

    var numFound: u32 = 0;

    for (0..wordsearch.numRows) |y| for (0..wordsearch.numCols) |x| {
        search: for ([_]grid.Direction{ .ul, .u, .ur, .l, .r, .dl, .d, .dr }) |dir| {
            var pos = grid.Position{ .x = x, .y = y };
            for ("XMAS") |c| {
                const char = wordsearch.at(pos) catch continue :search;
                if (char != c) continue :search;
                pos = pos.step(dir);
            }
            numFound += 1;
        }
    };

    return numFound;
}

// ---- Part 2 ---- //

pub fn part2(filename: []const u8, allocator: std.mem.Allocator) !u32 {
    _ = allocator;

    var buf: [1024 * 1024]u8 = undefined;
    const input = try std.fs.cwd().readFile(filename, &buf);
    const wordsearch = grid.Grid(u8).init(input, "\n");

    var numFound: u32 = 0;

    for (0..wordsearch.numRows) |y| for (0..wordsearch.numCols) |x| {
        const pos = grid.Position{ .x = x, .y = y };
        const center = wordsearch.at(pos) catch continue;
        if (center != 'A') continue;
        const corners = [_]u8{
            wordsearch.at(pos.step(.ul)) catch continue,
            wordsearch.at(pos.step(.ur)) catch continue,
            wordsearch.at(pos.step(.dl)) catch continue,
            wordsearch.at(pos.step(.dr)) catch continue,
        };
        switch (corners[0]) {
            'M' => if (corners[3] != 'S') continue,
            'S' => if (corners[3] != 'M') continue,
            else => continue,
        }
        switch (corners[1]) {
            'M' => if (corners[2] != 'S') continue,
            'S' => if (corners[2] != 'M') continue,
            else => continue,
        }
        numFound += 1;
    };

    return numFound;
}

// ---- Misc ---- //

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var args = std.process.args();
    _ = args.skip();
    const part = (args.next() orelse "_")[0];
    const result = switch (part) {
        '1' => try part1("input", allocator),
        '2' => try part2("input", allocator),
        else => return error.NoPartSupplied,
    };

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{result});
}

test part1 {
    const allocator = std.testing.allocator;
    const result = try part1("test", allocator);
    try std.testing.expectEqual(18, result);
}

test part2 {
    const allocator = std.testing.allocator;
    const result = try part2("test", allocator);
    try std.testing.expectEqual(9, result);
}
