const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

pub fn p1(allocator: Allocator, path: []const u8) !u64 {
    const data = try readFile(allocator, path);
    var lines = std.mem.splitScalar(u8, data, '\n');
    var instructions = std.ArrayList(Instruction){};

    while (lines.next()) |line| {
        const parsed_line = try parseInstruction(line);
        try instructions.append(allocator, parsed_line);
    }

    var current_combination: i64 = 50;
    var zero_count: u64 = 0;

    for (instructions.items) |instruction| {
        switch (instruction.direction) {
            .left => {
                const new_combination = @rem((current_combination - instruction.distance), 100);
                if (new_combination < 0) {
                    current_combination = 100 - @as(i64, @intCast(@abs(new_combination)));
                } else {
                    current_combination = new_combination;
                }
            },
            .right => {
                current_combination = @rem((current_combination + instruction.distance), 100);
            },
        }

        if (current_combination == 0) {
            zero_count += 1;
        }
    }

    return zero_count;
}

const Direction = enum { left, right };

const Instruction = struct {
    direction: Direction,
    distance: i64,
};

fn parseInstruction(line: []const u8) !Instruction {
    const direction_char = line[0];
    var direction: Direction = undefined;
    switch (direction_char) {
        'L' => direction = .left,
        'R' => direction = .right,
        else => return error.NotDirection,
    }

    const distance_str = std.mem.trimEnd(u8, line[1..], " ");
    const distance = try std.fmt.parseInt(i64, distance_str, 10);
    // const practical_distance = @rem(distance, 99) - 50;

    return .{ .direction = direction, .distance = distance };
}

fn readFile(allocator: Allocator, path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_contents = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    return file_contents;
}
