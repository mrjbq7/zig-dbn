// stdlib imports
const std = @import("std");
const builtin = @import("builtin");
const zstd = std.compress.zstd;

// local imports
const dbn = @import("dbn");
const metadata = dbn.metadata;
const record = dbn.record;
const enums = dbn.enums;
const RType = enums.RType;

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

    if (args.len < 3) {
        std.debug.print("Usage: {s} <input file.dbn or file.dbn.zst> <output file.dbn or file.dbn.zst> [<version>]\n", .{args[0]});
        return;
    }

    const input_path = args[1];
    const output_path = args[2];

    if (std.mem.endsWith(u8, output_path, ".zst")) {
        std.debug.print("Output file type .zst not currently supported\n", .{});
        return;
    }

    const version_number = if (args.len > 3) std.fmt.parseInt(u32, args[3], 10) catch {
        std.debug.print("Invalid version number: {s}\n", .{args[3]});
        return;
    } else 3;
    const version = std.enums.fromInt(enums.Version, version_number) orelse {
        std.debug.print("Invalid version number: {d}\n", .{version_number});
        return;
    };

    std.debug.print("Converting {s} to {s} version {t}\n", .{ input_path, output_path, version });

    // Open the input file
    const input_file = try std.fs.cwd().openFile(input_path, .{});
    defer input_file.close();

    var input_buffer: [4096]u8 = undefined;
    var input_reader = input_file.reader(&input_buffer);

    var reader: *std.io.Reader = &input_reader.interface;

    var zstd_buffer: ?[]u8 = null;
    var zstd_reader: ?zstd.Decompress = null;

    // Check for compressed files
    if (std.mem.endsWith(u8, input_path, ".zst")) {
        zstd_buffer = try allocator.alloc(u8, zstd.default_window_len + zstd.block_size_max);
        zstd_reader = zstd.Decompress.init(&input_reader.interface, zstd_buffer.?, .{});
        reader = &zstd_reader.?.reader;
    }

    // Open the output file
    const output_file = try std.fs.cwd().createFile(output_path, .{});
    defer output_file.close();

    var output_buffer: [4096]u8 = undefined;
    var output_writer = output_file.writer(&output_buffer);

    // TODO: arg for output format, if not specified use .v3

    // Read metadata
    var meta = try metadata.readMetadata(allocator, reader);
    defer meta.deinit();

    if (meta.version == version) {
        std.debug.print("Version {any} is already the target version\n", .{version});
        return;
    }

    // TODO: convert and write metadata

    // Convert and write records
    while (try meta.readRecord(reader)) |rec| {
        try output_writer.interface.print("{any}\n", .{rec});
    }

    try output_writer.interface.flush();
}
