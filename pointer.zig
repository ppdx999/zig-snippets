const std = @import("std");

test "pointer" {
    var x: u8 = 42;

    // get address of x
    var ptr_x: *u8 = &x;

    var y: u8 = 0;

    // dereference
    y = ptr_x.*;

    try std.testing.expect(y == 42);
}

fn sideEffectableAdd(x: *u8, y: u8) void {
    x.* += y;
}

test "side effectable add" {
    var x: u8 = 42;
    var p: *u8 = &x;
    sideEffectableAdd(p, 10);
    try std.testing.expect(x == 52);
}
