const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

pub fn p1(allocator: Allocator, path: []const u8) !u64 {
    const data = try readFile(allocator, path);
    const instructions = try parseInstructions(allocator, data);

    var current_combination: i64 = 50;
    var zero_count: u64 = 0;

    for (instructions) |instruction| {
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

pub fn p2(allocator: Allocator, path: []const u8) !u64 {
    const data = try readFile(allocator, path);
    const instructions = try parseInstructions(allocator, data);

    var current_position: i64 = 50;
    var zero_count: u64 = 0;

    for (instructions) |instruction| {
        var distance_left = instruction.distance;

        if (instruction.direction == .left) {
            while (distance_left > 0) {
                const new_position = current_position - 1;

                if (new_position == -1) {
                    current_position = 99;
                } else {
                    current_position = new_position;
                }

                if (current_position == 0) {
                    zero_count += 1;
                }

                distance_left -= 1;
            }
        }

        if (instruction.direction == .right) {
            while (distance_left > 0) {
                const new_position = current_position + 1;

                if (new_position == 100) {
                    current_position = 0;
                } else {
                    current_position = new_position;
                }

                if (current_position == 0) {
                    zero_count += 1;
                }

                distance_left -= 1;
            }
        }
    }

    return zero_count;
}

const Direction = enum { left, right };

const Instruction = struct {
    direction: Direction,
    distance: i64,
};

fn parseInstructions(allocator: Allocator, data: []const u8) ![]Instruction {
    var instructions = std.ArrayList(Instruction){};
    var lines = std.mem.splitScalar(u8, data, '\n');

    while (lines.next()) |line| {
        const instruction = try parseInstruction(line);
        try instructions.append(allocator, instruction);
    }

    return instructions.toOwnedSlice(allocator);
}

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

    return .{ .direction = direction, .distance = distance };
}

fn readFile(allocator: Allocator, path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_contents = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    return file_contents;
}
