const std = @import("std");
const testing = std.testing;
const metadata = @import("metadata.zig");
const record = @import("record.zig");

test "test_data.status.dbn" {
    const allocator = testing.allocator;

    // Open the test data file
    const file = try std.fs.cwd().openFile("test_data/test_data.status.dbn", .{});
    defer file.close();
    const reader = file.deprecatedReader();

    // Read metadata
    var meta = try metadata.readMetadata(allocator, reader);
    defer meta.deinit();

    // Assert metadata contents
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.status, meta.schema);
    try testing.expectEqual(1609113600000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(4, meta.limit);

    // Read first status record
    const record1 = try meta.readRecord(reader);
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .status);

    // Check first status record
    const status1 = record1.?.v2.status;
    try testing.expectEqual(1609113600000000000, status1.ts_recv);
    try testing.expectEqual(1609110000000000000, status1.hd.ts_event);
    try testing.expectEqual(.status, status1.hd.rtype);
    try testing.expectEqual(1, status1.hd.publisher_id);
    try testing.expectEqual(5482, status1.hd.instrument_id);
    try testing.expectEqual(7, status1.action);
    try testing.expectEqual(1, status1.reason);
    try testing.expectEqual(0, status1.trading_event);
    try testing.expectEqual('Y', status1.is_trading);
    try testing.expectEqual('Y', status1.is_quoting);
    try testing.expectEqual('~', status1.is_short_sell_restricted);
}

test "test_data.status.v2.dbn.zst" {
    const allocator = testing.allocator;

    // Open the compressed test data file
    const file = try std.fs.cwd().openFile("test_data/test_data.status.v2.dbn.zst", .{});
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
    try testing.expectEqual(.status, meta.schema);
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

    // Read first status record
    const record1 = try meta.readRecord(reader);
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .status);

    // Check first status record
    const status1 = record1.?.v2.status;
    try testing.expectEqual(1609113600000000000, status1.ts_recv);
    try testing.expectEqual(1609110000000000000, status1.hd.ts_event);
    try testing.expectEqual(.status, status1.hd.rtype);
    try testing.expectEqual(1, status1.hd.publisher_id);
    try testing.expectEqual(5482, status1.hd.instrument_id);
    try testing.expectEqual(7, status1.action);
    try testing.expectEqual(1, status1.reason);
    try testing.expectEqual(0, status1.trading_event);
    try testing.expectEqual('Y', status1.is_trading);
    try testing.expectEqual('Y', status1.is_quoting);
    try testing.expectEqual('~', status1.is_short_sell_restricted);
}

test "test_data.status.v3.dbn.zst" {
    const allocator = testing.allocator;

    // Open the compressed test data file
    const file = try std.fs.cwd().openFile("test_data/test_data.status.v3.dbn.zst", .{});
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
    try testing.expectEqual(.status, meta.schema);
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

    // Read first status record
    const record1 = try meta.readRecord(reader);
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v3 == .status);

    // Check first status record
    const status1 = record1.?.v3.status;
    try testing.expectEqual(1609113600000000000, status1.ts_recv);
    try testing.expectEqual(1609110000000000000, status1.hd.ts_event);
    try testing.expectEqual(.status, status1.hd.rtype);
    try testing.expectEqual(1, status1.hd.publisher_id);
    try testing.expectEqual(5482, status1.hd.instrument_id);
}
