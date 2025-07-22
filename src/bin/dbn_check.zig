// stdlib imports
const std = @import("std");
const builtin = @import("builtin");

// local imports
const dbn = @import("dbn");
const RecordIterator = dbn.iter.RecordIterator;
const RType = dbn.enums.RType;

pub fn main() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa: {
        if (builtin.os.tag == .wasi) break :gpa std.heap.wasm_allocator;
        break :gpa switch (builtin.mode) {
            .Debug, .ReleaseSafe => debug_allocator.allocator(),
            .ReleaseFast, .ReleaseSmall => std.heap.smp_allocator,
        };
    };
    defer _ = debug_allocator.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 2) {
        std.debug.print("Usage: {s} <file.dbn or file.dbn.zst>\n", .{args[0]});
        return;
    }

    const file_path = args[1];

    var iter = try RecordIterator.init(allocator, file_path);
    defer iter.deinit();

    try iter.meta.check();

    // Initialize statistics tracking
    var rtype_counts = std.AutoHashMap(RType, u64).init(allocator);
    defer rtype_counts.deinit();

    // Count records
    var record_count: u64 = 0;
    while (try iter.next()) |record| {
        record_count += 1;

        // Extract the RType from the record
        const rtype = switch (record) {
            inline else => |v| switch (v) {
                inline else => |msg| msg.hd.rtype,
            },
        };

        // Update count for this RType
        const entry = try rtype_counts.getOrPut(rtype);
        if (!entry.found_existing) {
            entry.value_ptr.* = 0;
        }
        entry.value_ptr.* += 1;
    }

    var stdout = std.fs.File.stdout().deprecatedWriter();

    // Check if limit matches record count
    if (iter.meta.limit) |limit| {
        if (limit == record_count) {
            try stdout.print("OK\n", .{});
        } else {
            try stdout.print("ERROR: metadata.limit ({d}) != record_count ({d})\n", .{ limit, record_count });
        }
    } else {
        try stdout.print("WARNING: metadata.limit is null, found {d} records\n", .{record_count});
    }

    try stdout.print("\n", .{});

    // Fill the counts array
    var counts: [256]u64 = [_]u64{0} ** 256;
    var rtype_iter = rtype_counts.iterator();
    while (rtype_iter.next()) |entry| {
        const rtype = @intFromEnum(entry.key_ptr.*);
        counts[rtype] += entry.value_ptr.*;
    }

    // Print the counts
    for (counts, 0..) |count, i| {
        if (count > 0) {
            const chars = @as(usize, @intFromFloat(60.0 * @as(f64, @floatFromInt(count)) / @as(f64, @floatFromInt(record_count))));
            const rtype = try std.meta.intToEnum(RType, i);
            try stdout.print("{s}: {d:<11} │", .{ @tagName(rtype), count });
            for (0..chars) |_| {
                try stdout.print("■", .{});
            }
            try stdout.print("\n", .{});
        }
    }

    try stdout.print("\ntotal: {d}\n", .{record_count});
}
