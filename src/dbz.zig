const std = @import("std");
const builtin = @import("builtin");

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

pub fn readMetadata(allocator: std.mem.Allocator, reader: anytype) !Metadata {
    const magic = try reader.readInt(u32, .little);
    if (!std.compress.zstd.decompress.isSkippableMagic(magic)) {
        return error.BadMagic;
    }

    const frameSize = try reader.readInt(u32, .little);
    if (frameSize < FIXED_METADATA_LEN) {
        return error.InvalidMetadata;
    }

    const buffer = try allocator.alloc(u8, frameSize);
    defer allocator.free(buffer);

    try reader.readNoEof(buffer);

    return try parseMetadata(allocator, buffer);
}

pub fn parseMetadata(allocator: std.mem.Allocator, buffer: []u8) !Metadata {
    var metadata = Metadata.init(allocator);
    metadata.symbol_cstr_len = v1.SYMBOL_CSTR_LEN;
    errdefer metadata.deinit();

    var pos: usize = 0;

    if (!std.mem.eql(u8, buffer[pos .. pos + 3], "DBZ")) return error.InvalidDbz;

    const version = buffer[pos + 3];
    if (version != SCHEMA_VERSION) return error.InvalidDbz;
    metadata.version = .v1; // XXX: .v0?

    pos += VERSION_CSTR_LEN;

    // Read dataset
    const dataset_slice = buffer[pos .. pos + METADATA_DATASET_CSTR_LEN];
    const dataset_str = std.mem.sliceTo(dataset_slice, 0);
    metadata.dataset = try allocator.dupe(u8, dataset_str);
    pos += METADATA_DATASET_CSTR_LEN;

    const raw_schema = std.mem.readInt(u16, buffer[pos..][0..2], .little);
    metadata.schema = try std.meta.intToEnum(Schema, raw_schema);
    pos += 2;

    // Read timestamps
    if (pos + 24 > buffer.len) return error.UnexpectedEndOfBuffer; // 3 * u64
    metadata.start = std.mem.readInt(u64, buffer[pos..][0..8], .little);
    pos += 8;

    const end_ts = std.mem.readInt(u64, buffer[pos..][0..8], .little);
    metadata.end = if (end_ts == constants.UNDEF_TIMESTAMP) null else end_ts;
    pos += 8;

    const limit_val = std.mem.readInt(u64, buffer[pos..][0..8], .little);
    metadata.limit = if (limit_val == 0) null else limit_val;
    pos += 8;

    // Skip over the deprecated record count
    pos += 8;

    // Skip over the unused compression
    pos += 1;

    // Read stype_in
    if (pos + 1 > buffer.len) return error.UnexpectedEndOfBuffer;
    metadata.stype_in = try std.meta.intToEnum(SType, buffer[pos]);
    pos += 1;

    // Read stype_out
    if (pos + 1 > buffer.len) return error.UnexpectedEndOfBuffer;
    metadata.stype_out = try std.meta.intToEnum(SType, buffer[pos]);
    pos += 1;

    pos += RESERVED_LEN;

    var compressed: std.ArrayList(u8) = .init(allocator);
    defer compressed.deinit();

    const n = try std.compress.zstd.decompress.decodeZstandardFrameArrayList(
        allocator,
        &compressed,
        buffer[pos..],
        true,
        std.math.maxInt(usize),
    );
    std.debug.assert(n <= (buffer.len - pos) * 3); // 3x is arbitrary

    var zstd_buffer = try compressed.toOwnedSlice();
    defer allocator.free(zstd_buffer);

    pos = 0;

    const schema_definition_length = std.mem.readInt(u32, zstd_buffer[0..4], .little);
    if (schema_definition_length != 0) return error.InvalidDbz;
    pos += 4 + schema_definition_length;

    metadata.symbols = try readRepeatedSymbols(allocator, v1.SYMBOL_CSTR_LEN, zstd_buffer, &pos);
    metadata.partial = try readRepeatedSymbols(allocator, v1.SYMBOL_CSTR_LEN, zstd_buffer, &pos);
    metadata.not_found = try readRepeatedSymbols(allocator, v1.SYMBOL_CSTR_LEN, zstd_buffer, &pos);
    metadata.mappings = try readSymbolMappings(allocator, v1.SYMBOL_CSTR_LEN, zstd_buffer, &pos);

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
