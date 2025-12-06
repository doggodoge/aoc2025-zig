const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn p1(allocator: Allocator, path: []const u8) !u64 {
    const ranges = try parseFile(allocator, path);

    for (ranges) |range| {
        std.debug.print("{any}\n", .{range});
    }

    return 0;
}

const Range = struct {
    start: u64,
    end: u64,
};

fn parseFile(allocator: Allocator, path: []const u8) ![]const Range {
    const data = try std.fs.cwd().readFileAlloc(allocator, path, std.math.maxInt(usize));
    defer allocator.free(data);

    var ranges_str_iter = std.mem.splitScalar(u8, data, ',');
    var ranges = std.ArrayList(Range){};

    while (ranges_str_iter.next()) |range_str| {
        var split_range = std.mem.splitScalar(u8, range_str, '-');
        const left = split_range.next().?;
        const right = split_range.next().?;

        const left_int = try std.fmt.parseInt(u64, left, 10);
        const right_int = try std.fmt.parseInt(u64, right, 10);

        const range: Range = .{
            .start = left_int,
            .end = right_int,
        };

        try ranges.append(allocator, range);
    }

    return ranges.toOwnedSlice(allocator);
}
