const std = @import("std");
const stdout = std.io.getStdOut();

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var client: std.http.Client = .{ .allocator = allocator };
    defer client.deinit();

    const uri = std.Uri.parse("https://catfact.ninja/fact") catch unreachable;

    var req = try client.request(.GET, uri, .{ .allocator = allocator }, .{});
    defer req.deinit();

    try req.start();
    try req.wait();

    const body = req.reader().readAllAlloc(allocator, 8 * 1024) catch unreachable;
    defer allocator.free(body);

    try stdout.writer().print("{s}\n", .{body});
}
