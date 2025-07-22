const std = @import("std");
const testing = std.testing;

const RecordIterator = @import("iter.zig").RecordIterator;

test "test_data.definition.dbn" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.definition.dbn");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("XNAS.ITCH", meta.dataset);
    try testing.expectEqual(.definition, meta.schema);
    try testing.expectEqual(1633305600000000000, meta.start);
    try testing.expectEqual(1641254400000000000, meta.end);
    try testing.expectEqual(2, meta.limit);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("MSFT", meta.symbols[0]);

    // Assert mappings for MSFT (should have 62 intervals)
    try testing.expectEqual(1, meta.mappings.len);
    try testing.expectEqualStrings("MSFT", meta.mappings[0].raw_symbol);
    try testing.expectEqual(62, meta.mappings[0].intervals.len);

    // Check first few intervals
    try testing.expectEqual(20211004, meta.mappings[0].intervals[0].start_ts);
    try testing.expectEqual(20211005, meta.mappings[0].intervals[0].end_ts);
    try testing.expectEqual(6819, meta.mappings[0].intervals[0].instrument_id);

    try testing.expectEqual(20211005, meta.mappings[0].intervals[1].start_ts);
    try testing.expectEqual(20211006, meta.mappings[0].intervals[1].end_ts);
    try testing.expectEqual(6830, meta.mappings[0].intervals[1].instrument_id);

    // Check last interval
    try testing.expectEqual(20220103, meta.mappings[0].intervals[61].start_ts);
    try testing.expectEqual(20220104, meta.mappings[0].intervals[61].end_ts);
    try testing.expectEqual(7119, meta.mappings[0].intervals[61].instrument_id);

    // TODO: FIX THIS TEST

    // // Read first definition record
    // const record1 = try iter.next();
    // try testing.expect(record1 != null);
    // try testing.expect(record1.? == .instrument_def);

    // // Check first definition record
    // const def1 = record1.?.instrument_def;
    // try testing.expectEqual(1633331241618029519, def1.ts_recv);
    // try testing.expectEqual(1633331241618018154, def1.hd.ts_event);
    // try testing.expectEqual(.instrument_def, def1.hd.rtype);
    // try testing.expectEqual(2, def1.hd.publisher_id);
    // try testing.expectEqual(6819, def1.hd.instrument_id);
}

test "test_data.definition.dbz" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.definition.dbz");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("XNAS.ITCH", meta.dataset);
    try testing.expectEqual(.definition, meta.schema);
    try testing.expectEqual(1664841600000000000, meta.start);
    try testing.expectEqual(1672790400000000000, meta.end);
    try testing.expectEqual(null, meta.limit);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("MSFT", meta.symbols[0]);

    // Assert mappings for MSFT (should have 62 intervals)
    try testing.expectEqual(1, meta.mappings.len);
    try testing.expectEqualStrings("MSFT", meta.mappings[0].raw_symbol);
    try testing.expectEqual(20, meta.mappings[0].intervals.len);

    // Check first few intervals
    try testing.expectEqual(20221004, meta.mappings[0].intervals[0].start_ts);
    try testing.expectEqual(20221205, meta.mappings[0].intervals[0].end_ts);
    try testing.expectEqual(7358, meta.mappings[0].intervals[0].instrument_id);

    try testing.expectEqual(20221205, meta.mappings[0].intervals[1].start_ts);
    try testing.expectEqual(20221206, meta.mappings[0].intervals[1].end_ts);
    try testing.expectEqual(7236, meta.mappings[0].intervals[1].instrument_id);

    // Check last interval
    try testing.expectEqual(20230103, meta.mappings[0].intervals[19].start_ts);
    try testing.expectEqual(20230104, meta.mappings[0].intervals[19].end_ts);
    try testing.expectEqual(7084, meta.mappings[0].intervals[19].instrument_id);

    // TODO: FIX THIS TEST
    //
    // // Read first definition record
    // const record1 = try iter.next();
    // try testing.expect(record1 != null);
    // try testing.expect(record1.? == .instrument_def);
}
