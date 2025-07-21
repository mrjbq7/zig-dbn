const std = @import("std");
const testing = std.testing;
const metadata = @import("metadata.zig");
const record = @import("record.zig");

test "test_data.bbo-1m.dbn" {
    const allocator = testing.allocator;

    // Open the test data file
    const file = try std.fs.cwd().openFile("test_data/test_data.bbo-1m.dbn", .{});
    defer file.close();
    const reader = file.deprecatedReader();

    // Read metadata
    var meta = try metadata.readMetadata(allocator, reader);
    defer meta.deinit();

    // Assert metadata contents
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.bbo_1m, meta.schema);
    try testing.expectEqual(1609113600000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(4, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Assert empty arrays
    try testing.expectEqual(0, meta.partial.len);
    try testing.expectEqual(0, meta.not_found.len);

    // Assert mappings
    try testing.expectEqual(1, meta.mappings.len);
    try testing.expectEqualStrings("ESH1", meta.mappings[0].raw_symbol);
    try testing.expectEqual(1, meta.mappings[0].intervals.len);
    try testing.expectEqual(20201228, meta.mappings[0].intervals[0].start_ts);
    try testing.expectEqual(20201229, meta.mappings[0].intervals[0].end_ts);
    try testing.expectEqualStrings("5482", meta.mappings[0].intervals[0].symbol);

    // Read first BBO record
    const record1 = try meta.readRecord(reader);
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .bbo);

    // Check first BBO record
    const bbo1 = record1.?.v2.bbo;
    try testing.expectEqual(1609113600000000000, bbo1.ts_recv);
    try testing.expectEqual(1609113599045849637, bbo1.hd.ts_event);
    try testing.expectEqual(.bbo_1m, bbo1.hd.rtype);
    try testing.expectEqual(1, bbo1.hd.publisher_id);
    try testing.expectEqual(5482, bbo1.hd.instrument_id);
    try testing.expectEqual(.ask, bbo1.side);
    try testing.expectEqual(3702500000000, bbo1.price);
    try testing.expectEqual(2, bbo1.size);
    try testing.expectEqual(168, bbo1.flags.raw);
    try testing.expectEqual(145799, bbo1.sequence);
    try testing.expectEqual(3702250000000, bbo1.levels[0].bid_px);
    try testing.expectEqual(3702750000000, bbo1.levels[0].ask_px);
    try testing.expectEqual(18, bbo1.levels[0].bid_sz);
    try testing.expectEqual(13, bbo1.levels[0].ask_sz);
    try testing.expectEqual(10, bbo1.levels[0].bid_ct);
    try testing.expectEqual(13, bbo1.levels[0].ask_ct);
}

test "test_data.bbo-1m.v2.dbn.zst" {
    const allocator = testing.allocator;

    // Open the compressed test data file
    const file = try std.fs.cwd().openFile("test_data/test_data.bbo-1m.v2.dbn.zst", .{});
    defer file.close();

    // Create a decompressor with window buffer
    var window_buffer: [std.compress.zstd.DecompressorOptions.default_window_buffer_len]u8 = undefined;
    var decompressor = std.compress.zstd.decompressor(file.deprecatedReader(), .{ .window_buffer = &window_buffer });
    const reader = decompressor.reader();

    // Read metadata
    var meta = try metadata.readMetadata(allocator, reader);
    defer meta.deinit();

    // Assert metadata contents for v2
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.bbo_1m, meta.schema);
    try testing.expectEqual(1609113600000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(4, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first BBO record
    const record1 = try meta.readRecord(reader);
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .bbo);

    // Check first BBO record
    const bbo1 = record1.?.v2.bbo;
    try testing.expectEqual(1609113600000000000, bbo1.ts_recv);
    try testing.expectEqual(1609113599045849637, bbo1.hd.ts_event);
    try testing.expectEqual(.bbo_1m, bbo1.hd.rtype);
    try testing.expectEqual(1, bbo1.hd.publisher_id);
    try testing.expectEqual(5482, bbo1.hd.instrument_id);
}

test "test_data.bbo-1m.v3.dbn.zst" {
    const allocator = testing.allocator;

    // Open the compressed test data file
    const file = try std.fs.cwd().openFile("test_data/test_data.bbo-1m.v3.dbn.zst", .{});
    defer file.close();

    // Create a decompressor with window buffer
    var window_buffer: [std.compress.zstd.DecompressorOptions.default_window_buffer_len]u8 = undefined;
    var decompressor = std.compress.zstd.decompressor(file.deprecatedReader(), .{ .window_buffer = &window_buffer });
    const reader = decompressor.reader();

    // Read metadata
    var meta = try metadata.readMetadata(allocator, reader);
    defer meta.deinit();

    // Assert metadata contents for v3
    try testing.expectEqual(.v3, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.bbo_1m, meta.schema);
    try testing.expectEqual(1609113600000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(4, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first BBO record
    const record1 = try meta.readRecord(reader);
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v3 == .bbo);

    // Check first BBO record
    const bbo1 = record1.?.v3.bbo;
    try testing.expectEqual(1609113600000000000, bbo1.ts_recv);
    try testing.expectEqual(1609113599045849637, bbo1.hd.ts_event);
    try testing.expectEqual(.bbo_1m, bbo1.hd.rtype);
    try testing.expectEqual(1, bbo1.hd.publisher_id);
    try testing.expectEqual(5482, bbo1.hd.instrument_id);
}

test "test_data.bbo-1s.dbn" {
    const allocator = testing.allocator;

    // Open the test data file
    const file = try std.fs.cwd().openFile("test_data/test_data.bbo-1s.dbn", .{});
    defer file.close();
    const reader = file.deprecatedReader();

    // Read metadata
    var meta = try metadata.readMetadata(allocator, reader);
    defer meta.deinit();

    // Assert metadata contents
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.bbo_1s, meta.schema);
    try testing.expectEqual(1609113600000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(4, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first BBO record
    const record1 = try meta.readRecord(reader);
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .bbo);

    // Check first BBO record
    const bbo1 = record1.?.v2.bbo;
    try testing.expectEqual(1609113600000000000, bbo1.ts_recv);
    try testing.expectEqual(1609113599045849637, bbo1.hd.ts_event);
    try testing.expectEqual(.bbo_1s, bbo1.hd.rtype);
    try testing.expectEqual(1, bbo1.hd.publisher_id);
    try testing.expectEqual(5482, bbo1.hd.instrument_id);
}

test "test_data.bbo-1s.v2.dbn.zst" {
    const allocator = testing.allocator;

    // Open the compressed test data file
    const file = try std.fs.cwd().openFile("test_data/test_data.bbo-1s.v2.dbn.zst", .{});
    defer file.close();

    // Create a decompressor with window buffer
    var window_buffer: [std.compress.zstd.DecompressorOptions.default_window_buffer_len]u8 = undefined;
    var decompressor = std.compress.zstd.decompressor(file.deprecatedReader(), .{ .window_buffer = &window_buffer });
    const reader = decompressor.reader();

    // Read metadata
    var meta = try metadata.readMetadata(allocator, reader);
    defer meta.deinit();

    // Assert metadata contents for v2
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.bbo_1s, meta.schema);
    try testing.expectEqual(1609113600000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(4, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first BBO record
    const record1 = try meta.readRecord(reader);
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .bbo);

    // Check first BBO record
    const bbo1 = record1.?.v2.bbo;
    try testing.expectEqual(1609113600000000000, bbo1.ts_recv);
    try testing.expectEqual(1609113599045849637, bbo1.hd.ts_event);
    try testing.expectEqual(.bbo_1s, bbo1.hd.rtype);
    try testing.expectEqual(1, bbo1.hd.publisher_id);
    try testing.expectEqual(5482, bbo1.hd.instrument_id);
}

test "test_data.bbo-1s.v3.dbn.zst" {
    const allocator = testing.allocator;

    // Open the compressed test data file
    const file = try std.fs.cwd().openFile("test_data/test_data.bbo-1s.v3.dbn.zst", .{});
    defer file.close();

    // Create a decompressor with window buffer
    var window_buffer: [std.compress.zstd.DecompressorOptions.default_window_buffer_len]u8 = undefined;
    var decompressor = std.compress.zstd.decompressor(file.deprecatedReader(), .{ .window_buffer = &window_buffer });
    const reader = decompressor.reader();

    // Read metadata
    var meta = try metadata.readMetadata(allocator, reader);
    defer meta.deinit();

    // Assert metadata contents for v3
    try testing.expectEqual(.v3, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.bbo_1s, meta.schema);
    try testing.expectEqual(1609113600000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(4, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first BBO record
    const record1 = try meta.readRecord(reader);
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v3 == .bbo);

    // Check first BBO record
    const bbo1 = record1.?.v3.bbo;
    try testing.expectEqual(1609113600000000000, bbo1.ts_recv);
    try testing.expectEqual(1609113599045849637, bbo1.hd.ts_event);
    try testing.expectEqual(.bbo_1s, bbo1.hd.rtype);
    try testing.expectEqual(1, bbo1.hd.publisher_id);
    try testing.expectEqual(5482, bbo1.hd.instrument_id);
}
