const std = @import("std");

// should take as input from Python:
// - a list of sets
// - a list of dictionaries where each letter has it's own probability
// - a matrix of probabilities + a list of row labels

// copied from Python's bisect_right
pub fn searchSorted(arr: []const f64, sort_val: f64) usize {
    var low: usize = 0;
    var high = arr.len;

    while (low < high) {
        const mid = @divFloor(low + high, 2);

        if (sort_val < arr[mid]) {
            high = mid;
        }
        else
        {
            low = mid + 1;
        }
    }
    return low;
}


pub fn cumsum(probs: []const f64, cdf: []f64) void {
    std.debug.assert(probs.len == cdf.len);

    // cumulative sum
    var total: f64 = 0;
    for (probs, 0..) |prob, index| {
        total = total + prob;
        cdf[index] = total;
    }

    // normalize by the total because floating point arithmetic, even though the total should be 1.0
    for (cdf, 0..) |_, index| {
        cdf[index] = cdf[index] / total;
    }
}


pub fn chooseWeighted(comptime T: type, arr: []const T, probs: []const f64, cdf: []f64, chosen: []T, rand: *const std.rand.Random) void {
    cumsum(probs, cdf);

    for (chosen, 0..) |_, index| {
        chosen[index] = arr[searchSorted(cdf, rand.float(f64))];
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    const rand = prng.random();

    var arr: []const u8 = "world";
    const probs: []const f64 = &[_]f64{0.2, 0.2, 0.1, 0.1, 0.4};
    const cdf = try allocator.alloc(f64, probs.len);
    const chosen = try allocator.alloc(u8, 10000);

    chooseWeighted(u8, arr, probs, cdf, chosen, &rand);
    for (chosen) |char| {
        std.debug.print("{c} ", .{char});
    }
}
