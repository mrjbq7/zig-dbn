const std = @import("std");
const builtin = @import("builtin");
const zstd = std.compress.zstd;

const constants = @import("constants.zig");
const Metadata = @import("metadata.zig").Metadata;
const readRepeatedSymbols = @import("metadata.zig").readRepeatedSymbols;
const readSymbolMappings = @import("metadata.zig").readSymbolMappings;
const Schema = @import("enums.zig").Schema;
const SType = @import("enums.zig").SType;
const v1 = @import("v1.zig");

const FIXED_METADATA_LEN: usize = 96;
const METADATA_DATASET_CSTR_LEN: usize = 16;
const SCHEMA_VERSION: u8 = 1;
const VERSION_CSTR_LEN: usize = 4;
const RESERVED_LEN: usize = 39;

pub fn readMetadata(allocator: std.mem.Allocator, reader: *std.Io.Reader) !Metadata {
    const magic = try reader.takeInt(u32, .little);
    if (magic < 0x184D2A50 or magic > 0x184D2A5F) {
        return error.BadMagic;
    }

    const frameSize = try reader.takeInt(u32, .little);
    if (frameSize < FIXED_METADATA_LEN) {
        return error.InvalidMetadata;
    }

    const buffer = try allocator.alloc(u8, frameSize);
    defer allocator.free(buffer);
    try reader.readSliceAll(buffer);

    return try parseMetadata(allocator, buffer);
}

pub fn parseMetadata(allocator: std.mem.Allocator, buffer: []u8) !Metadata {
    var reader: std.Io.Reader = .fixed(buffer);

    var metadata = Metadata.init(allocator);
    metadata.symbol_cstr_len = v1.SYMBOL_CSTR_LEN;
    errdefer metadata.deinit();

    const magic = try reader.take(3);
    if (!std.mem.eql(u8, magic, "DBZ")) return error.InvalidDbz;

    const version = try reader.takeByte();
    if (version != SCHEMA_VERSION) return error.InvalidDbz;
    metadata.version = .v1; // XXX: .v0?

    // Read dataset
    const dataset_slice = try reader.take(METADATA_DATASET_CSTR_LEN);
    const dataset_str = std.mem.sliceTo(dataset_slice, 0);
    metadata.dataset = try allocator.dupe(u8, dataset_str);

    const raw_schema = try reader.takeInt(u16, .little);
    metadata.schema = std.enums.fromInt(Schema, raw_schema).?;

    // Read timestamps
    metadata.start = try reader.takeInt(u64, .little);

    const end_ts = try reader.takeInt(u64, .little);
    metadata.end = if (end_ts == constants.UNDEF_TIMESTAMP) null else end_ts;

    const limit_val = try reader.takeInt(u64, .little);
    metadata.limit = if (limit_val == 0) null else limit_val;

    // Skip over the deprecated record count
    try reader.discardAll(8);

    // Skip over the unused compression
    try reader.discardAll(1);

    // Read stype_in
    const stype_in = try reader.takeByte();
    metadata.stype_in = std.enums.fromInt(SType, stype_in).?;

    // Read stype_out
    const stype_out = try reader.takeByte();
    metadata.stype_out = std.enums.fromInt(SType, stype_out).?;

    try reader.discardAll(RESERVED_LEN);

    // XXX: fix this
    var out: std.Io.Writer.Allocating = .init(allocator);
    defer out.deinit();
    try out.ensureUnusedCapacity(zstd.default_window_len);
    var zstd_reader = zstd.Decompress.init(&reader, &.{}, .{});
    _ = try zstd_reader.reader.streamRemaining(&out.writer);
    const zstd_buffer = out.written();

    var new_reader: std.Io.Reader = .fixed(zstd_buffer);

    const schema_definition_length = try new_reader.takeInt(u32, .little);
    if (schema_definition_length != 0) return error.InvalidDbz;
    try new_reader.discardAll(schema_definition_length);

    metadata.symbols = try readRepeatedSymbols(allocator, v1.SYMBOL_CSTR_LEN, &new_reader);
    metadata.partial = try readRepeatedSymbols(allocator, v1.SYMBOL_CSTR_LEN, &new_reader);
    metadata.not_found = try readRepeatedSymbols(allocator, v1.SYMBOL_CSTR_LEN, &new_reader);
    metadata.mappings = try readSymbolMappings(allocator, v1.SYMBOL_CSTR_LEN, &new_reader);

    return metadata;
}

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

    const path = if (args.len > 1) args[1] else "test_data/test_data.mbo.dbz";

    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const reader = file.deprecatedReader();

    var metadata = try readMetadata(allocator, reader);
    defer metadata.deinit();

    const stdout = std.fs.File.stdout().deprecatedWriter();
    try metadata.print(stdout);

    var window_buffer: [std.compress.zstd.DecompressorOptions.default_window_buffer_len]u8 = undefined;
    var decompressor = std.compress.zstd.decompressor(reader, .{ .window_buffer = &window_buffer });
    const decompressor_reader = decompressor.reader();

    while (try metadata.readRecord(decompressor_reader)) |record| {
        std.debug.print("{any}\n", .{record});
    }
}
