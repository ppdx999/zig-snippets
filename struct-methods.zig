const std = @import("std");
const builtin = @import("builtin");
const stdout = std.io.getStdOut().writer();

const Win = struct {
    pub const Self = @This();

    pub fn init() !Self {
        try stdout.print("Win.init\n", .{});
        return Self{};
    }

    pub fn print(self: Win) !void {
        _ = self;
        try stdout.print("Win.print\n", .{});
    }

    pub fn deinit(self: Win) !void {
        _ = self;
        try stdout.print("Win.deinit\n", .{});
    }
};

const Posix = struct {
    pub const Self = @This();

    pub fn init() !Self {
        try stdout.print("Posix.init\n", .{});
        return Self{};
    }

    pub fn print(self: Posix) !void {
        _ = self;
        try stdout.print("Posix.print\n", .{});
    }

    pub fn deinit(self: Posix) !void {
        _ = self;
        try stdout.print("Posix.deinit\n", .{});
    }
};

pub fn main() !void {
    const obj = switch (builtin.os.tag) {
        .windows => try Win.init(),
        else => try Posix.init(),
    };

    try obj.print();

    try obj.deinit();
}
