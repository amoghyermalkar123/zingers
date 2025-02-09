const std = @import("std");

const Allocator = std.mem.Allocator;

pub fn main() !void {
    var allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer allocator.deinit();

    var l = al(allocator.allocator());
    try l.append('s');

    std.debug.print("{s}", .{l.items});
}

pub fn al(alloc: Allocator) *std.ArrayList(u8) {
    var l = std.ArrayList(u8).init(alloc);
    return &l;
}
