const std = @import("std");
const testing = std.testing;

const RecordIterator = @import("iter.zig").RecordIterator;

test "test_data.trades.dbn" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.trades.dbn");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.trades, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);

    // Read first trade record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .trade);

    // Check first trade record
    const trade1 = record1.?.v2.trade;
    try testing.expectEqual(1609160400099150057, trade1.ts_recv);
    try testing.expectEqual(1609160400098821953, trade1.hd.ts_event);
    try testing.expectEqual(.mbp_0, trade1.hd.rtype);
    try testing.expectEqual(1, trade1.hd.publisher_id);
    try testing.expectEqual(5482, trade1.hd.instrument_id);
    try testing.expectEqual(.trade, trade1.action);
    try testing.expectEqual(.ask, trade1.side);
    try testing.expectEqual(0, trade1.depth);
    try testing.expectEqual(3720250000000, trade1.price);
    try testing.expectEqual(5, trade1.size);
    try testing.expectEqual(129, trade1.flags.raw);
    try testing.expectEqual(19251, trade1.ts_in_delta);
    try testing.expectEqual(1170380, trade1.sequence);
}

test "test_data.trades.v1.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.trades.v1.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v1
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.trades, meta.schema);
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

    // Read first trade record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v1 == .trade);

    // Check first trade record
    const trade1 = record1.?.v1.trade;
    try testing.expectEqual(1609160400099150057, trade1.ts_recv);
    try testing.expectEqual(1609160400098821953, trade1.hd.ts_event);
    try testing.expectEqual(.mbp_0, trade1.hd.rtype);
    try testing.expectEqual(1, trade1.hd.publisher_id);
    try testing.expectEqual(5482, trade1.hd.instrument_id);
    try testing.expectEqual(.trade, trade1.action);
    try testing.expectEqual(.ask, trade1.side);
    try testing.expectEqual(0, trade1.depth);
    try testing.expectEqual(3720250000000, trade1.price);
    try testing.expectEqual(5, trade1.size);
    try testing.expectEqual(129, trade1.flags.raw);
    try testing.expectEqual(19251, trade1.ts_in_delta);
    try testing.expectEqual(1170380, trade1.sequence);
}

test "test_data.trades.v2.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.trades.v2.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v2
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.trades, meta.schema);
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

    // Read first trade record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .trade);

    // Check first trade record
    const trade1 = record1.?.v2.trade;
    try testing.expectEqual(1609160400099150057, trade1.ts_recv);
    try testing.expectEqual(1609160400098821953, trade1.hd.ts_event);
    try testing.expectEqual(.mbp_0, trade1.hd.rtype);
    try testing.expectEqual(1, trade1.hd.publisher_id);
    try testing.expectEqual(5482, trade1.hd.instrument_id);
    try testing.expectEqual(.trade, trade1.action);
    try testing.expectEqual(.ask, trade1.side);
    try testing.expectEqual(0, trade1.depth);
    try testing.expectEqual(3720250000000, trade1.price);
    try testing.expectEqual(5, trade1.size);
    try testing.expectEqual(129, trade1.flags.raw);
    try testing.expectEqual(19251, trade1.ts_in_delta);
    try testing.expectEqual(1170380, trade1.sequence);
}

test "test_data.trades.v3.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.trades.v3.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v3
    try testing.expectEqual(.v3, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.trades, meta.schema);
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

    // Read first trade record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v3 == .trade);

    // Check first trade record
    const trade1 = record1.?.v3.trade;
    try testing.expectEqual(1609160400099150057, trade1.ts_recv);
    try testing.expectEqual(1609160400098821953, trade1.hd.ts_event);
    try testing.expectEqual(.mbp_0, trade1.hd.rtype);
    try testing.expectEqual(1, trade1.hd.publisher_id);
    try testing.expectEqual(5482, trade1.hd.instrument_id);
}

test "test_data.trades.dbz" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.trades.dbz");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v1
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.trades, meta.schema);
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

    // Read first trade record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v1 == .trade);

    // Check first trade record
    const trade1 = record1.?.v1.trade;
    try testing.expectEqual(1609160400099150057, trade1.ts_recv);
    try testing.expectEqual(1609160400098821953, trade1.hd.ts_event);
    try testing.expectEqual(.mbp_0, trade1.hd.rtype);
    try testing.expectEqual(1, trade1.hd.publisher_id);
    try testing.expectEqual(5482, trade1.hd.instrument_id);
    try testing.expectEqual(.trade, trade1.action);
    try testing.expectEqual(.ask, trade1.side);
    try testing.expectEqual(0, trade1.depth);
    try testing.expectEqual(3720250000000, trade1.price);
    try testing.expectEqual(5, trade1.size);
    try testing.expectEqual(129, trade1.flags.raw);
    try testing.expectEqual(19251, trade1.ts_in_delta);
    try testing.expectEqual(1170380, trade1.sequence);
}
