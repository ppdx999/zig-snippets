const std = @import("std");
const math = std.math;
const stdout = std.io.getStdOut().writer();
const prng = std.rand.DefaultPrng;
const time = std.time;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const chars = "abcdefghijklmnopqrstuvwxyz";
    var array = try setRandomChars(allocator, chars, 10, 5);
    defer freeRandomChars(allocator, array);

    try stdout.print("array: {s}\n", .{array});
}

// fn allocSentinel(allocator: std.mem.Allocator, comptime T: type, count: usize, comptime sentinel: T) ![:sentinel]T {
//     var ptr = try allocator.alloc(T, count + 1);
//     ptr[count] = sentinel;
//     return ptr[0..count :sentinel];
// }

fn setRandomChars(allocator: std.mem.Allocator, chars: []const u8, len: u32, count: u32) ![][:0]u8 {
    var rand = prng.init(@intCast(time.milliTimestamp()));

    var contents = std.ArrayList(u8).init(allocator);
    defer contents.deinit();

    var slice_list = std.ArrayList(usize).init(allocator);
    defer slice_list.deinit();

    var i: u32 = 0;
    while (i < count) : (i += 1) {
        var j: u32 = 0;
        var buf = try allocator.alloc(u8, len + 1);

        while (j < len) : (j += 1) {
            const c = chars[rand.random().int(u32) % chars.len];
            buf[j] = c;
        }
        buf[len] = 0;
        try contents.appendSlice(buf[0..buf.len]);
        try slice_list.append(buf.len - 1);
    }

    const contents_slice = contents.items;
    const slice_sizes = slice_list.items;

    const slice_list_bytes = try math.mul(usize, @sizeOf([]u8), slice_sizes.len);
    const total_bytes = try math.add(usize, slice_list_bytes, contents_slice.len);

    const buf = try allocator.alignedAlloc(u8, @alignOf([]u8), total_bytes);
    errdefer allocator.free(buf);

    const result_slice_list = std.mem.bytesAsSlice([:0]u8, buf[0..slice_list_bytes]);
    const result_contents = buf[slice_list_bytes..];
    @memcpy(result_contents[0..contents_slice.len], contents_slice);

    var contents_index: usize = 0;
    for (slice_sizes, 0..) |length, idx| {
        const new_index = contents_index + length;
        result_slice_list[idx] = result_contents[contents_index..new_index :0];
        contents_index = new_index + 1;
    }

    return result_slice_list;
}

fn freeRandomChars(allocator: std.mem.Allocator, array: []const [:0]u8) void {
    var total_bytes: usize = 0;
    for (array) |arg| {
        total_bytes += @sizeOf([]u8) + arg.len + 1;
    }
    const unaligned_allocated_buf = @as([*]const u8, @ptrCast(array.ptr))[0..total_bytes];
    const aligned_allocated_buf: []align(@alignOf([]u8)) const u8 = @alignCast(unaligned_allocated_buf);
    return allocator.free(aligned_allocated_buf);
}
