const std = @import("std");
const zstd = std.compress.zstd;

const enums = @import("enums.zig");
const constants = @import("constants.zig");
const record = @import("record.zig");

const SType = enums.SType;
const Schema = enums.Schema;
const Version = enums.Version;
const Record = record.Record;

const v1 = @import("v1.zig");
const v2 = @import("v2.zig");
const v3 = @import("v3.zig");

const DBN_MAGIC = "DBN";
const METADATA_DATASET_CSTR_LEN: usize = 16;
const METADATA_FIXED_LEN: usize = 100;
const NULL_STYPE: u8 = std.math.maxInt(u8);
const NULL_SCHEMA: u16 = std.math.maxInt(u16);

pub const MetadataError = error{
    InvalidHeader,
    IncompatibleVersion,
    InvalidMetadataLength,
    InvalidUtf8,
    InvalidSchema,
    InvalidSType,
    UnexpectedEndOfBuffer,
    InvalidDate,
    SchemaDefinitionsNotSupported,
};

/// Symbol mapping containing a raw symbol and its mapping intervals.
pub const SymbolMapping = struct {
    /// The raw symbol string.
    raw_symbol: []const u8,
    /// Array of mapping intervals for this symbol.
    intervals: []MappingInterval,

    pub fn deinit(self: *SymbolMapping, allocator: std.mem.Allocator) void {
        allocator.free(self.raw_symbol);
        for (self.intervals) |*interval| {
            interval.deinit(allocator);
        }
        allocator.free(self.intervals);
    }
};

/// A mapping interval for a symbol.
pub const MappingInterval = struct {
    /// Start date of the mapping interval as raw u32 date value (YYYYMMDD format).
    /// TODO: Convert to proper timestamp in nanoseconds since UNIX epoch.
    start_ts: u64,
    /// End date of the mapping interval as raw u32 date value (YYYYMMDD format).
    /// TODO: Convert to proper timestamp in nanoseconds since UNIX epoch.
    end_ts: ?u64,
    /// The mapped symbol for this interval.
    symbol: []const u8,

    pub fn deinit(self: *MappingInterval, allocator: std.mem.Allocator) void {
        allocator.free(self.symbol);
    }
};

/// Information about the data contained in a DBN file or stream. DBN requires the
/// Metadata to be included at the start of the encoded data.
pub const Metadata = struct {
    /// The DBN schema version number. Newly-encoded DBN files will use
    /// the latest DBN version.
    version: Version,
    /// The dataset code.
    dataset: []const u8,
    /// The data record schema. Specifies which record types are in the DBN stream.
    /// `null` indicates the DBN stream _may_ contain more than one record type.
    schema: ?Schema,
    /// The UNIX nanosecond timestamp of the query start, or the first record if the
    /// file was split.
    start: u64,
    /// The UNIX nanosecond timestamp of the query end, or the last record if the file
    /// was split.
    end: ?u64,
    /// The optional maximum number of records for the query.
    limit: ?u64,
    /// The input symbology type to map from. `null` indicates a mix, such as in the
    /// case of live data.
    stype_in: ?SType,
    /// The output symbology type to map to.
    stype_out: SType,
    /// `true` if this store contains live data with send timestamps appended to each
    /// record.
    ts_out: bool,
    /// The length in bytes of fixed-length symbol strings, including a null terminator
    /// byte.
    symbol_cstr_len: usize,
    /// The original query input symbols from the request.
    symbols: [][]const u8,
    /// Symbols that did not resolve for _at least one day_ in the query time range.
    partial: [][]const u8,
    /// Symbols that did not resolve for _any_ day in the query time range.
    not_found: [][]const u8,
    /// Symbol mappings containing a raw symbol and its mapping intervals.
    mappings: []SymbolMapping,

    /// Allocator used for dynamic allocations.
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Metadata {
        return .{
            .version = .v3,
            .dataset = &.{},
            .schema = null,
            .start = 0,
            .end = null,
            .limit = null,
            .stype_in = null,
            .stype_out = .raw_symbol,
            .ts_out = false,
            .symbol_cstr_len = v3.SYMBOL_CSTR_LEN,
            .symbols = &.{},
            .partial = &.{},
            .not_found = &.{},
            .mappings = &.{},
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Metadata) void {
        self.allocator.free(self.dataset);

        for (self.symbols) |symbol| {
            self.allocator.free(symbol);
        }
        self.allocator.free(self.symbols);

        for (self.partial) |symbol| {
            self.allocator.free(symbol);
        }
        self.allocator.free(self.partial);

        for (self.not_found) |symbol| {
            self.allocator.free(symbol);
        }
        self.allocator.free(self.not_found);

        for (self.mappings) |*mapping| {
            mapping.deinit(self.allocator);
        }
        self.allocator.free(self.mappings);
    }

    pub fn check(self: *Metadata) !void {
        // Assert metadata contents
        std.debug.assert(self.dataset.len > 0);
        std.debug.assert(self.symbol_cstr_len > 0);
        std.debug.assert(self.start > 0);
        if (self.end) |end_ts| {
            std.debug.assert(end_ts >= self.start);
        }
        if (self.limit) |limit| {
            std.debug.assert(limit > 0);
        }

        // Assert symbols arrays
        for (self.symbols) |symbol| {
            std.debug.assert(symbol.len > 0);
            std.debug.assert(std.unicode.utf8ValidateSlice(symbol));
        }

        for (self.partial) |symbol| {
            std.debug.assert(symbol.len > 0);
            std.debug.assert(std.unicode.utf8ValidateSlice(symbol));
        }

        for (self.not_found) |symbol| {
            std.debug.assert(symbol.len > 0);
            std.debug.assert(std.unicode.utf8ValidateSlice(symbol));
        }

        // Assert symbol mappings
        for (self.mappings) |mapping| {
            std.debug.assert(mapping.raw_symbol.len > 0);
            std.debug.assert(std.unicode.utf8ValidateSlice(mapping.raw_symbol));

            for (mapping.intervals) |interval| {
                std.debug.assert(interval.start_ts > 0);
                if (interval.end_ts) |end| {
                    std.debug.assert(end >= interval.start_ts);
                }
                std.debug.assert(interval.symbol.len > 0);
                std.debug.assert(std.unicode.utf8ValidateSlice(interval.symbol));
            }
        }
    }

    pub fn print(self: *Metadata, writer: anytype) !void {
        try writer.print("Version: {t}\n", .{self.version});
        try writer.print("Dataset: {s}\n", .{self.dataset});
        try writer.print("Schema: {?}\n", .{self.schema});
        try writer.print("Start: {d}\n", .{self.start});
        try writer.print("End: {?}\n", .{self.end});
        try writer.print("Limit: {?}\n", .{self.limit});
        try writer.print("SType In: {?}\n", .{self.stype_in});
        try writer.print("SType Out: {any}\n", .{self.stype_out});
        try writer.print("TS Out: {any}\n", .{self.ts_out});
        try writer.print("Symbol CStr Len: {d}\n", .{self.symbol_cstr_len});

        try writer.print("Symbols: {d}\n", .{self.symbols.len});
        for (self.symbols, 0..) |symbol, i| {
            try writer.print("  [{d}] {s}\n", .{ i, symbol });
        }

        try writer.print("Partial: {d}\n", .{self.partial.len});
        for (self.partial, 0..) |symbol, i| {
            try writer.print("  [{d}] {s}\n", .{ i, symbol });
        }

        try writer.print("Not Found: {d}\n", .{self.not_found.len});
        for (self.not_found, 0..) |symbol, i| {
            try writer.print("  [{d}] {s}\n", .{ i, symbol });
        }

        try writer.print("Mappings: {d}\n", .{self.mappings.len});
        for (self.mappings, 0..) |mapping, i| {
            try writer.print("  [{d}] {s} -> {d} interval(s)\n", .{ i, mapping.raw_symbol, mapping.intervals.len });
            for (mapping.intervals, 0..) |interval, j| {
                if (interval.end_ts) |end| {
                    try writer.print("    [{d}] {d}-{d}: {s}\n", .{ j, interval.start_ts, end, interval.symbol });
                } else {
                    try writer.print("    [{d}] {d}-present: {s}\n", .{ j, interval.start_ts, interval.symbol });
                }
            }
        }
    }

    pub fn readRecord(self: *Metadata, reader: *std.io.Reader) !?Record {
        return record.readRecord(reader, self.version);
    }

    pub fn readRecords(self: *Metadata, allocator: std.mem.Allocator, reader: *std.io.Reader) ![]Record {
        return record.readRecords(allocator, reader, self.version);
    }
};

test "Metadata initialization and deinitialization" {
    const allocator = std.testing.allocator;

    var metadata = Metadata.init(allocator);
    defer metadata.deinit();

    try std.testing.expectEqual(.v3, metadata.version);
    try std.testing.expectEqual(0, metadata.dataset.len);
    try std.testing.expectEqual(null, metadata.schema);
    try std.testing.expectEqual(0, metadata.start);
    try std.testing.expectEqual(null, metadata.end);
    try std.testing.expectEqual(null, metadata.limit);
    try std.testing.expectEqual(null, metadata.stype_in);
    try std.testing.expectEqual(.raw_symbol, metadata.stype_out);
    try std.testing.expectEqual(false, metadata.ts_out);
    try std.testing.expectEqual(v3.SYMBOL_CSTR_LEN, metadata.symbol_cstr_len);
}

test "Metadata write and read roundtrip" {
    const allocator = std.testing.allocator;

    // Create metadata with test data
    var original_metadata = Metadata.init(allocator);
    defer original_metadata.deinit();

    original_metadata.dataset = try allocator.dupe(u8, "TEST");
    original_metadata.schema = .trades;
    original_metadata.start = 1234567890;
    original_metadata.end = 9876543210;
    original_metadata.limit = 1000;
    original_metadata.stype_in = .raw_symbol;
    original_metadata.stype_out = .instrument_id;
    original_metadata.ts_out = true;

    // Add some symbols
    original_metadata.symbols = try allocator.alloc([]const u8, 2);
    original_metadata.symbols[0] = try allocator.dupe(u8, "AAPL");
    original_metadata.symbols[1] = try allocator.dupe(u8, "MSFT");

    // Add partial symbols
    original_metadata.partial = try allocator.alloc([]const u8, 1);
    original_metadata.partial[0] = try allocator.dupe(u8, "GOOGL");

    // Add not found symbols
    original_metadata.not_found = try allocator.alloc([]const u8, 1);
    original_metadata.not_found[0] = try allocator.dupe(u8, "INVALID");

    // Add a mapping
    original_metadata.mappings = try allocator.alloc(SymbolMapping, 1);
    original_metadata.mappings[0].raw_symbol = try allocator.dupe(u8, "ES");
    original_metadata.mappings[0].intervals = try allocator.alloc(MappingInterval, 2);
    original_metadata.mappings[0].intervals[0] = .{
        .start_ts = 20230101,
        .end_ts = 20230630,
        .symbol = try allocator.dupe(u8, "ESH23"),
    };
    original_metadata.mappings[0].intervals[1] = .{
        .start_ts = 20230701,
        .end_ts = null,
        .symbol = try allocator.dupe(u8, "ESU23"),
    };

    // Write to buffer
    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();
    var writer = buffer.writer();
    var adapter = writer.adaptToNewApi();

    try writeMetadata(&adapter.new_interface, &original_metadata);

    // Read back from buffer
    var stream: std.io.Reader = .fixed(buffer.items);
    var read_metadata = try readMetadata(allocator, &stream);
    defer read_metadata.deinit();

    // Verify all fields match
    try std.testing.expectEqual(original_metadata.version, read_metadata.version);
    try std.testing.expectEqualStrings(original_metadata.dataset, read_metadata.dataset);
    try std.testing.expectEqual(original_metadata.schema, read_metadata.schema);
    try std.testing.expectEqual(original_metadata.start, read_metadata.start);
    try std.testing.expectEqual(original_metadata.end, read_metadata.end);
    try std.testing.expectEqual(original_metadata.limit, read_metadata.limit);
    try std.testing.expectEqual(original_metadata.stype_in, read_metadata.stype_in);
    try std.testing.expectEqual(original_metadata.stype_out, read_metadata.stype_out);
    try std.testing.expectEqual(original_metadata.ts_out, read_metadata.ts_out);
    try std.testing.expectEqual(original_metadata.symbol_cstr_len, read_metadata.symbol_cstr_len);

    // Verify symbols
    try std.testing.expectEqual(original_metadata.symbols.len, read_metadata.symbols.len);
    for (original_metadata.symbols, read_metadata.symbols) |orig, read| {
        try std.testing.expectEqualStrings(orig, read);
    }

    // Verify partial
    try std.testing.expectEqual(original_metadata.partial.len, read_metadata.partial.len);
    for (original_metadata.partial, read_metadata.partial) |orig, read| {
        try std.testing.expectEqualStrings(orig, read);
    }

    // Verify not_found
    try std.testing.expectEqual(original_metadata.not_found.len, read_metadata.not_found.len);
    for (original_metadata.not_found, read_metadata.not_found) |orig, read| {
        try std.testing.expectEqualStrings(orig, read);
    }

    // Verify mappings
    try std.testing.expectEqual(original_metadata.mappings.len, read_metadata.mappings.len);
    for (original_metadata.mappings, read_metadata.mappings) |orig_map, read_map| {
        try std.testing.expectEqualStrings(orig_map.raw_symbol, read_map.raw_symbol);
        try std.testing.expectEqual(orig_map.intervals.len, read_map.intervals.len);

        for (orig_map.intervals, read_map.intervals) |orig_int, read_int| {
            try std.testing.expectEqual(orig_int.start_ts, read_int.start_ts);
            try std.testing.expectEqual(orig_int.end_ts, read_int.end_ts);
            try std.testing.expectEqualStrings(orig_int.symbol, read_int.symbol);
        }
    }
}

/// Reads DBN metadata from a reader, including the DBN header and version check.
pub fn readMetadata(allocator: std.mem.Allocator, reader: *std.io.Reader) !Metadata {
    // Read and validate DBN header (3 bytes)
    var header: [3]u8 = undefined;
    try reader.readSliceAll(&header);
    if (!std.mem.eql(u8, &header, DBN_MAGIC)) {
        return MetadataError.InvalidHeader;
    }

    // Read version
    const version_byte = try reader.takeByte();
    const version: Version = @enumFromInt(version_byte);

    // Read metadata length
    const length = try reader.takeInt(u32, .little);
    if (length < METADATA_FIXED_LEN) {
        return MetadataError.InvalidMetadataLength;
    }

    // Read the rest of metadata into buffer
    const buffer = try allocator.alloc(u8, length);
    defer allocator.free(buffer);
    try reader.readSliceAll(buffer);

    // Parse metadata from buffer
    return try parseMetadata(allocator, version, buffer);
}

/// Parses metadata from a buffer.
fn parseMetadata(allocator: std.mem.Allocator, version: Version, buffer: []const u8) !Metadata {
    var pos: usize = 0;
    var metadata = Metadata.init(allocator);
    errdefer metadata.deinit();

    metadata.version = version;

    // Read dataset
    if (pos + METADATA_DATASET_CSTR_LEN > buffer.len) return MetadataError.UnexpectedEndOfBuffer;
    const dataset_slice = buffer[pos .. pos + METADATA_DATASET_CSTR_LEN];
    const dataset_str = std.mem.sliceTo(dataset_slice, 0);
    metadata.dataset = try allocator.dupe(u8, dataset_str);
    pos += METADATA_DATASET_CSTR_LEN;

    // Read schema
    if (pos + 2 > buffer.len) return MetadataError.UnexpectedEndOfBuffer;
    const raw_schema = std.mem.readInt(u16, buffer[pos..][0..2], .little);
    if (raw_schema == NULL_SCHEMA) {
        metadata.schema = null;
    } else {
        metadata.schema = try std.meta.intToEnum(Schema, raw_schema);
    }
    pos += 2;

    // Read timestamps
    if (pos + 24 > buffer.len) return MetadataError.UnexpectedEndOfBuffer; // 3 * u64
    metadata.start = std.mem.readInt(u64, buffer[pos..][0..8], .little);
    pos += 8;

    const end_ts = std.mem.readInt(u64, buffer[pos..][0..8], .little);
    metadata.end = if (end_ts == constants.UNDEF_TIMESTAMP) null else end_ts;
    pos += 8;

    const limit_val = std.mem.readInt(u64, buffer[pos..][0..8], .little);
    metadata.limit = if (limit_val == 0) null else limit_val;
    pos += 8;

    // Skip deprecated record_count for version 1
    if (version == .v1) {
        if (pos + 8 > buffer.len) return MetadataError.UnexpectedEndOfBuffer;
        pos += 8;
    }

    // Read stype_in
    if (pos + 1 > buffer.len) return MetadataError.UnexpectedEndOfBuffer;
    if (buffer[pos] == NULL_STYPE) {
        metadata.stype_in = null;
    } else {
        metadata.stype_in = try std.meta.intToEnum(SType, buffer[pos]);
    }
    pos += 1;

    // Read stype_out
    if (pos + 1 > buffer.len) return MetadataError.UnexpectedEndOfBuffer;
    metadata.stype_out = try std.meta.intToEnum(SType, buffer[pos]);
    pos += 1;

    // Read ts_out
    if (pos + 1 > buffer.len) return MetadataError.UnexpectedEndOfBuffer;
    metadata.ts_out = buffer[pos] != 0;
    pos += 1;

    // Read symbol_cstr_len
    if (version == .v1) {
        metadata.symbol_cstr_len = v1.SYMBOL_CSTR_LEN;
    } else {
        if (pos + 2 > buffer.len) return MetadataError.UnexpectedEndOfBuffer;
        metadata.symbol_cstr_len = std.mem.readInt(u16, buffer[pos..][0..2], .little);
        pos += 2;
    }

    // Skip reserved bytes
    const reserved_len = switch (version) {
        .v1 => v1.METADATA_RESERVED_LEN,
        .v2 => v2.METADATA_RESERVED_LEN,
        .v3 => v3.METADATA_RESERVED_LEN,
    };
    if (pos + reserved_len > buffer.len) return MetadataError.UnexpectedEndOfBuffer;
    pos += reserved_len;

    // Read schema definition length
    if (pos + 4 > buffer.len) return MetadataError.UnexpectedEndOfBuffer;
    const schema_def_length = std.mem.readInt(u32, buffer[pos..][0..4], .little);
    pos += 4 + schema_def_length;

    if (schema_def_length != 0) return MetadataError.SchemaDefinitionsNotSupported;

    // Read symbols
    metadata.symbols = try readRepeatedSymbols(allocator, metadata.symbol_cstr_len, buffer, &pos);
    metadata.partial = try readRepeatedSymbols(allocator, metadata.symbol_cstr_len, buffer, &pos);
    metadata.not_found = try readRepeatedSymbols(allocator, metadata.symbol_cstr_len, buffer, &pos);
    metadata.mappings = try readSymbolMappings(allocator, metadata.symbol_cstr_len, buffer, &pos);

    return metadata;
}

/// Reads a repeated list of null-terminated symbol strings.
pub fn readRepeatedSymbols(allocator: std.mem.Allocator, symbol_cstr_len: usize, buffer: []const u8, pos: *usize) ![][]const u8 {
    if (pos.* + 4 > buffer.len) return MetadataError.UnexpectedEndOfBuffer;

    const count = std.mem.readInt(u32, buffer[pos.*..][0..4], .little);
    pos.* += 4;

    const symbols = try allocator.alloc([]const u8, count);
    errdefer allocator.free(symbols);

    for (symbols, 0..) |*symbol, i| {
        symbol.* = readSymbol(allocator, symbol_cstr_len, buffer, pos) catch |err| {
            // Clean up already allocated symbols
            for (symbols[0..i]) |sym| {
                allocator.free(sym);
            }
            return err;
        };
    }

    return symbols;
}

/// Reads a single null-terminated symbol string.
fn readSymbol(allocator: std.mem.Allocator, symbol_cstr_len: usize, buffer: []const u8, pos: *usize) ![]const u8 {
    if (pos.* + symbol_cstr_len > buffer.len) return MetadataError.UnexpectedEndOfBuffer;

    const symbol_slice = buffer[pos.* .. pos.* + symbol_cstr_len];
    const symbol_str = std.mem.sliceTo(symbol_slice, 0);

    if (!std.unicode.utf8ValidateSlice(symbol_str)) {
        return MetadataError.InvalidUtf8;
    }

    pos.* += symbol_cstr_len;
    return try allocator.dupe(u8, symbol_str);
}

/// Reads symbol mappings from buffer.
pub fn readSymbolMappings(allocator: std.mem.Allocator, symbol_cstr_len: usize, buffer: []const u8, pos: *usize) ![]SymbolMapping {
    if (pos.* + 4 > buffer.len) {
        return MetadataError.UnexpectedEndOfBuffer;
    }

    const count = std.mem.readInt(u32, buffer[pos.*..][0..4], .little);
    pos.* += 4;

    const mappings = try allocator.alloc(SymbolMapping, count);
    errdefer allocator.free(mappings);

    for (mappings) |*mapping| {
        mapping.* = try readSymbolMapping(allocator, symbol_cstr_len, buffer, pos);
    }

    return mappings;
}

/// Reads a single symbol mapping.
fn readSymbolMapping(allocator: std.mem.Allocator, symbol_cstr_len: usize, buffer: []const u8, pos: *usize) !SymbolMapping {
    var mapping: SymbolMapping = undefined;

    // Check minimum size needed for symbol mapping (raw_symbol + interval_count)
    const min_symbol_mapping_encoded_len = symbol_cstr_len + @sizeOf(u32);
    if (pos.* + min_symbol_mapping_encoded_len > buffer.len) {
        return MetadataError.UnexpectedEndOfBuffer;
    }

    // Read raw symbol
    mapping.raw_symbol = try readSymbol(allocator, symbol_cstr_len, buffer, pos);
    errdefer allocator.free(mapping.raw_symbol);

    // Read interval count
    if (pos.* + 4 > buffer.len) {
        return MetadataError.UnexpectedEndOfBuffer;
    }
    const interval_count = std.mem.readInt(u32, buffer[pos.*..][0..4], .little);
    pos.* += 4;

    // Validate buffer has enough space for all intervals
    const mapping_interval_encoded_len = @sizeOf(u32) * 2 + symbol_cstr_len; // start_date + end_date + symbol
    const read_size = interval_count * mapping_interval_encoded_len;
    if (pos.* + read_size > buffer.len) {
        return MetadataError.UnexpectedEndOfBuffer;
    }

    // Read intervals
    mapping.intervals = try allocator.alloc(MappingInterval, interval_count);
    errdefer allocator.free(mapping.intervals);

    for (mapping.intervals) |*interval| {
        // Read start timestamp (stored as u32 date in DBN format)
        if (pos.* + 4 > buffer.len) {
            return MetadataError.UnexpectedEndOfBuffer;
        }
        const start_date = std.mem.readInt(u32, buffer[pos.*..][0..4], .little);
        // For now, store the raw u32 date value as u64
        // TODO: Implement proper date to timestamp conversion
        interval.start_ts = start_date;
        pos.* += 4;

        // Read end timestamp
        if (pos.* + 4 > buffer.len) {
            return MetadataError.UnexpectedEndOfBuffer;
        }
        const end_date = std.mem.readInt(u32, buffer[pos.*..][0..4], .little);
        // For now, store the raw u32 date value as u64
        // 0 represents null/undefined end date
        interval.end_ts = if (end_date == 0) null else end_date;
        pos.* += 4;

        // Read symbol
        interval.symbol = try readSymbol(allocator, symbol_cstr_len, buffer, pos);
    }

    return mapping;
}

pub fn writeMetadata(writer: *std.io.Writer, metadata: *const Metadata) !void {
    // Calculate total metadata size
    const metadata_size = try calculateMetadataSize(metadata);

    // Write header
    try writer.writeAll(DBN_MAGIC);
    try writer.writeByte(@intFromEnum(metadata.version));
    try writer.writeInt(u32, @intCast(metadata_size), .little);

    // Write dataset (16 bytes, null-terminated)
    var dataset_buf: [METADATA_DATASET_CSTR_LEN]u8 = @splat(0);
    const n = @min(metadata.dataset.len, METADATA_DATASET_CSTR_LEN - 1);
    @memcpy(dataset_buf[0..n], metadata.dataset[0..n]);
    try writer.writeAll(&dataset_buf);

    // Write schema
    const schema_val: u16 = if (metadata.schema) |s| @intFromEnum(s) else NULL_SCHEMA;
    try writer.writeInt(u16, schema_val, .little);

    // Write timestamps
    try writer.writeInt(u64, metadata.start, .little);
    try writer.writeInt(u64, metadata.end orelse constants.UNDEF_TIMESTAMP, .little);
    try writer.writeInt(u64, metadata.limit orelse 0, .little);

    // Write deprecated record count
    if (metadata.version == .v1) {
        try writer.writeInt(u64, 0, .little);
    }

    // Write stype_in
    const stype_in_val: u8 = if (metadata.stype_in) |s| @intFromEnum(s) else NULL_STYPE;
    try writer.writeByte(stype_in_val);

    // Write stype_out
    try writer.writeByte(@intFromEnum(metadata.stype_out));

    // Write ts_out
    try writer.writeByte(if (metadata.ts_out) 1 else 0);

    // Write symbol_cstr_len (not for v1)
    if (metadata.version != .v1) {
        try writer.writeInt(u16, @intCast(metadata.symbol_cstr_len), .little);
    }

    // Write reserved bytes
    const reserved_len = switch (metadata.version) {
        .v1 => v1.METADATA_RESERVED_LEN,
        .v2 => v2.METADATA_RESERVED_LEN,
        .v3 => v3.METADATA_RESERVED_LEN,
    };
    var reserved_bytes: [v3.METADATA_RESERVED_LEN]u8 = @splat(0);
    try writer.writeAll(reserved_bytes[0..reserved_len]);

    // Write schema definition length (always 0 for now)
    try writer.writeInt(u32, 0, .little);

    // Write symbols
    try writeRepeatedSymbols(writer, metadata.symbols, metadata.symbol_cstr_len);
    try writeRepeatedSymbols(writer, metadata.partial, metadata.symbol_cstr_len);
    try writeRepeatedSymbols(writer, metadata.not_found, metadata.symbol_cstr_len);
    try writeSymbolMappings(writer, metadata.mappings, metadata.symbol_cstr_len);

    try writer.flush();
}

/// Calculates the total size of metadata in bytes.
fn calculateMetadataSize(metadata: *const Metadata) !usize {
    var size: usize = METADATA_FIXED_LEN;

    size += 4; // schema definition length

    // Add size for repeated symbols
    size += 4 + metadata.symbols.len * metadata.symbol_cstr_len;
    size += 4 + metadata.partial.len * metadata.symbol_cstr_len;
    size += 4 + metadata.not_found.len * metadata.symbol_cstr_len;

    // Add size for mappings
    size += 4; // mapping count
    for (metadata.mappings) |mapping| {
        size += metadata.symbol_cstr_len; // raw_symbol
        size += 4; // interval count
        size += mapping.intervals.len * (8 + metadata.symbol_cstr_len); // each interval: start(4) + end(4) + symbol
    }

    return size;
}

/// Writes a repeated list of null-terminated symbol strings.
fn writeRepeatedSymbols(writer: *std.io.Writer, symbols: []const []const u8, symbol_cstr_len: usize) !void {
    try writer.writeInt(u32, @intCast(symbols.len), .little);

    for (symbols) |symbol| {
        try writeSymbol(writer, symbol, symbol_cstr_len);
    }
}

/// Writes a single null-terminated symbol string.
fn writeSymbol(writer: *std.io.Writer, symbol: []const u8, symbol_cstr_len: usize) !void {
    // Use a buffer large enough for any reasonable symbol length
    var symbol_buf: [256]u8 = @splat(0);
    std.debug.assert(symbol_cstr_len <= 256);
    const n = @min(symbol.len, symbol_cstr_len - 1);
    @memcpy(symbol_buf[0..n], symbol[0..n]);
    try writer.writeAll(symbol_buf[0..symbol_cstr_len]);
}

/// Writes symbol mappings.
fn writeSymbolMappings(writer: *std.io.Writer, mappings: []const SymbolMapping, symbol_cstr_len: usize) !void {
    try writer.writeInt(u32, @intCast(mappings.len), .little);

    for (mappings) |mapping| {
        try writeSymbolMapping(writer, &mapping, symbol_cstr_len);
    }
}

/// Writes a single symbol mapping.
fn writeSymbolMapping(writer: *std.io.Writer, mapping: *const SymbolMapping, symbol_cstr_len: usize) !void {
    // Write raw symbol
    try writeSymbol(writer, mapping.raw_symbol, symbol_cstr_len);

    // Write interval count
    try writer.writeInt(u32, @intCast(mapping.intervals.len), .little);

    // Write intervals
    for (mapping.intervals) |interval| {
        // Write start timestamp (as u32 date for now)
        try writer.writeInt(u32, @intCast(interval.start_ts), .little);

        // Write end timestamp
        const end_date: u32 = if (interval.end_ts) |end| @intCast(end) else 0;
        try writer.writeInt(u32, end_date, .little);

        // Write symbol
        try writeSymbol(writer, interval.symbol, symbol_cstr_len);
    }
}
