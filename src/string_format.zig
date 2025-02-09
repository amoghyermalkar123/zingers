const std = @import("std");
const Allocator = std.mem.Allocator;

pub const ID = struct {
    client: u64,
    clock: u64,
};

test "basic" {
    var ar = std.AutoHashMap(ID, void).init(std.heap.page_allocator);
    defer ar.deinit();

    try ar.put(.{
        .client = 1,
        .clock = 1,
    }, {});

    try ar.put(.{
        .client = 1,
        .clock = 0,
    }, {});

    var w = ar.keyIterator();
    var next = w.next();
    while (next != null) {
        const s = try std.fmt.allocPrint(ar.allocator, "client {d}: clock:{d} | ", .{ next.?.client, next.?.clock });
        std.debug.print("{s}", .{s});
        next = w.next();
    }
}
