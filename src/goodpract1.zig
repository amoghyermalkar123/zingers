const std = @import("std");

const Allocator = std.mem.Allocator;

pub fn main() !void {
    var allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer allocator.deinit();

    var l = SomeType.init(allocator.allocator());
    try l.sometype_buffer.append(12);

    std.debug.print("{d}", .{l.sometype_buffer.items});
}

const SomeType = struct {
    sometype_buffer: std.ArrayList(u64),

    const Self = @This();

    pub fn init(allocator: Allocator) Self {
        var list = std.ArrayList(u64).init(allocator);

        // defer also works
        errdefer list.deinit();
        return .{
            .sometype_buffer = &list,
        };
    }

    pub fn deinit(self: *Self) void {
        self.sometype_buffer.deinit();
    }
};
