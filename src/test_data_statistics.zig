const std = @import("std");
const testing = std.testing;
const metadata = @import("metadata.zig");
const record = @import("record.zig");

test "test_data.statistics.dbn" {
    const allocator = testing.allocator;

    // Open the test data file
    const file = try std.fs.cwd().openFile("test_data/test_data.statistics.dbn", .{});
    defer file.close();
    const reader = file.deprecatedReader();

    // Read metadata
    var meta = try metadata.readMetadata(allocator, reader);
    defer meta.deinit();

    // Assert metadata contents
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.statistics, meta.schema);
    try testing.expectEqual(2814749767106560, meta.start);
    try testing.expectEqual(null, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.instrument_id, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert empty arrays
    try testing.expectEqual(0, meta.symbols.len);
    try testing.expectEqual(0, meta.partial.len);
    try testing.expectEqual(0, meta.not_found.len);
    try testing.expectEqual(0, meta.mappings.len);

    if (true) return error.SkipZigTest; // XXX: FIX THIS TEST

    // Read first statistics record
    const record1 = try meta.readRecord(reader);
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .statistics);

    // Check first statistics record
    const stat1 = record1.?.v2.statistics;
    try testing.expectEqual(1682269536040124325, stat1.ts_recv);
    try testing.expectEqual(1682269536030443135, stat1.hd.ts_event);
    try testing.expectEqual(.statistics, stat1.hd.rtype);
    try testing.expectEqual(1, stat1.hd.publisher_id);
    try testing.expectEqual(146945, stat1.hd.instrument_id);
    try testing.expectEqual(18446744073709551615, stat1.ts_ref);
    try testing.expectEqual(100000000000, stat1.price);
    try testing.expectEqual(2147483647, stat1.quantity);
    try testing.expectEqual(2, stat1.sequence);
    try testing.expectEqual(26961, stat1.ts_in_delta);
    try testing.expectEqual(7, stat1.stat_type);
    try testing.expectEqual(13, stat1.channel_id);
    try testing.expectEqual(1, stat1.update_action);
    try testing.expectEqual(255, stat1.stat_flags);

    // Read second statistics record
    const record2 = try meta.readRecord(reader);
    try testing.expect(record2 != null);
    try testing.expect(record2.?.v2 == .statistics);

    // Check second statistics record
    const stat2 = record2.?.v2.statistics;
    try testing.expectEqual(1682269536121890092, stat2.ts_recv);
    try testing.expectEqual(1682269536071497081, stat2.hd.ts_event);
    try testing.expectEqual(.statistics, stat2.hd.rtype);
    try testing.expectEqual(1, stat2.hd.publisher_id);
    try testing.expectEqual(146945, stat2.hd.instrument_id);
    try testing.expectEqual(18446744073709551615, stat2.ts_ref);
    try testing.expectEqual(100000000000, stat2.price);
    try testing.expectEqual(2147483647, stat2.quantity);
    try testing.expectEqual(7, stat2.sequence);
    try testing.expectEqual(28456, stat2.ts_in_delta);
    try testing.expectEqual(5, stat2.stat_type);
    try testing.expectEqual(13, stat2.channel_id);
    try testing.expectEqual(1, stat2.update_action);
    try testing.expectEqual(255, stat2.stat_flags);

    // Verify no more records
    const record3 = try meta.readRecord(reader);
    try testing.expect(record3 == null);
}

test "test_data.statistics.v1.dbn.zst" {
    const allocator = testing.allocator;

    // Open the compressed test data file
    const file = try std.fs.cwd().openFile("test_data/test_data.statistics.v1.dbn.zst", .{});
    defer file.close();

    // Create a decompressor with window buffer
    var window_buffer: [std.compress.zstd.DecompressorOptions.default_window_buffer_len]u8 = undefined;
    var decompressor = std.compress.zstd.decompressor(file.deprecatedReader(), .{ .window_buffer = &window_buffer });
    const reader = decompressor.reader();

    // Read metadata
    var meta = try metadata.readMetadata(allocator, reader);
    defer meta.deinit();

    // Assert metadata contents for v1
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.statistics, meta.schema);
    try testing.expectEqual(2814749767106560, meta.start);
    try testing.expectEqual(null, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.instrument_id, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(22, meta.symbol_cstr_len);

    // Assert empty arrays
    try testing.expectEqual(0, meta.symbols.len);
    try testing.expectEqual(0, meta.partial.len);
    try testing.expectEqual(0, meta.not_found.len);
    try testing.expectEqual(0, meta.mappings.len);

    // Read first statistics record
    const record1 = try meta.readRecord(reader);
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v1 == .statistics);

    // Check first statistics record
    const stat1 = record1.?.v1.statistics;
    try testing.expectEqual(1682269536040124325, stat1.ts_recv);
    try testing.expectEqual(1682269536030443135, stat1.hd.ts_event);
    try testing.expectEqual(.statistics, stat1.hd.rtype);
    try testing.expectEqual(1, stat1.hd.publisher_id);
    try testing.expectEqual(146945, stat1.hd.instrument_id);
    try testing.expectEqual(18446744073709551615, stat1.ts_ref);
    try testing.expectEqual(100000000000, stat1.price);
    try testing.expectEqual(2147483647, stat1.quantity);
    try testing.expectEqual(2, stat1.sequence);
    try testing.expectEqual(26961, stat1.ts_in_delta);
    try testing.expectEqual(7, stat1.stat_type);
    try testing.expectEqual(13, stat1.channel_id);
    try testing.expectEqual(1, stat1.update_action);
    try testing.expectEqual(255, stat1.stat_flags);

    // Read second statistics record
    const record2 = try meta.readRecord(reader);
    try testing.expect(record2 != null);
    try testing.expect(record2.?.v1 == .statistics);

    // Check second statistics record
    const stat2 = record2.?.v1.statistics;
    try testing.expectEqual(1682269536121890092, stat2.ts_recv);
    try testing.expectEqual(1682269536071497081, stat2.hd.ts_event);
    try testing.expectEqual(.statistics, stat2.hd.rtype);
    try testing.expectEqual(1, stat2.hd.publisher_id);
    try testing.expectEqual(146945, stat2.hd.instrument_id);
    try testing.expectEqual(18446744073709551615, stat2.ts_ref);
    try testing.expectEqual(100000000000, stat2.price);
    try testing.expectEqual(2147483647, stat2.quantity);
    try testing.expectEqual(7, stat2.sequence);
    try testing.expectEqual(28456, stat2.ts_in_delta);
    try testing.expectEqual(5, stat2.stat_type);
    try testing.expectEqual(13, stat2.channel_id);
    try testing.expectEqual(1, stat2.update_action);
    try testing.expectEqual(255, stat2.stat_flags);

    // Verify no more records
    const record3 = try meta.readRecord(reader);
    try testing.expect(record3 == null);
}

test "test_data.statistics.v2.dbn.zst" {
    const allocator = testing.allocator;

    // Open the compressed test data file
    const file = try std.fs.cwd().openFile("test_data/test_data.statistics.v2.dbn.zst", .{});
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
    try testing.expectEqual(.statistics, meta.schema);
    try testing.expectEqual(2814749767106560, meta.start);
    try testing.expectEqual(null, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.instrument_id, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert empty arrays
    try testing.expectEqual(0, meta.symbols.len);
    try testing.expectEqual(0, meta.partial.len);
    try testing.expectEqual(0, meta.not_found.len);
    try testing.expectEqual(0, meta.mappings.len);

    if (true) return error.SkipZigTest; // XXX: FIX THIS TEST

    // Read first statistics record
    const record1 = try meta.readRecord(reader);
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .statistics);

    // Check first statistics record
    const stat1 = record1.?.v2.statistics;
    try testing.expectEqual(1682269536040124325, stat1.ts_recv);
    try testing.expectEqual(1682269536030443135, stat1.hd.ts_event);
    try testing.expectEqual(.statistics, stat1.hd.rtype);
    try testing.expectEqual(1, stat1.hd.publisher_id);
    try testing.expectEqual(146945, stat1.hd.instrument_id);
    try testing.expectEqual(18446744073709551615, stat1.ts_ref);
    try testing.expectEqual(100000000000, stat1.price);
    try testing.expectEqual(2147483647, stat1.quantity);
    try testing.expectEqual(2, stat1.sequence);
    try testing.expectEqual(26961, stat1.ts_in_delta);
    try testing.expectEqual(7, stat1.stat_type);
    try testing.expectEqual(13, stat1.channel_id);
    try testing.expectEqual(1, stat1.update_action);
    try testing.expectEqual(255, stat1.stat_flags);

    // Read second statistics record
    const record2 = try meta.readRecord(reader);
    try testing.expect(record2 != null);
    try testing.expect(record2.?.v2 == .statistics);

    // Check second statistics record
    const stat2 = record2.?.v2.statistics;
    try testing.expectEqual(1682269536121890092, stat2.ts_recv);
    try testing.expectEqual(1682269536071497081, stat2.hd.ts_event);
    try testing.expectEqual(.statistics, stat2.hd.rtype);
    try testing.expectEqual(1, stat2.hd.publisher_id);
    try testing.expectEqual(146945, stat2.hd.instrument_id);
    try testing.expectEqual(18446744073709551615, stat2.ts_ref);
    try testing.expectEqual(100000000000, stat2.price);
    try testing.expectEqual(9223372036854775807, stat2.quantity);
    try testing.expectEqual(7, stat2.sequence);
    try testing.expectEqual(28456, stat2.ts_in_delta);
    try testing.expectEqual(5, stat2.stat_type);
    try testing.expectEqual(13, stat2.channel_id);
    try testing.expectEqual(1, stat2.update_action);
    try testing.expectEqual(255, stat2.stat_flags);

    // Verify no more records
    const record3 = try meta.readRecord(reader);
    try testing.expect(record3 == null);
}

test "test_data.statistics.v3.dbn.zst" {
    const allocator = testing.allocator;

    // Open the compressed test data file
    const file = try std.fs.cwd().openFile("test_data/test_data.statistics.v3.dbn.zst", .{});
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
    try testing.expectEqual(.statistics, meta.schema);
    try testing.expectEqual(2814749767106560, meta.start);
    try testing.expectEqual(null, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.instrument_id, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert empty arrays
    try testing.expectEqual(0, meta.symbols.len);
    try testing.expectEqual(0, meta.partial.len);
    try testing.expectEqual(0, meta.not_found.len);
    try testing.expectEqual(0, meta.mappings.len);

    // Read first statistics record
    const record1 = try meta.readRecord(reader);
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v3 == .statistics);

    // Check first statistics record
    const stat1 = record1.?.v3.statistics;
    try testing.expectEqual(1682269536040124325, stat1.ts_recv);
    try testing.expectEqual(1682269536030443135, stat1.hd.ts_event);
    try testing.expectEqual(.statistics, stat1.hd.rtype);
    try testing.expectEqual(1, stat1.hd.publisher_id);
    try testing.expectEqual(146945, stat1.hd.instrument_id);
    try testing.expectEqual(18446744073709551615, stat1.ts_ref);
    try testing.expectEqual(100000000000, stat1.price);
    try testing.expectEqual(9223372036854775807, stat1.quantity);
    try testing.expectEqual(2, stat1.sequence);
    try testing.expectEqual(26961, stat1.ts_in_delta);
    try testing.expectEqual(7, stat1.stat_type);
    try testing.expectEqual(13, stat1.channel_id);
    try testing.expectEqual(1, stat1.update_action);
    try testing.expectEqual(255, stat1.stat_flags);

    // Read second statistics record
    const record2 = try meta.readRecord(reader);
    try testing.expect(record2 != null);
    try testing.expect(record2.?.v3 == .statistics);

    // Check second statistics record
    const stat2 = record2.?.v3.statistics;
    try testing.expectEqual(1682269536121890092, stat2.ts_recv);
    try testing.expectEqual(1682269536071497081, stat2.hd.ts_event);
    try testing.expectEqual(.statistics, stat2.hd.rtype);
    try testing.expectEqual(1, stat2.hd.publisher_id);
    try testing.expectEqual(146945, stat2.hd.instrument_id);
    try testing.expectEqual(18446744073709551615, stat2.ts_ref);
    try testing.expectEqual(100000000000, stat2.price);
    try testing.expectEqual(9223372036854775807, stat2.quantity);
    try testing.expectEqual(7, stat2.sequence);
    try testing.expectEqual(28456, stat2.ts_in_delta);
    try testing.expectEqual(5, stat2.stat_type);
    try testing.expectEqual(13, stat2.channel_id);
    try testing.expectEqual(1, stat2.update_action);
    try testing.expectEqual(255, stat2.stat_flags);

    // Verify no more records
    const record3 = try meta.readRecord(reader);
    try testing.expect(record3 == null);
}
