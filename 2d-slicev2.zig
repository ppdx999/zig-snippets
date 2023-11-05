const std = @import("std");

pub fn Slice2d(comptime T: type, comptime _width: usize, comptime _height: usize) type {
    return struct {
        const Self = @This();
        pub const width: usize = _width;
        pub const height: usize = _height;

        data: []T,

        pub fn init(allocator: std.mem.Allocator) !Self {
            return .{
                .data = try allocator.alloc(T, width * height),
            };
        }

        pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
            allocator.free(self.data);
        }

        pub inline fn get(self: Self, x: usize, y: usize) T {
            return self.data[y * width + x];
        }

        pub inline fn set(self: *Self, x: usize, y: usize, value: T) void {
            self.data[y * width + x] = value;
        }
    };
}

test "Slice2d" {
    var slice = try Slice2d(u8, 2, 2).init(std.testing.allocator);
    defer slice.deinit(std.testing.allocator);

    slice.set(0, 0, 1);
    slice.set(1, 0, 2);
    slice.set(0, 1, 3);
    slice.set(1, 1, 4);

    try std.testing.expect(slice.get(0, 0) == 1);
    try std.testing.expect(slice.get(1, 0) == 2);
    try std.testing.expect(slice.get(0, 1) == 3);
    try std.testing.expect(slice.get(1, 1) == 4);
}
