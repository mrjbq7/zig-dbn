// stdlib imports
const std = @import("std");
const builtin = @import("builtin");

// local imports
const dbn = @import("dbn");
const metadata = dbn.metadata;
const record = dbn.record;

const Format = enum {
    meta,
    any,
    csv,
    json,
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
        std.debug.print("Error: Unknown format '{s}'. Use 'meta', 'any', 'csv', or 'json'\n", .{args[2]});
        return error.InvalidFormat;
    };

    // Open the file
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.deprecatedReader());
    var buffered_reader = buffered.reader();

    // Create reader - check if file ends with .zst for compression
    var reader: std.io.AnyReader = undefined;
    var window_buffer: [std.compress.zstd.DecompressorOptions.default_window_buffer_len]u8 = undefined;
    var decompressor: ?std.compress.zstd.Decompressor(@TypeOf(buffered_reader)) = null;

    if (std.mem.endsWith(u8, file_path, ".zst")) {
        decompressor = std.compress.zstd.decompressor(buffered_reader, .{ .window_buffer = &window_buffer });
        reader = decompressor.?.reader().any();
    } else {
        reader = buffered_reader.any();
    }

    // Read and print metadata
    var meta = try metadata.readMetadata(allocator, reader);
    defer meta.deinit();

    // Create the buffered writer for stdout
    var buffer: [4096]u8 = undefined;
    var stdout = std.fs.File.stdout().writerStreaming(&buffer);
    var writer = &stdout.interface;

    // Print metadata only
    if (format == .meta) {
        try meta.print(writer);
        try writer.flush();
        return;
    }

    // Print all records
    var record_count: usize = 0;
    while (try meta.readRecord(reader)) |rec| {
        record_count += 1;
        const hd = switch (rec) {
            inline else => |v| switch (v) {
                inline else => |r| r.hd,
            },
        };
        switch (format) {
            .meta => unreachable,
            .any => {
                try writer.print("Record {d}: {any} {any}\n", .{ record_count, hd, rec });
            },
            .csv => {
                if (record_count == 1) {
                    try rec.printCsvHeader(writer);
                }
                try rec.printCsvRow(writer);
            },
            .json => {
                try rec.printJson(writer);
            },
        }
    }

    try writer.print("\nTotal records: {d}\n", .{record_count});

    try writer.flush();
}
