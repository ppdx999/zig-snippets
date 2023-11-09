const std = @import("std");
const stdout = std.io.getStdOut().writer();
const tt = std.testing;

pub fn main() !void {
    var arr = [_]i32{ 3, 2, 1 };
    for (arr) |elem| {
        try stdout.print("{d}, ", .{elem});
    }
    std.mem.sort(i32, &arr, {}, std.sort.asc(i32));
    for (arr) |elem| {
        try stdout.print("{d}, ", .{elem});
    }

    try stdout.print("\n", .{});

    var arr2 = [_]Foo{
        .{ .a = 3, .b = 3 },
        .{ .a = 2, .b = 2 },
        .{ .a = 1, .b = 1 },
    };
    for (arr2) |elem| {
        try stdout.print("{d}, ", .{elem.a});
    }
    std.mem.sort(Foo, &arr2, {}, lessThan);
    for (arr2) |elem| {
        try stdout.print("{d}, ", .{elem.a});
    }
}

test "sort array" {
    var arr = [_]i32{ 3, 2, 1 };
    for (arr) |elem| {
        try stdout.print("{d}, ", .{elem});
    }
    std.mem.sort(i32, &arr, {}, std.sort.asc(i32));
    for (arr) |elem| {
        try stdout.print("{d}, ", .{elem});
    }

    try tt.expect(arr[0] == 1);
    try tt.expect(arr[1] == 2);
    try tt.expect(arr[2] == 3);
}

const Foo = struct {
    a: i32,
    b: i32,
};

fn lessThan(_: void, a: Foo, b: Foo) bool {
    return a.a < b.a;
}

test "sort struct" {
    var arr = [_]Foo{
        .{ .a = 3, .b = 3 },
        .{ .a = 2, .b = 2 },
        .{ .a = 1, .b = 1 },
    };
    for (arr) |elem| {
        try stdout.print("{d}, ", .{elem.a});
    }
    std.mem.sort(Foo, &arr, {}, lessThan);
    for (arr) |elem| {
        try stdout.print("{d}, ", .{elem.a});
    }

    try tt.expect(arr[0].a == 1);
    try tt.expect(arr[1].a == 2);
    try tt.expect(arr[2].a == 3);
}
