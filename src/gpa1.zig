const std = @import("std");

const Allocator = std.mem.Allocator;

// In this bit we understand that every initialization of memory needs a de-initialization
// you can see we init a list on line 38 and deinit it on line 39. By the looks of it,
// we only allocate in that area and don't allocate anywhere else in the codebase.
// Still the leak detector will panic and tell you there is a memory leak on line 13 because
// you did not de-initialize the arena allocator. on line 18
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer switch (gpa.deinit()) {
        .ok => {},
        .leak => @panic("memory leak re baba"),
    };

    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();

    const st = SomeType.init(arena.allocator());
    for (st.tokens.items) |val| {
        std.debug.print("{any}\n", .{val});
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
        var list = std.ArrayList(Token).init(allocator);
        // defer list.deinit(); this is not needed because of line 19

        list.append(.{
            .key = 1,
            .val = 1,
        }) catch unreachable;

        return .{
            .tokens = list,
        };
    }
};
