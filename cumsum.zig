const std = @import("std");

pub fn cumsum(probs: *[]const f64, cdf: *[]f64) void {
    // cumulative sum
    var total: f64 = 0;
    for (probs.*, 0..) |prob, index| {
        total = total + prob;
        cdf.*[index] = total;
    }

    // normalize by the total because floating point arithmetic, even though the total should be 1.0
    for (cdf.*, 0..) |_, index| {
        cdf.*[index] = cdf.*[index] / total;
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var probs: []const f64 = &[_]f64{ 0.2, 0.2, 0.1, 0.1, 0.4 };
    var cdf = try allocator.alloc(f64, probs.len);

    cumsum(&probs, &cdf);
    std.debug.print("probs:\n", .{});
    for (probs) |prob| {
        std.debug.print("{} ", .{prob});
    }

    std.debug.print("\ncdfs:\n", .{});
    for (cdf) |cum| {
        std.debug.print("{} ", .{cum});
    }
}
