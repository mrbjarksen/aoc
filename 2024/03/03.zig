const std = @import("std");

// ---- Shared ---- //

pub fn mulSum(filename: []const u8, useDisables: bool) !u64 {
    const input = try std.fs.cwd().openFile(filename, .{ .mode = .read_only });

    var total: u64 = 0;
    var num1: u32 = 0;
    var num2: u32 = 0;
    var state: u8 = 0;
    while (input.reader().readByte() catch null) |char| {
        state = switch (std.mem.readInt(u16, &[2]u8{ state, char }, .big)) {
            0x0000 + 'm' => blk: {
                num1 = 0;
                num2 = 0;
                break :blk 1;
            },
            0x0100 + 'u' => 2,
            0x0200 + 'l' => 3,
            0x0300 + '(' => 4,
            0x0400 + '0'...0x0400 + '9', 0x0500 + '0'...0x0500 + '9' => blk: {
                num1 = 10 * num1 + char - '0';
                break :blk 5;
            },
            0x0500 + ',' => 6,
            0x0600 + '0'...0x0600 + '9', 0x0700 + '0'...0x0700 + '9' => blk: {
                num2 = 10 * num2 + char - '0';
                break :blk 7;
            },
            0x0700 + ')' => blk: {
                total += num1 * num2;
                break :blk 0;
            },

            0x0000 + 'd' => 0x11,
            0x1100 + 'o' => 0x12,
            0x1200 + 'n' => 0x13,
            0x1300 + '\'' => 0x14,
            0x1400 + 't' => 0x15,
            0x1500 + '(' => 0x16,
            0x1600 + ')' => if (useDisables) 0x20 else 0,

            0x2000 + 'd' => 0x21,
            0x2100 + 'o' => 0x22,
            0x2200 + '(' => 0x23,
            0x2300 + ')' => 0,

            else => state & 0x20,
        };
    }

    return total;
}

// ---- Part 1 ---- //

pub fn part1(filename: []const u8, allocator: std.mem.Allocator) !u64 {
    _ = allocator;
    return try mulSum(filename, false);
}

// ---- Part 2 ---- //

pub fn part2(filename: []const u8, allocator: std.mem.Allocator) !u64 {
    _ = allocator;
    return try mulSum(filename, true);
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
    const result = try part1("test1", allocator);
    try std.testing.expectEqual(161, result);
}

test part2 {
    const allocator = std.testing.allocator;
    const result = try part2("test2", allocator);
    try std.testing.expectEqual(48, result);
}
