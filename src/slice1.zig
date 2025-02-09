const std = @import("std");

const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer switch (gpa.deinit()) {
        .ok => {},
        .leak => @panic("memory leak re baba"),
    };

    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();

    var at = Atype.init(arena.allocator());
    const str = try at.add("amogh");
    at.slice = str;
    at.slice = "amogh";
    try at.print();
}

const Atype = struct {
    allocator: Allocator,
    slice: []const u8 = "ishan",

    const Self = @This();

    pub fn init(allocator: Allocator) Self {
        return .{
            .allocator = allocator,
        };
    }

    pub fn add(self: *Self, str: []const u8) ![]u8 {
        const temp = try self.allocator.alloc(u8, str.len);
        return temp;
    }

    pub fn print(self: *Self) !void {
        std.debug.print("str: {s}\n", .{self.slice});
    }
};
