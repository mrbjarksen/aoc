const std = @import("std");

// ---- Shared ---- //

pub fn isSafeReport(report: []u16, remove: ?u8) bool {
    if (remove == 0) {
        return isSafeReport(report[1..], null);
    }

    var last: i32 = report[0];
    const asc: bool = if (remove == 1) report[2] > report[0] else report[1] > report[0];

    var i: u8 = 1;
    while (report[i] != std.math.maxInt(u16)) : (i += 1) {
        if (i == remove) {
            continue;
        }
        if (@abs(report[i] - last) > 3 or (asc and report[i] <= last) or (!asc and report[i] >= last)) {
            return false;
        }
        last = report[i];
    }

    return true;
}

pub fn getNumSafeReports(filename: []const u8, allowRemove: bool) !u32 {
    const input = try std.fs.cwd().openFile(filename, .{ .mode = .read_only });
    defer input.close();

    var numSafe: u32 = 0;

    var buf: [256]u8 = undefined;
    var report: [256]u16 = undefined;
    while (try input.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        @memset(&report, std.math.maxInt(u16));
        var nums = std.mem.splitSequence(u8, line, " ");
        var count: u8 = 0;
        while (nums.next()) |num| : (count += 1) {
            report[count] = try std.fmt.parseInt(u16, num, 10);
        }

        if (allowRemove) {
            var i: u8 = 0;
            while (report[i] != std.math.maxInt(u16)) : (i += 1) {
                if (isSafeReport(&report, i)) {
                    numSafe += 1;
                    break;
                }
            }
        } else {
            if (isSafeReport(&report, null)) {
                numSafe += 1;
            }
        }
    }

    return numSafe;
}

// ---- Part 1 ---- //

pub fn part1(filename: []const u8, allocator: std.mem.Allocator) !u32 {
    _ = allocator;
    return try getNumSafeReports(filename, false);
}

// ---- Part 2 ---- //

pub fn part2(filename: []const u8, allocator: std.mem.Allocator) !u32 {
    _ = allocator;
    return try getNumSafeReports(filename, true);
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
    try std.testing.expectEqual(2, result);
}

test part2 {
    const allocator = std.testing.allocator;
    const result = try part2("test", allocator);
    try std.testing.expectEqual(4, result);
}
