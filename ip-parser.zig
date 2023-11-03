const std = @import("std");
const stdout = std.io.getStdOut().writer();
const tt = std.testing;

fn countLen(it: anytype) u8 {
    var count: u8 = 0;
    while (it.next()) |_| {
        count += 1;
    }
    it.reset();
    return count;
}

fn validIpv4(text: []const u8) bool {
    // 数字と.以外の文字が含まれている場合は不正
    for (text) |c| {
        if ((c < '0' or c > '9') and c != '.') {
            return false;
        }
    }

    // 4つのパートに分割する。
    // ex) 192.168.1.1 -> ["192", "168", "1", "1"]
    var it = std.mem.split(u8, text, ".");

    // 4つのパートに分割できない場合は不正
    if (countLen(&it) != 4) {
        return false;
    }

    while (it.next()) |part| {
        // 12..0のように連続するドットがある場合は不正
        if (part.len == 0) {
            return false;
        }

        // 0で始まる数字は不正
        if (part[0] == '0' and part.len > 1) {
            return false;
        }

        var value: u32 = 0;
        for (part) |c| {
            value = value * 10 + (c - '0');
        }

        // 255より大きい数字が含まれている場合は不正
        if (value > 255) {
            return false;
        }
    }

    return true;
}

test "validIpv4" {
    const TestCase = struct {
        text: []const u8,
        expected: bool,
    };

    const inputs = [_]TestCase{
        .{ .text = "0.0.0.0", .expected = true },
        .{ .text = "192.168.0.1", .expected = true },
        .{ .text = "10.0.0.1", .expected = true },
        .{ .text = "255.255.255.255", .expected = true },
        .{ .text = "127.0.0.1", .expected = true },
        .{ .text = "172.16.0.1", .expected = true },
        .{ .text = "100.100.100.100", .expected = true },
        .{ .text = "8.8.8.8", .expected = true },
        .{ .text = "192.0.2.1", .expected = true },
        .{ .text = "198.51.100.1", .expected = true },
        .{ .text = "203.0.113.1", .expected = true },
        .{ .text = "169.254.0.1", .expected = true },
        .{ .text = "1.2.3.4", .expected = true },
        .{ .text = "192.168.1.10", .expected = true },
        .{ .text = "10.10.10.10", .expected = true },
        .{ .text = "0.0.0.1", .expected = true },
        .{ .text = "192.0.0.1", .expected = true },
        .{ .text = "224.0.0.1", .expected = true },
        .{ .text = "240.0.0.1", .expected = true },
        .{ .text = "198.18.0.1", .expected = true },
        .{ .text = "256.0.0.0", .expected = false },
        .{ .text = "300.300.300.300", .expected = false },
        .{ .text = "192.168.1.256", .expected = false },
        .{ .text = "10.0.0.1.1", .expected = false },
        .{ .text = "192.168.1.", .expected = false },
        .{ .text = "1.2.3", .expected = false },
        .{ .text = "1.2.3.4.", .expected = false },
        .{ .text = "1.2.3..", .expected = false },
        .{ .text = "1.2.3.4.5", .expected = false },
        .{ .text = "19216801", .expected = false },
        .{ .text = "200.10.20.30.40", .expected = false },
        .{ .text = "1000.1000.1000.1000", .expected = false },
        .{ .text = "10.00.0.1", .expected = false },
        .{ .text = "255.256.255.255", .expected = false },
        .{ .text = "255.255.255.256", .expected = false },
        .{ .text = "192.168.0.01", .expected = false },
        .{ .text = "001.2.3.4", .expected = false },
        .{ .text = "00001.2.3.4", .expected = false },
        .{ .text = "12..34.56", .expected = false },
        .{ .text = "abc.def.ghi.jkl", .expected = false },
    };

    for (inputs) |input| {
        const actual = validIpv4(input.text);
        if (actual != input.expected) {
            try stdout.print("text: {s}, expected: {any}, actual: {any}\n", .{ input.text, input.expected, actual });
        }
        try tt.expectEqual(actual, input.expected);
    }
}
