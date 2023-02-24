const std = @import("std");

// choose a single item from an array
pub fn choose(comptime T: type, arr: *[]const T, rand: *const std.rand.Random) T {
    const idx = rand.uintLessThan(usize, arr.*.len);
    return arr.*[idx];
}

pub fn main() !void {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();
    var arr: []const u8 = "world";

    const idx = rand.uintLessThan(usize, arr.len);
    std.debug.print("Outside func, {} {c}\n", .{idx, arr[idx]});

    const item = choose(u8, &arr, &rand);
    std.debug.print("From func, {c}\n", .{item});
}
