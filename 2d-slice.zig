const std = @import("std");
const stdout = std.io.getStdOut().writer();
const tt = std.testing;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var slice = try make2dSlice(allocator, u8, 3, 4);
    defer free2dSlice(allocator, u8, slice) catch unreachable;

    for (0..3) |i| {
        for (0..4) |j| {
            slice[i][j] = @intCast(i * 4 + j);
        }
    }

    for (slice) |row| {
        for (row) |elem| {
            try stdout.print("{d}, ", .{elem});
        }
        try stdout.print("\n", .{});
    }
}

fn make2dSlice(alc: std.mem.Allocator, comptime T: type, row_size: usize, col_size: usize) ![][]T {
    const cntnt_bytes = try std.math.mul(usize, @sizeOf(T), row_size * col_size);
    const slice_bytes = try std.math.mul(usize, @sizeOf([]T), row_size);
    const total_bytes = try std.math.add(usize, cntnt_bytes, slice_bytes);
    const buf = try alc.alignedAlloc(u8, @alignOf([]T), total_bytes);
    errdefer alc.free(buf);

    const slice = std.mem.bytesAsSlice([]T, buf[0..slice_bytes]);
    for (0..row_size) |i| {
        const start = slice_bytes + i * col_size;
        const end = start + col_size;
        slice[i] = buf[start..end];
    }
    return slice;
}

fn free2dSlice(alc: std.mem.Allocator, comptime T: type, slice: []const []T) !void {
    const slice_bytes = try std.math.mul(usize, @sizeOf([]T), slice.len);
    const cntnt_bytes = try std.math.mul(usize, @sizeOf(T), slice[0].len * slice.len);
    const total_bytes = try std.math.add(usize, cntnt_bytes, slice_bytes);

    const unaligned_buf = @as([*]const T, @ptrCast(slice.ptr))[0..total_bytes];
    const buf: []align(@alignOf([]T)) const T = @alignCast(unaligned_buf);
    return alc.free(buf[0..total_bytes]);
}

fn get(matrix: []u8, row: usize, col: usize) u8 {
    const width = matrix[0].len;
    return matrix[row * width + col];
}

test "2d slice with one contiguous allocation" {
    const alc = std.testing.allocator;
    const row_size: usize = 3;
    const col_size: usize = 4;

    const slice = try make2dSlice(alc, u8, row_size, col_size);
    defer free2dSlice(alc, u8, slice) catch unreachable;

    try tt.expect(slice.len == row_size);
    for (0..row_size) |i| {
        try tt.expect(slice[i].len == col_size);
    }
}
