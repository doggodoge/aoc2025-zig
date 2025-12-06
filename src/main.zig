const std = @import("std");
const aoc2025_zig = @import("aoc2025_zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const gpa_allocator = gpa.allocator();
    const args = try std.process.argsAlloc(gpa_allocator);
    defer std.process.argsFree(gpa_allocator, args);

    if (args.len < 3) {
        std.debug.print("Usage: {s} <input_file> <day>\n", .{args[0]});
        return;
    }

    const input_file_path = args[1];
    const day_str = args[2];
    const day = try std.fmt.parseInt(u32, day_str, 10);

    var arena = std.heap.ArenaAllocator.init(gpa_allocator);
    defer arena.deinit();
    const arena_allocator = arena.allocator();

    switch (day) {
        1 => {
            const p1_result = try aoc2025_zig.day_one.p1(arena_allocator, input_file_path);
            const p2_result = try aoc2025_zig.day_one.p2(arena_allocator, input_file_path);
            std.debug.print("Day one puzzle one: {d}\n", .{p1_result});
            std.debug.print("Day one puzzle two: {d}\n", .{p2_result});
        },
        2 => {
            const p1_result = try aoc2025_zig.day_two.p1(arena_allocator, input_file_path);
            std.debug.print("Day two puzzle one: {d}\n", .{p1_result});
        },
        else => {
            std.debug.print("Invalid day: {d}\n", .{day});
        },
    }
}
