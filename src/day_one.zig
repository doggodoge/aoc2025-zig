const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

pub fn solve(allocator: Allocator, path: []const u8) !i64 {
    const data = try readFile(allocator, path);
    var lines = std.mem.splitScalar(u8, data, '\n');
    var instructions = std.ArrayList(Instruction){};

    while (lines.next()) |line| {
        const parsed_line = try parseInstruction(line);
        try instructions.append(allocator, parsed_line);
    }

    var current_combination: i64 = 50;
    std.debug.print("The dail is pointing at:\n\t50\n", .{});

    for (instructions.items) |instruction| {
        switch (instruction.direction) {
            .left => {
                const new_combination = current_combination - instruction.distance;
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
        std.debug.print("\t{d}\n", .{current_combination});
    }

    return current_combination;
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

    return .{ .direction = direction, .distance = distance };
}

fn readFile(allocator: Allocator, path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_contents = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    return file_contents;
}
