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

    const chars2 = "0123456789";
    var array2 = try setRandomChars(allocator, chars2, 5, 5);
    defer freeRandomChars(allocator, array2);

    try stdout.print("array2: {s}\n", .{array2});
}

fn setRandomCharsv2(allocator: std.mem.Allocator, chars: []const u8, len: u32, count: u32) ![][:0]u8 {
    // allocate a memory block that is large enough to hold all the strings
    const contents_bytes = try math.mul(usize, @sizeOf([]u8), count * (len + 1));
    const slice_list_bytes = try math.mul(usize, @sizeOf(usize), count);
    const total_bytes = try math.add(usize, contents_bytes, slice_list_bytes);
    const buf = try allocator.alignedAlloc(u8, @alignOf([]u8), total_bytes);

    // create a slice list that points to the memory block
    const slice_list = buf[0..slice_list_bytes];
    var contents_index: usize = 0;
    for (slice_list, 0..) |_, i| {
        slice_list[i] = buf[slice_list_bytes + contents_index ..];
        contents_index += len + 1;
    }

    // fill the memory block with random strings
    var rand = prng.init(@intCast(time.milliTimestamp()));
    for (slice_list) |slice| {
        var i: u32 = 0;
        while (i < len) : (i += 1) {
            const c = chars[rand.random().int(u32) % chars.len];
            slice[i] = c;
        }
        slice[len] = 0;
    }

    return slice_list;
}

fn freeRandomCharsv2(allocator: std.mem.Allocator, slice: []const [:0]u8) void {
    const slice_list_bytes = try math.mul(usize, @sizeOf(usize), slice.len);
    const contents_bytes = try math.mul(usize, @sizeOf([]u8), slice.len * (slice[0].len + 1));
    const total_bytes = try math.add(usize, slice_list_bytes, contents_bytes);
    const buf = slice.ptr - slice_list_bytes;
    const unaligned_allocated_buf = @as([*]const u8, @ptrCast(buf))[0..total_bytes];
    const aligned_allocated_buf: []align(@alignOf([]u8)) const u8 = @alignCast(unaligned_allocated_buf);
    return allocator.free(aligned_allocated_buf);
}

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
