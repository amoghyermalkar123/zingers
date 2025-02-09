const std = @import("std");

// ANSI color codes for pretty output
const colors = struct {
    const reset = "\x1b[0m";
    const bold = "\x1b[1m";
    const red = "\x1b[31m";
    const green = "\x1b[32m";
    const yellow = "\x1b[33m";
    const blue = "\x1b[34m";
    const magenta = "\x1b[35m";
    const cyan = "\x1b[36m";
};

pub const TestCase = struct {
    name: []const u8,
    func: *const fn () anyerror!void,
};

pub const TestResult = struct {
    name: []const u8,
    duration_ns: u64,
    passed: bool,
    error_msg: ?[]const u8,
};

pub const TestRunner = struct {
    allocator: std.mem.Allocator,
    tests: std.ArrayList(TestCase),
    results: std.ArrayList(TestResult),
    total_duration_ns: u64,

    pub fn init(allocator: std.mem.Allocator) TestRunner {
        return .{
            .allocator = allocator,
            .tests = std.ArrayList(TestCase).init(allocator),
            .results = std.ArrayList(TestResult).init(allocator),
            .total_duration_ns = 0,
        };
    }

    pub fn deinit(self: *TestRunner) void {
        self.tests.deinit();
        self.results.deinit();
    }

    pub fn addTest(self: *TestRunner, name: []const u8, func: *const fn () anyerror!void) !void {
        try self.tests.append(.{ .name = name, .func = func });
    }

    pub fn run(self: *TestRunner) !void {
        const start_time = try std.time.Instant.now();

        // Print header
        try self.printHeader();

        // Run all tests
        for (self.tests.items) |test_case| {
            const test_start = try std.time.Instant.now();
            const result = self.runSingleTest(test_case);
            const test_end = try std.time.Instant.now();
            const duration = test_end.since(test_start);

            try self.results.append(.{
                .name = test_case.name,
                .duration_ns = duration,
                .passed = result == null,
                .error_msg = result,
            });

            try self.printTestResult(self.results.items[self.results.items.len - 1]);
        }

        const end_time = try std.time.Instant.now();
        self.total_duration_ns = end_time.since(start_time);

        // Print summary
        try self.printSummary();
    }

    fn runSingleTest(self: *TestRunner, test_case: TestCase) ?[]const u8 {
        test_case.func() catch |err| {
            return std.fmt.allocPrint(self.allocator, "Error: {s}", .{@errorName(err)}) catch return "Memory allocation failed";
        };
        return null;
    }

    fn printHeader(self: *TestRunner) !void {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("\n{s}Running {d} tests...{s}\n\n", .{
            colors.bold,
            self.tests.items.len,
            colors.reset,
        });
    }

    fn printTestResult(self: *TestRunner, result: TestResult) !void {
        _ = self;

        const stdout = std.io.getStdOut().writer();
        const status_color = if (result.passed) colors.green else colors.red;
        const status_text = if (result.passed) "PASS" else "FAIL";
        const duration_ms = @as(f64, @floatFromInt(result.duration_ns)) / 1_000_000.0;

        try stdout.print("{s}{s:<4}{s} {s}{s:<30}{s} {s}({d:.2}ms){s}", .{
            status_color,
            status_text,
            colors.reset,
            colors.bold,
            result.name,
            colors.reset,
            colors.cyan,
            duration_ms,
            colors.reset,
        });

        if (result.error_msg) |msg| {
            try stdout.print(" - {s}{s}{s}", .{ colors.red, msg, colors.reset });
        }
        try stdout.print("\n", .{});
    }

    fn printSummary(self: *TestRunner) !void {
        const stdout = std.io.getStdOut().writer();
        var passed: usize = 0;
        var failed: usize = 0;

        for (self.results.items) |result| {
            if (result.passed) {
                passed += 1;
            } else {
                failed += 1;
            }
        }

        const total_duration_ms = @as(f64, @floatFromInt(self.total_duration_ns)) / 1_000_000.0;

        try stdout.print("\n{s}Test Summary:{s}\n", .{ colors.bold, colors.reset });
        try stdout.print("  Total:  {d} tests\n", .{self.tests.items.len});
        try stdout.print("  {s}Passed:{s}  {d} tests\n", .{ colors.green, colors.reset, passed });
        if (failed > 0) {
            try stdout.print("  {s}Failed:{s}  {d} tests\n", .{ colors.red, colors.reset, failed });
        }
        try stdout.print("  Time:   {d:.2}ms\n\n", .{total_duration_ms});
    }
};

// Example test functions
fn testPass() !void {
    // Simulate some work
    std.time.sleep(10 * std.time.ns_per_ms);
    try std.testing.expect(true);
}

fn testFail() !void {
    // Simulate some work
    std.time.sleep(5 * std.time.ns_per_ms);
    try std.testing.expect(false);
}

/// zig run src/test_runner.zig
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var runner = TestRunner.init(allocator);
    defer runner.deinit();

    // Add some test cases
    try runner.addTest("Simple passing test", testPass);
    try runner.addTest("Simple failing test", testFail);
    try runner.addTest("Another passing test", testPass);

    // Run all tests
    try runner.run();
}
