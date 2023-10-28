const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const file = try std.fs.cwd().openFile("sample.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    try stdout.print("file size: {d}\n", .{file_size});

    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();

    const contents = try reader.readAllAlloc(allocator, file_size);
    defer allocator.free(contents);

    try stdout.print("read file value: {s}\n", .{contents});
}
