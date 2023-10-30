const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    try stdout.print("Args: {s}\n", .{args});
}
