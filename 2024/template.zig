const std = @import("std");

// ---- Shared ---- //

// ---- Part 1 ---- //

pub fn part1(filename: []const u8, allocator: std.mem.Allocator) !u32 {
    _ = filename;
    _ = allocator;
    return error.Unsolved;
}

// ---- Part 2 ---- //

pub fn part2(filename: []const u8, allocator: std.mem.Allocator) !u32 {
    _ = filename;
    _ = allocator;
    return error.Unsolved;
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
    try std.testing.expectEqual(null, result);
}

test part2 {
    const allocator = std.testing.allocator;
    const result = try part2("test", allocator);
    try std.testing.expectEqual(null, result);
}
