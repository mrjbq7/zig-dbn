const std = @import("std");
const testing = std.testing;

const RecordIterator = @import("iter.zig").RecordIterator;

test "test_data.ohlcv-1d.dbn" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1d.dbn");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1d, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Assert mappings
    try testing.expectEqual(1, meta.mappings.len);
    try testing.expectEqualStrings("ESH1", meta.mappings[0].raw_symbol);
    try testing.expectEqual(1, meta.mappings[0].intervals.len);
    try testing.expectEqual(20201228, meta.mappings[0].intervals[0].start_ts);
    try testing.expectEqual(20201229, meta.mappings[0].intervals[0].end_ts);
    try testing.expectEqualStrings("5482", meta.mappings[0].intervals[0].symbol);

    // Read first OHLCV record (if present - limit is 2 but might not have records)
    const record1 = try iter.next();
    if (record1) |r| {
        try testing.expect(r.v2 == .ohlcv);
        const ohlcv1 = r.v2.ohlcv;
        try testing.expectEqual(.ohlcv_1d, ohlcv1.hd.rtype);
        try testing.expectEqual(1, ohlcv1.hd.publisher_id);
        try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    }
}

test "test_data.ohlcv-1d.v1.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1d.v1.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v1
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1d, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(22, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first OHLCV record (if present - limit is 2 but might not have records)
    const record1 = try iter.next();
    if (record1) |r| {
        try testing.expect(r.v1 == .ohlcv);
        const ohlcv1 = r.v1.ohlcv;
        try testing.expectEqual(.ohlcv_1d, ohlcv1.hd.rtype);
        try testing.expectEqual(1, ohlcv1.hd.publisher_id);
        try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    }
}

test "test_data.ohlcv-1d.v2.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1d.v2.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v2
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1d, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Assert mappings
    try testing.expectEqual(1, meta.mappings.len);
    try testing.expectEqualStrings("ESH1", meta.mappings[0].raw_symbol);
    try testing.expectEqual(1, meta.mappings[0].intervals.len);
    try testing.expectEqual(20201228, meta.mappings[0].intervals[0].start_ts);
    try testing.expectEqual(20201229, meta.mappings[0].intervals[0].end_ts);
    try testing.expectEqualStrings("5482", meta.mappings[0].intervals[0].symbol);

    // Read first OHLCV record (if present - limit is 2 but might not have records)
    const record1 = try iter.next();
    if (record1) |r| {
        try testing.expect(r.v2 == .ohlcv);
        const ohlcv1 = r.v2.ohlcv;
        try testing.expectEqual(.ohlcv_1d, ohlcv1.hd.rtype);
        try testing.expectEqual(1, ohlcv1.hd.publisher_id);
        try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    }
}

test "test_data.ohlcv-1d.v3.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1d.v3.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v3
    try testing.expectEqual(.v3, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1d, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Assert mappings
    try testing.expectEqual(1, meta.mappings.len);
    try testing.expectEqualStrings("ESH1", meta.mappings[0].raw_symbol);
    try testing.expectEqual(1, meta.mappings[0].intervals.len);
    try testing.expectEqual(20201228, meta.mappings[0].intervals[0].start_ts);
    try testing.expectEqual(20201229, meta.mappings[0].intervals[0].end_ts);
    try testing.expectEqualStrings("5482", meta.mappings[0].intervals[0].symbol);

    // Read first OHLCV record (if present)
    const record1 = try iter.next();
    if (record1) |r| {
        try testing.expect(r.v3 == .ohlcv);
        const ohlcv1 = r.v3.ohlcv;
        try testing.expectEqual(.ohlcv_1d, ohlcv1.hd.rtype);
        try testing.expectEqual(1, ohlcv1.hd.publisher_id);
        try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    }
}

test "test_data.ohlcv-1d.dbz" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1d.dbz");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v1
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1d, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(22, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first OHLCV record (if present - limit is 2 but might not have records)
    const record1 = try iter.next();
    if (record1) |r| {
        try testing.expect(r.v1 == .ohlcv);
        const ohlcv1 = r.v1.ohlcv;
        try testing.expectEqual(.ohlcv_1d, ohlcv1.hd.rtype);
        try testing.expectEqual(1, ohlcv1.hd.publisher_id);
        try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    }
}

test "test_data.ohlcv-1h.dbn" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1h.dbn");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1h, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);

    // Read first OHLCV record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .ohlcv);

    // Check first OHLCV record
    const ohlcv1 = record1.?.v2.ohlcv;
    try testing.expectEqual(1609160400000000000, ohlcv1.hd.ts_event);
    try testing.expectEqual(.ohlcv_1h, ohlcv1.hd.rtype);
    try testing.expectEqual(1, ohlcv1.hd.publisher_id);
    try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    try testing.expectEqual(372025000000000, ohlcv1.open);
    try testing.expectEqual(372350000000000, ohlcv1.high);
    try testing.expectEqual(372025000000000, ohlcv1.low);
    try testing.expectEqual(372225000000000, ohlcv1.close);
    try testing.expectEqual(9385, ohlcv1.volume);
}

test "test_data.ohlcv-1h.v1.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1h.v1.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v2
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1h, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(22, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first OHLCV record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v1 == .ohlcv);

    // Check first OHLCV record
    const ohlcv1 = record1.?.v1.ohlcv;
    try testing.expectEqual(1609160400000000000, ohlcv1.hd.ts_event);
    try testing.expectEqual(.ohlcv_1h, ohlcv1.hd.rtype);
    try testing.expectEqual(1, ohlcv1.hd.publisher_id);
    try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    try testing.expectEqual(372025000000000, ohlcv1.open);
    try testing.expectEqual(372350000000000, ohlcv1.high);
    try testing.expectEqual(372025000000000, ohlcv1.low);
    try testing.expectEqual(372225000000000, ohlcv1.close);
    try testing.expectEqual(9385, ohlcv1.volume);
}

test "test_data.ohlcv-1h.v2.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1h.v2.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v2
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1h, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first OHLCV record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .ohlcv);

    // Check first OHLCV record
    const ohlcv1 = record1.?.v2.ohlcv;
    try testing.expectEqual(1609160400000000000, ohlcv1.hd.ts_event);
    try testing.expectEqual(.ohlcv_1h, ohlcv1.hd.rtype);
    try testing.expectEqual(1, ohlcv1.hd.publisher_id);
    try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    try testing.expectEqual(372025000000000, ohlcv1.open);
    try testing.expectEqual(372350000000000, ohlcv1.high);
    try testing.expectEqual(372025000000000, ohlcv1.low);
    try testing.expectEqual(372225000000000, ohlcv1.close);
    try testing.expectEqual(9385, ohlcv1.volume);
}

test "test_data.ohlcv-1h.v3.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1h.v3.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v3
    try testing.expectEqual(.v3, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1h, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first OHLCV record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v3 == .ohlcv);

    // Check first OHLCV record
    const ohlcv1 = record1.?.v3.ohlcv;
    try testing.expectEqual(1609160400000000000, ohlcv1.hd.ts_event);
    try testing.expectEqual(.ohlcv_1h, ohlcv1.hd.rtype);
    try testing.expectEqual(1, ohlcv1.hd.publisher_id);
    try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
}

test "test_data.ohlcv-1h.dbz" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1h.dbz");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v2
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1h, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(22, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first OHLCV record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v1 == .ohlcv);

    // Check first OHLCV record
    const ohlcv1 = record1.?.v1.ohlcv;
    try testing.expectEqual(1609160400000000000, ohlcv1.hd.ts_event);
    try testing.expectEqual(.ohlcv_deprecated, ohlcv1.hd.rtype);
    try testing.expectEqual(1, ohlcv1.hd.publisher_id);
    try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    try testing.expectEqual(372025000000000, ohlcv1.open);
    try testing.expectEqual(372350000000000, ohlcv1.high);
    try testing.expectEqual(372025000000000, ohlcv1.low);
    try testing.expectEqual(372225000000000, ohlcv1.close);
    try testing.expectEqual(9385, ohlcv1.volume);
}

test "test_data.ohlcv-1m.dbn" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1m.dbn");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1m, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);

    // Read first OHLCV record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .ohlcv);

    // Check first OHLCV record
    const ohlcv1 = record1.?.v2.ohlcv;
    try testing.expectEqual(1609160400000000000, ohlcv1.hd.ts_event);
    try testing.expectEqual(.ohlcv_1m, ohlcv1.hd.rtype);
    try testing.expectEqual(1, ohlcv1.hd.publisher_id);
    try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    try testing.expectEqual(372025000000000, ohlcv1.open);
    try testing.expectEqual(372150000000000, ohlcv1.high);
    try testing.expectEqual(372025000000000, ohlcv1.low);
    try testing.expectEqual(372100000000000, ohlcv1.close);
    try testing.expectEqual(353, ohlcv1.volume);
}

test "test_data.ohlcv-1m.v1.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1m.v1.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v1
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1m, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(22, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first OHLCV record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v1 == .ohlcv);

    // Check first OHLCV record
    const ohlcv1 = record1.?.v1.ohlcv;
    try testing.expectEqual(1609160400000000000, ohlcv1.hd.ts_event);
    try testing.expectEqual(.ohlcv_1m, ohlcv1.hd.rtype);
    try testing.expectEqual(1, ohlcv1.hd.publisher_id);
    try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    try testing.expectEqual(372025000000000, ohlcv1.open);
    try testing.expectEqual(372150000000000, ohlcv1.high);
    try testing.expectEqual(372025000000000, ohlcv1.low);
    try testing.expectEqual(372100000000000, ohlcv1.close);
    try testing.expectEqual(353, ohlcv1.volume);
}

test "test_data.ohlcv-1m.v2.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1m.v2.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v2
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1m, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first OHLCV record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .ohlcv);

    // Check first OHLCV record
    const ohlcv1 = record1.?.v2.ohlcv;
    try testing.expectEqual(1609160400000000000, ohlcv1.hd.ts_event);
    try testing.expectEqual(.ohlcv_1m, ohlcv1.hd.rtype);
    try testing.expectEqual(1, ohlcv1.hd.publisher_id);
    try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    try testing.expectEqual(372025000000000, ohlcv1.open);
    try testing.expectEqual(372150000000000, ohlcv1.high);
    try testing.expectEqual(372025000000000, ohlcv1.low);
    try testing.expectEqual(372100000000000, ohlcv1.close);
    try testing.expectEqual(353, ohlcv1.volume);
}

test "test_data.ohlcv-1m.v3.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1m.v3.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v3
    try testing.expectEqual(.v3, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1m, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first OHLCV record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v3 == .ohlcv);

    // Check first OHLCV record
    const ohlcv1 = record1.?.v3.ohlcv;
    try testing.expectEqual(1609160400000000000, ohlcv1.hd.ts_event);
    try testing.expectEqual(.ohlcv_1m, ohlcv1.hd.rtype);
    try testing.expectEqual(1, ohlcv1.hd.publisher_id);
    try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
}

test "test_data.ohlcv-1m.dbz" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1m.dbz");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v1
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1m, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(22, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first OHLCV record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v1 == .ohlcv);

    // Check first OHLCV record
    const ohlcv1 = record1.?.v1.ohlcv;
    try testing.expectEqual(1609160400000000000, ohlcv1.hd.ts_event);
    try testing.expectEqual(.ohlcv_deprecated, ohlcv1.hd.rtype);
    try testing.expectEqual(1, ohlcv1.hd.publisher_id);
    try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    try testing.expectEqual(372025000000000, ohlcv1.open);
    try testing.expectEqual(372150000000000, ohlcv1.high);
    try testing.expectEqual(372025000000000, ohlcv1.low);
    try testing.expectEqual(372100000000000, ohlcv1.close);
    try testing.expectEqual(353, ohlcv1.volume);
}

test "test_data.ohlcv-1s.dbn" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1s.dbn");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1s, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);

    // Read first OHLCV record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .ohlcv);

    // Check first OHLCV record
    const ohlcv1 = record1.?.v2.ohlcv;
    try testing.expectEqual(1609160400000000000, ohlcv1.hd.ts_event);
    try testing.expectEqual(.ohlcv_1s, ohlcv1.hd.rtype);
    try testing.expectEqual(1, ohlcv1.hd.publisher_id);
    try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    try testing.expectEqual(372025000000000, ohlcv1.open);
    try testing.expectEqual(372050000000000, ohlcv1.high);
    try testing.expectEqual(372025000000000, ohlcv1.low);
    try testing.expectEqual(372050000000000, ohlcv1.close);
    try testing.expectEqual(57, ohlcv1.volume);
}

test "test_data.ohlcv-1s.v1.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1s.v1.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v1
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1s, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(22, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first OHLCV record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v1 == .ohlcv);

    // Check first OHLCV record
    const ohlcv1 = record1.?.v1.ohlcv;
    try testing.expectEqual(1609160400000000000, ohlcv1.hd.ts_event);
    try testing.expectEqual(.ohlcv_1s, ohlcv1.hd.rtype);
    try testing.expectEqual(1, ohlcv1.hd.publisher_id);
    try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    try testing.expectEqual(372025000000000, ohlcv1.open);
    try testing.expectEqual(372050000000000, ohlcv1.high);
    try testing.expectEqual(372025000000000, ohlcv1.low);
    try testing.expectEqual(372050000000000, ohlcv1.close);
    try testing.expectEqual(57, ohlcv1.volume);
}

test "test_data.ohlcv-1s.v2.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1s.v2.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v2
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1s, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first OHLCV record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .ohlcv);

    // Check first OHLCV record
    const ohlcv1 = record1.?.v2.ohlcv;
    try testing.expectEqual(1609160400000000000, ohlcv1.hd.ts_event);
    try testing.expectEqual(.ohlcv_1s, ohlcv1.hd.rtype);
    try testing.expectEqual(1, ohlcv1.hd.publisher_id);
    try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    try testing.expectEqual(372025000000000, ohlcv1.open);
    try testing.expectEqual(372050000000000, ohlcv1.high);
    try testing.expectEqual(372025000000000, ohlcv1.low);
    try testing.expectEqual(372050000000000, ohlcv1.close);
    try testing.expectEqual(57, ohlcv1.volume);
}

test "test_data.ohlcv-1s.v3.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1s.v3.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v3
    try testing.expectEqual(.v3, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1s, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first OHLCV record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v3 == .ohlcv);

    // Check first OHLCV record
    const ohlcv1 = record1.?.v3.ohlcv;
    try testing.expectEqual(1609160400000000000, ohlcv1.hd.ts_event);
    try testing.expectEqual(.ohlcv_1s, ohlcv1.hd.rtype);
    try testing.expectEqual(1, ohlcv1.hd.publisher_id);
    try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
}

test "test_data.ohlcv-1s.dbz" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.ohlcv-1s.dbz");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v1
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.ohlcv_1s, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(22, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("ESH1", meta.symbols[0]);

    // Read first OHLCV record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v1 == .ohlcv);

    // Check first OHLCV record
    const ohlcv1 = record1.?.v1.ohlcv;
    try testing.expectEqual(1609160400000000000, ohlcv1.hd.ts_event);
    try testing.expectEqual(.ohlcv_deprecated, ohlcv1.hd.rtype);
    try testing.expectEqual(1, ohlcv1.hd.publisher_id);
    try testing.expectEqual(5482, ohlcv1.hd.instrument_id);
    try testing.expectEqual(372025000000000, ohlcv1.open);
    try testing.expectEqual(372050000000000, ohlcv1.high);
    try testing.expectEqual(372025000000000, ohlcv1.low);
    try testing.expectEqual(372050000000000, ohlcv1.close);
    try testing.expectEqual(57, ohlcv1.volume);
}
