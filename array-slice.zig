const std = @import("std");
const stdout = std.io.getStdOut().writer();

test "array_and_slice" {
    var array = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqual([5]i32, @TypeOf(array));

    var K: usize = 0;

    var slice = array[0..K];
    try std.testing.expectEqual([]i32, @TypeOf(slice));
}

test "mutable_and_imutable_array" {
    var mutable_array = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqual([5]i32, @TypeOf(mutable_array));

    const immutable_array = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqual([5]i32, @TypeOf(immutable_array));
}

test "slice_from_immutable_array" {
    const immutable_array = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqual([5]i32, @TypeOf(immutable_array));

    var K: usize = 0;

    var mutable_slice = immutable_array[0..K];
    try std.testing.expectEqual([]const i32, @TypeOf(mutable_slice));

    const immutable_slice = immutable_array[0..K];
    try std.testing.expectEqual([]const i32, @TypeOf(immutable_slice));

    // if the length of the slice is known at compile time,
    // zig handle the type of the slice as a pointer to an array
    var mutable_ptr_to_array = immutable_array[0..];
    try std.testing.expectEqual(*const [5]i32, @TypeOf(mutable_ptr_to_array));

    // if the length of the slice is unknown at compile time,
    // zig handle the type of the slice as a pointer to an array
    const immutable_ptr_to_array = immutable_array[0..];
    try std.testing.expectEqual(*const [5]i32, @TypeOf(immutable_ptr_to_array));
}

test "slice_from_mutable_array" {
    var mutable_array = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqual([5]i32, @TypeOf(mutable_array));

    var K: usize = 0;

    var mutable_slice = mutable_array[0..K];
    try std.testing.expectEqual([]i32, @TypeOf(mutable_slice));

    const immutable_slice = mutable_array[0..K];
    try std.testing.expectEqual([]i32, @TypeOf(immutable_slice));

    // if the length of the slice is known at compile time,
    // zig handle the type of the slice as a pointer to an array
    var mutable_ptr_to_array = mutable_array[0..];
    try std.testing.expectEqual(*[5]i32, @TypeOf(mutable_ptr_to_array));

    // if the length of the slice is unknown at compile time,
    // zig handle the type of the slice as a pointer to an array
    const immutable_ptr_to_array = mutable_array[0..];
    try std.testing.expectEqual(*[5]i32, @TypeOf(immutable_ptr_to_array));
}
