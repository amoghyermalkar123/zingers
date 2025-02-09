const std = @import("std");

const Allocator = std.mem.Allocator;

pub fn main() !void {
    var allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer allocator.deinit();

    var l = SomeType.init(allocator.allocator());
    try l.sometype_buffer.append('q');

    for (l.sometype_buffer.items, 0..) |value, i| {
        _ = i;
        std.debug.print("{c}\n", .{value});
    }
}

const SomeType = struct {
    sometype_buffer: std.ArrayList(u8),

    const Self = @This();

    pub fn init(allocator: Allocator) Self {
        var list = std.ArrayList(u8).init(allocator);

        defer list.deinit();
        list.append(24) catch unreachable;
        list.append(25) catch unreachable;
        list.append(26) catch unreachable;

        return .{
            .sometype_buffer = list,
        };
    }

    pub fn deinit(self: *Self) void {
        self.sometype_buffer.deinit();
    }
};
