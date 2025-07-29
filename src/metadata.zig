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
