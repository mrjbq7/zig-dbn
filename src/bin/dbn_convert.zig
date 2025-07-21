// stdlib imports
const std = @import("std");
const builtin = @import("builtin");

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
    const version = std.meta.intToEnum(enums.Version, version_number) catch {
        std.debug.print("Invalid version number: {d}\n", .{version_number});
        return;
    };

    std.debug.print("Converting {s} to {s} version {t}\n", .{ input_path, output_path, version });

    // Open the input file
    const input_file = try std.fs.cwd().openFile(input_path, .{});
    defer input_file.close();

    var buffered_input = std.io.bufferedReader(input_file.deprecatedReader());
    var input_reader = buffered_input.reader();

    // Create reader - check if file ends with .zst for compression
    var reader: std.io.AnyReader = undefined;
    var window_buffer: [std.compress.zstd.DecompressorOptions.default_window_buffer_len]u8 = undefined;
    var decompressor: ?std.compress.zstd.Decompressor(@TypeOf(input_reader)) = null;

    if (std.mem.endsWith(u8, input_path, ".zst")) {
        decompressor = std.compress.zstd.decompressor(input_reader, .{ .window_buffer = &window_buffer });
        reader = decompressor.?.reader().any();
    } else {
        reader = input_reader.any();
    }

    // Open the output file
    const output_file = try std.fs.cwd().createFile(output_path, .{});
    defer output_file.close();

    var buffered_output = std.io.bufferedWriter(output_file.deprecatedWriter());
    const output_writer = buffered_output.writer();

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
        try output_writer.print("{any}\n", .{rec});
    }

    try buffered_output.flush();
}
