const std = @import("std");

// ---- Header ---- //

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
    try std.testing.expectEqual(result, 11);
}

test part2 {
    const allocator = std.testing.allocator;
    const result = try part2("test", allocator);
    try std.testing.expectEqual(result, 31);
}

// ---- Part 1 ---- //

const Lists = struct {
    left: []u32,
    right: []u32,
};

fn getSortedLists(filename: []const u8, allocator: std.mem.Allocator) !Lists {
    const input = try std.fs.cwd().openFile(filename, .{ .mode = .read_only });
    defer input.close();

    var firstList = std.ArrayList(u32).init(allocator);
    var secondList = std.ArrayList(u32).init(allocator);

    var buf: [32]u8 = undefined;
    while (try input.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var nums = std.mem.splitSequence(u8, line, "   ");
        try firstList.append(try std.fmt.parseInt(u32, nums.next().?, 10));
        try secondList.append(try std.fmt.parseInt(u32, nums.next().?, 10));
    }

    const firstSlice = try firstList.toOwnedSlice();
    const secondSlice = try secondList.toOwnedSlice();

    std.mem.sort(u32, firstSlice, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, secondSlice, {}, comptime std.sort.asc(u32));

    return .{ .left = firstSlice, .right = secondSlice };
}

pub fn part1(filename: []const u8, allocator: std.mem.Allocator) !u32 {
    const lists = try getSortedLists(filename, allocator);
    defer allocator.free(lists.left);
    defer allocator.free(lists.right);

    var totalDist: u32 = 0;
    for (lists.left, lists.right) |leftNum, rightNum| {
        if (leftNum > rightNum) {
            totalDist += leftNum - rightNum;
        } else {
            totalDist += rightNum - leftNum;
        }
    }

    return totalDist;
}

// ---- Part 2 ---- //

const Counts = struct {
    left: std.AutoHashMap(u32, u16),
    right: std.AutoHashMap(u32, u16),
};

fn getCounts(filename: []const u8, allocator: std.mem.Allocator) !Counts {
    const input = try std.fs.cwd().openFile(filename, .{ .mode = .read_only });
    defer input.close();

    var firstCounts = std.AutoHashMap(u32, u16).init(allocator);
    var secondCounts = std.AutoHashMap(u32, u16).init(allocator);

    var buf: [32]u8 = undefined;
    while (try input.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var nums = std.mem.splitSequence(u8, line, "   ");

        const firstNum = try std.fmt.parseInt(u32, nums.next().?, 10);
        try firstCounts.put(firstNum, 1 + (firstCounts.get(firstNum) orelse 0));

        const secondNum = try std.fmt.parseInt(u32, nums.next().?, 10);
        try secondCounts.put(secondNum, 1 + (secondCounts.get(secondNum) orelse 0));
    }

    return .{ .left = firstCounts, .right = secondCounts };
}

pub fn part2(filename: []const u8, allocator: std.mem.Allocator) !u32 {
    var counts = try getCounts(filename, allocator);
    defer counts.left.deinit();
    defer counts.right.deinit();

    var score: u32 = 0;
    var iterator = counts.left.keyIterator();
    while (iterator.next()) |num| {
        const leftCount = counts.left.get(num.*) orelse 0;
        const rightCount = counts.right.get(num.*) orelse 0;
        score += num.* * leftCount * rightCount;
    }
    return score;
}
