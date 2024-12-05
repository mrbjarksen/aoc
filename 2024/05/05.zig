const std = @import("std");

// ---- Shared ---- //

const Rule = struct {
    before: u8,
    after: u8,
};

fn getRules(input: []const u8, allocator: std.mem.Allocator) ![]Rule {
    var rules = std.ArrayList(Rule).init(allocator);
    errdefer rules.deinit();

    var lines = std.mem.splitSequence(u8, input, "\n");
    while (lines.next()) |line| {
        var pages = std.mem.splitSequence(u8, line, "|");
        try rules.append(Rule{
            .before = try std.fmt.parseInt(u8, pages.first(), 10),
            .after = try std.fmt.parseInt(u8, pages.rest(), 10),
        });
    }

    return rules.toOwnedSlice();
}

fn getUpdates(input: []const u8, allocator: std.mem.Allocator) ![][]u8 {
    var updates = std.ArrayList([]u8).init(allocator);
    errdefer {
        for (updates.items) |update| {
            allocator.free(update);
        }
        updates.deinit();
    }

    var lines = std.mem.splitSequence(u8, input, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var pages = std.mem.splitSequence(u8, line, ",");
        var update = std.ArrayList(u8).init(allocator);
        while (pages.next()) |page| {
            try update.append(try std.fmt.parseInt(u8, page, 10));
        }
        try updates.append(try update.toOwnedSlice());
    }

    return updates.toOwnedSlice();
}

// ---- Part 1 ---- //

pub fn part1(filename: []const u8, allocator: std.mem.Allocator) !u32 {
    var buf: [1024 * 1024]u8 = undefined;
    const input = try std.fs.cwd().readFile(filename, &buf);
    var split = std.mem.splitSequence(u8, input, "\n\n");

    const rules = try getRules(split.first(), allocator);
    const updates = try getUpdates(split.rest(), allocator);

    defer {
        allocator.free(rules);
        for (updates) |update| {
            allocator.free(update);
        }
        allocator.free(updates);
    }

    var total: u32 = 0;
    updates: for (updates) |update| {
        for (update, 1..) |pageBefore, i| {
            for (update[i..]) |pageAfter| {
                for (rules) |rule| {
                    if (rule.before == pageAfter and rule.after == pageBefore) {
                        continue :updates;
                    }
                }
            }
        }
        total += update[update.len / 2];
    }

    return total;
}

// ---- Part 2 ---- //

pub fn part2(filename: []const u8, allocator: std.mem.Allocator) !u32 {
    var buf: [1024 * 1024]u8 = undefined;
    const input = try std.fs.cwd().readFile(filename, &buf);
    var split = std.mem.splitSequence(u8, input, "\n\n");

    const rules = try getRules(split.first(), allocator);
    const updates = try getUpdates(split.rest(), allocator);

    defer {
        allocator.free(rules);
        for (updates) |update| {
            allocator.free(update);
        }
        allocator.free(updates);
    }

    var total: u32 = 0;
    for (updates) |update| {
        var swapped: bool = false;
        for (update, 1..) |*pageBefore, i| {
            for (update[i..]) |*pageAfter| {
                for (rules) |rule| {
                    if (rule.before == pageAfter.* and rule.after == pageBefore.*) {
                        const tmp = pageAfter.*;
                        pageAfter.* = pageBefore.*;
                        pageBefore.* = tmp;
                        swapped = true;
                    }
                }
            }
        }
        if (swapped) total += update[update.len / 2];
    }

    return total;
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
    try std.testing.expectEqual(143, result);
}

test part2 {
    const allocator = std.testing.allocator;
    const result = try part2("test", allocator);
    try std.testing.expectEqual(123, result);
}
