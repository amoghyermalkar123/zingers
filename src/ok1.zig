const std = @import("std");

const Allocator = std.mem.Allocator;

pub fn main() !void {
    var allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer allocator.deinit();

    var l = SomeType.init(allocator.allocator());

    try l.tokens.append(.{
        .key = 2,
        .val = 2,
    });

    l.tokens.items[0] = .{
        .key = 3,
        .val = 3,
    };

    for (l.tokens.items) |i| {
        std.debug.print("{any}\n", .{i});
    }
}

const Token = struct {
    key: u64,
    val: u64,
};

const SomeType = struct {
    tokens: std.ArrayList(Token),

    const Self = @This();

    pub fn init(allocator: Allocator) Self {
        // storing pointers in an already heap allocated structures in an ArrayList is a bad idea
        // to start with. Any write op you do on this DS will mostly invalidate pointers to other existing items
        var list = std.ArrayList(Token).init(allocator);
        defer list.deinit();

        list.append(.{
            .key = 1,
            .val = 1,
        }) catch unreachable;

        return .{
            .tokens = list,
        };
    }

    pub fn deinit(self: *Self) void {
        self.tokens.deinit();
    }
};
