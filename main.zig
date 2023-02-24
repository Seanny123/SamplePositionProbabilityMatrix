const std = @import("std");

// should take as input from Python:
// - a list of sets
// - a list of dictionaries where each letter has it's own probability
// - a matrix of probabilities + a list of row labels

// TODO: how do I set array the type to be any numerical type?
// copied from Python's bisect_right
pub fn searchSorted(arr: *[]const f64, sort_val: f64) usize {
    var low: usize = 0;
    var high = arr.length;
    while (low < high) {
        const mid = @divFloor(low + high, 2);

        if (sort_val < arr[mid]) {
            high = mid;
        }
        else
        {
            low = mid;
        }
    }
    return low;
}


// lol, I have no idea what type to use for the probabilities to be compatible with Python
pub fn chooseWeighted(comptime T: type, arr: *[]const T, rand: *const std.rand.Random, p: []const f64) T {
    var cdf = std.mem.zeroes([std.mem.len(arr)]f64);
    //var cdf = [_]f64{0} * arr.*.len;


    // cumsum
    var total: f64 = 0;
    for (p) |prob, index| {
        total = total + prob;
        cdf[index] = total;
    }

    // normalize by the total because floating point arithmetic, even though the total should be 1.0
    for (cdf) |_, index| {
        cdf[index] = cdf[index] / total;
    }

    // how do I make an empty array of a given size?
    // should this be a constant?
    var chosen = [arr.len]T{};

    // this is where the parallel could happen! I think I want a threadpool and not os threads though?
    for (chosen) |_, index| {
        // generate several random floats rand.float
        // get index using searchsorted
        chosen[index] = arr.*[searchSorted(arr, rand.float())];
    }
    
    return chosen;
}

pub fn main() !void {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();
    var arr: []const u8 = "world";
    const prob: []const f64 = &[_]f64{0.2, 0.2, 0.1, 0.1, 0.4};
    const w_item = chooseWeighted(u8, &arr, &rand, prob);
    std.debug.print("Hello, {c}\n", .{w_item});
}
