const std = @import("std");
const testing = std.testing;

const RecordIterator = @import("iter.zig").RecordIterator;

test "test_data.tbbo.dbn" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.tbbo.dbn");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.tbbo, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);

    // Read first TBBO record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .mbp_1);

    // Check first TBBO record (uses mbp_1 struct)
    const tbbo1 = record1.?.v2.mbp_1;
    try testing.expectEqual(1609160400099150057, tbbo1.ts_recv);
    try testing.expectEqual(1609160400098821953, tbbo1.hd.ts_event);
    try testing.expectEqual(.mbp_1, tbbo1.hd.rtype);
    try testing.expectEqual(1, tbbo1.hd.publisher_id);
    try testing.expectEqual(5482, tbbo1.hd.instrument_id);
    try testing.expectEqual(.trade, tbbo1.action);
    try testing.expectEqual(.ask, tbbo1.side);
    try testing.expectEqual(0, tbbo1.depth);
    try testing.expectEqual(3720250000000, tbbo1.price);
    try testing.expectEqual(5, tbbo1.size);
    try testing.expectEqual(129, tbbo1.flags.raw);
    try testing.expectEqual(19251, tbbo1.ts_in_delta);
    try testing.expectEqual(1170380, tbbo1.sequence);
}

test "test_data.tbbo.v1.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.tbbo.v1.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v1
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.tbbo, meta.schema);
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

    // Read first TBBO record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v1 == .mbp_1);

    // Check first TBBO record (uses mbp_1 struct)
    const tbbo1 = record1.?.v1.mbp_1;
    try testing.expectEqual(1609160400099150057, tbbo1.ts_recv);
    try testing.expectEqual(1609160400098821953, tbbo1.hd.ts_event);
    try testing.expectEqual(.mbp_1, tbbo1.hd.rtype);
    try testing.expectEqual(1, tbbo1.hd.publisher_id);
    try testing.expectEqual(5482, tbbo1.hd.instrument_id);
    try testing.expectEqual(.trade, tbbo1.action);
    try testing.expectEqual(.ask, tbbo1.side);
    try testing.expectEqual(0, tbbo1.depth);
    try testing.expectEqual(3720250000000, tbbo1.price);
    try testing.expectEqual(5, tbbo1.size);
    try testing.expectEqual(129, tbbo1.flags.raw);
    try testing.expectEqual(19251, tbbo1.ts_in_delta);
    try testing.expectEqual(1170380, tbbo1.sequence);
    try testing.expectEqual(3720250000000, tbbo1.levels[0].bid_px);
    try testing.expectEqual(3720500000000, tbbo1.levels[0].ask_px);
    try testing.expectEqual(26, tbbo1.levels[0].bid_sz);
    try testing.expectEqual(7, tbbo1.levels[0].ask_sz);
    try testing.expectEqual(16, tbbo1.levels[0].bid_ct);
    try testing.expectEqual(6, tbbo1.levels[0].ask_ct);
}

test "test_data.tbbo.v2.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.tbbo.v2.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v2
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.tbbo, meta.schema);
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

    // Read first TBBO record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .mbp_1);

    // Check first TBBO record (uses mbp_1 struct)
    const tbbo1 = record1.?.v2.mbp_1;
    try testing.expectEqual(1609160400099150057, tbbo1.ts_recv);
    try testing.expectEqual(1609160400098821953, tbbo1.hd.ts_event);
    try testing.expectEqual(.mbp_1, tbbo1.hd.rtype);
    try testing.expectEqual(1, tbbo1.hd.publisher_id);
    try testing.expectEqual(5482, tbbo1.hd.instrument_id);
    try testing.expectEqual(.trade, tbbo1.action);
    try testing.expectEqual(.ask, tbbo1.side);
    try testing.expectEqual(0, tbbo1.depth);
    try testing.expectEqual(3720250000000, tbbo1.price);
    try testing.expectEqual(5, tbbo1.size);
    try testing.expectEqual(129, tbbo1.flags.raw);
    try testing.expectEqual(19251, tbbo1.ts_in_delta);
    try testing.expectEqual(1170380, tbbo1.sequence);
    try testing.expectEqual(3720250000000, tbbo1.levels[0].bid_px);
    try testing.expectEqual(3720500000000, tbbo1.levels[0].ask_px);
    try testing.expectEqual(26, tbbo1.levels[0].bid_sz);
    try testing.expectEqual(7, tbbo1.levels[0].ask_sz);
    try testing.expectEqual(16, tbbo1.levels[0].bid_ct);
    try testing.expectEqual(6, tbbo1.levels[0].ask_ct);
}

test "test_data.tbbo.v3.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.tbbo.v3.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v3
    try testing.expectEqual(.v3, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.tbbo, meta.schema);
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

    // Read first TBBO record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v3 == .mbp_1);

    // Check first TBBO record (uses mbp_1 struct)
    const tbbo1 = record1.?.v3.mbp_1;
    try testing.expectEqual(1609160400099150057, tbbo1.ts_recv);
    try testing.expectEqual(1609160400098821953, tbbo1.hd.ts_event);
    try testing.expectEqual(.mbp_1, tbbo1.hd.rtype);
    try testing.expectEqual(1, tbbo1.hd.publisher_id);
    try testing.expectEqual(5482, tbbo1.hd.instrument_id);
}

test "test_data.tbbo.dbz" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.tbbo.dbz");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v1
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.tbbo, meta.schema);
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

    // Read first TBBO record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v1 == .mbp_1);

    // Check first TBBO record (uses mbp_1 struct)
    const tbbo1 = record1.?.v1.mbp_1;
    try testing.expectEqual(1609160400099150057, tbbo1.ts_recv);
    try testing.expectEqual(1609160400098821953, tbbo1.hd.ts_event);
    try testing.expectEqual(.mbp_1, tbbo1.hd.rtype);
    try testing.expectEqual(1, tbbo1.hd.publisher_id);
    try testing.expectEqual(5482, tbbo1.hd.instrument_id);
    try testing.expectEqual(.trade, tbbo1.action);
    try testing.expectEqual(.ask, tbbo1.side);
    try testing.expectEqual(0, tbbo1.depth);
    try testing.expectEqual(3720250000000, tbbo1.price);
    try testing.expectEqual(5, tbbo1.size);
    try testing.expectEqual(129, tbbo1.flags.raw);
    try testing.expectEqual(19251, tbbo1.ts_in_delta);
    try testing.expectEqual(1170380, tbbo1.sequence);
    try testing.expectEqual(3720250000000, tbbo1.levels[0].bid_px);
    try testing.expectEqual(3720500000000, tbbo1.levels[0].ask_px);
    try testing.expectEqual(26, tbbo1.levels[0].bid_sz);
    try testing.expectEqual(7, tbbo1.levels[0].ask_sz);
    try testing.expectEqual(16, tbbo1.levels[0].bid_ct);
    try testing.expectEqual(6, tbbo1.levels[0].ask_ct);
}
