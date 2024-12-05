const std = @import("std");

pub const Position = struct {
    x: usize,
    y: usize,
    pub fn step(self: Position, dir: Direction) Position {
        return Position{
            .x = switch (dir) {
                .ul, .l, .dl => self.x -% 1,
                .ur, .r, .dr => self.x +% 1,
                else => self.x,
            },
            .y = switch (dir) {
                .ul, .u, .ur => self.y -% 1,
                .dl, .d, .dr => self.y +% 1,
                else => self.y,
            },
        };
    }
};

pub const Direction = enum { ul, u, ur, l, o, r, dl, d, dr };

pub fn Grid(comptime T: type) type {
    return struct {
        const Self = @This();

        flattened: []const T,
        terminator: []const T,

        numRows: usize,
        numCols: usize,

        pub fn init(flattened: []const T, terminator: []const T) Self {
            return Self{
                .flattened = flattened,
                .terminator = terminator,
                .numRows = std.mem.count(T, flattened, terminator) +
                    if (std.mem.endsWith(T, flattened, terminator)) @as(usize, 0) else @as(usize, 1),
                .numCols = std.mem.indexOf(T, flattened, terminator) orelse 1,
            };
        }

        pub fn at(self: Self, position: Position) !T {
            if (position.x >= self.numCols or position.y >= self.numRows) {
                return error.OutOfBounds;
            }
            return self.flattened[position.y * (self.numCols + self.terminator.len) + position.x];
        }
    };
}
