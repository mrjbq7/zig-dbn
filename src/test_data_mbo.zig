const std = @import("std");
const testing = std.testing;

const RecordIterator = @import("iter.zig").RecordIterator;

test "test_data.mbo.dbn" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.mbo.dbn");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.mbo, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);

    // Read first MBO record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .mbo);

    // Check first MBO record
    const mbo1 = record1.?.v2.mbo;
    try testing.expectEqual(1609160400000704060, mbo1.ts_recv);
    try testing.expectEqual(1609160400000429831, mbo1.hd.ts_event);
    try testing.expectEqual(.mbo, mbo1.hd.rtype);
    try testing.expectEqual(1, mbo1.hd.publisher_id);
    try testing.expectEqual(5482, mbo1.hd.instrument_id);
    try testing.expectEqual(.cancel, mbo1.action);
    try testing.expectEqual(.ask, mbo1.side);
    try testing.expectEqual(3722750000000, mbo1.price);
    try testing.expectEqual(1, mbo1.size);
    try testing.expectEqual(0, mbo1.channel_id);
    try testing.expectEqual(647784973705, mbo1.order_id);
    try testing.expectEqual(128, mbo1.flags.raw);
    try testing.expectEqual(22993, mbo1.ts_in_delta);
    try testing.expectEqual(1170352, mbo1.sequence);
}

test "test_data.mbo.v1.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.mbo.v1.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v1
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.mbo, meta.schema);
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

    // Read first MBO record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v1 == .mbo);

    // Check first MBO record
    const mbo1 = record1.?.v1.mbo;
    try testing.expectEqual(1609160400000704060, mbo1.ts_recv);
    try testing.expectEqual(1609160400000429831, mbo1.hd.ts_event);
    try testing.expectEqual(.mbo, mbo1.hd.rtype);
    try testing.expectEqual(1, mbo1.hd.publisher_id);
    try testing.expectEqual(5482, mbo1.hd.instrument_id);
    try testing.expectEqual(.cancel, mbo1.action);
    try testing.expectEqual(.ask, mbo1.side);
    try testing.expectEqual(3722750000000, mbo1.price);
    try testing.expectEqual(1, mbo1.size);
    try testing.expectEqual(0, mbo1.channel_id);
    try testing.expectEqual(647784973705, mbo1.order_id);
    try testing.expectEqual(128, mbo1.flags.raw);
    try testing.expectEqual(22993, mbo1.ts_in_delta);
    try testing.expectEqual(1170352, mbo1.sequence);
}

test "test_data.mbo.v2.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.mbo.v2.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v2
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.mbo, meta.schema);
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

    // Read first MBO record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .mbo);

    // Check first MBO record
    const mbo1 = record1.?.v2.mbo;
    try testing.expectEqual(1609160400000704060, mbo1.ts_recv);
    try testing.expectEqual(1609160400000429831, mbo1.hd.ts_event);
    try testing.expectEqual(.mbo, mbo1.hd.rtype);
    try testing.expectEqual(1, mbo1.hd.publisher_id);
    try testing.expectEqual(5482, mbo1.hd.instrument_id);
    try testing.expectEqual(.cancel, mbo1.action);
    try testing.expectEqual(.ask, mbo1.side);
    try testing.expectEqual(3722750000000, mbo1.price);
    try testing.expectEqual(1, mbo1.size);
    try testing.expectEqual(0, mbo1.channel_id);
    try testing.expectEqual(647784973705, mbo1.order_id);
    try testing.expectEqual(128, mbo1.flags.raw);
    try testing.expectEqual(22993, mbo1.ts_in_delta);
    try testing.expectEqual(1170352, mbo1.sequence);
}

test "test_data.mbo.v3.dbn" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.mbo.v3.dbn");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents
    try testing.expectEqual(.v3, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.mbo, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);

    // Read first MBO record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v3 == .mbo);

    // Check first MBO record (same values as v2)
    const mbo1 = record1.?.v3.mbo;
    try testing.expectEqual(1609160400000704060, mbo1.ts_recv);
    try testing.expectEqual(1609160400000429831, mbo1.hd.ts_event);
    try testing.expectEqual(.mbo, mbo1.hd.rtype);
    try testing.expectEqual(1, mbo1.hd.publisher_id);
    try testing.expectEqual(5482, mbo1.hd.instrument_id);
}

test "test_data.mbo.v3.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.mbo.v3.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v3
    try testing.expectEqual(.v3, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.mbo, meta.schema);
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

    // Read first MBO record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v3 == .mbo);

    // Check first MBO record
    const mbo1 = record1.?.v3.mbo;
    try testing.expectEqual(1609160400000704060, mbo1.ts_recv);
    try testing.expectEqual(1609160400000429831, mbo1.hd.ts_event);
    try testing.expectEqual(.mbo, mbo1.hd.rtype);
    try testing.expectEqual(1, mbo1.hd.publisher_id);
    try testing.expectEqual(5482, mbo1.hd.instrument_id);
}

test "test_data.mbo.dbz" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.mbo.dbz");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v1
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.mbo, meta.schema);
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

    // Read first MBO record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v1 == .mbo);

    // Check first MBO record
    const mbo1 = record1.?.v1.mbo;
    try testing.expectEqual(1609160400000704060, mbo1.ts_recv);
    try testing.expectEqual(1609160400000429831, mbo1.hd.ts_event);
    try testing.expectEqual(.mbo, mbo1.hd.rtype);
    try testing.expectEqual(1, mbo1.hd.publisher_id);
    try testing.expectEqual(5482, mbo1.hd.instrument_id);
    try testing.expectEqual(.cancel, mbo1.action);
    try testing.expectEqual(.ask, mbo1.side);
    try testing.expectEqual(3722750000000, mbo1.price);
    try testing.expectEqual(1, mbo1.size);
    try testing.expectEqual(0, mbo1.channel_id);
    try testing.expectEqual(647784973705, mbo1.order_id);
    try testing.expectEqual(128, mbo1.flags.raw);
    try testing.expectEqual(22993, mbo1.ts_in_delta);
    try testing.expectEqual(1170352, mbo1.sequence);
}
