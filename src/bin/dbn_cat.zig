// stdlib imports
const std = @import("std");
const builtin = @import("builtin");

// local imports
const dbn = @import("dbn");
const RecordIterator = dbn.iter.RecordIterator;

const Format = enum {
    meta,
    any,
    count,
    csv,
    tsv,
    json,
    zon,
};

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

    if (args.len < 2) {
        std.debug.print("Usage: {s} <file.dbn or file.dbn.zst> [format]\n", .{args[0]});
        return;
    }

    const file_path = args[1];

    const format = if (args.len < 3) Format.any else std.meta.stringToEnum(Format, args[2]) orelse {
        std.debug.print("Error: Unknown format '{s}'. Use 'meta', 'any', 'count', 'csv', 'tsv', 'json', or 'zon'\n", .{args[2]});
        return error.InvalidFormat;
    };

    var iter = try RecordIterator.init(allocator, file_path);
    defer iter.deinit();

    // Create the buffered writer for stdout
    var buffer: [4096]u8 = undefined;
    var stdout = std.fs.File.stdout().writerStreaming(&buffer);
    var writer = &stdout.interface;

    // Print metadata only
    if (format == .meta) {
        try iter.meta.print(writer);
        try writer.flush();
        return;
    }

    // Print all records
    var record_count: usize = 0;
    while (try iter.next()) |record| {
        record_count += 1;
        const hd = switch (record) {
            inline else => |v| switch (v) {
                inline else => |r| r.hd,
            },
        };
        switch (format) {
            .meta => unreachable,
            .any => try writer.print("Record {d}: {any} {any}\n", .{ record_count, hd, record }),
            .count => {
                if (record_count % 100_000 == 0) {
                    try writer.print("{d}\n", .{record_count});
                    try writer.flush();
                }
            },
            .csv => {
                if (record_count == 1) {
                    try record.printCsvHeader(writer);
                }
                try record.printCsvRow(writer);
            },
            .tsv => {
                if (record_count == 1) {
                    try record.printTsvHeader(writer);
                }
                try record.printTsvRow(writer);
            },
            .json => try record.printJson(writer),
            .zon => try record.printZon(writer),
        }
    }

    try writer.print("\nTotal records: {d}\n", .{record_count});

    try writer.flush();
}
