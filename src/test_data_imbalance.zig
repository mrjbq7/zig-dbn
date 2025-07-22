const std = @import("std");
const testing = std.testing;

const RecordIterator = @import("iter.zig").RecordIterator;

test "test_data.imbalance.dbn" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.imbalance.dbn");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("XNAS.ITCH", meta.dataset);
    try testing.expectEqual(.imbalance, meta.schema);
    try testing.expectEqual(1633305600000000000, meta.start);
    try testing.expectEqual(1641254400000000000, meta.end);
    try testing.expectEqual(2, meta.limit);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("SPOT", meta.symbols[0]);

    // Read first imbalance record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .imbalance);

    // Check first imbalance record
    const imb1 = record1.?.v2.imbalance;
    try testing.expectEqual(1633353900633864350, imb1.ts_recv);
    try testing.expectEqual(1633353900633854579, imb1.hd.ts_event);
    try testing.expectEqual(.imbalance, imb1.hd.rtype);
    try testing.expectEqual(2, imb1.hd.publisher_id);
    try testing.expectEqual(9439, imb1.hd.instrument_id);
    try testing.expectEqual(229430000000, imb1.ref_price);
    try testing.expectEqual(0, imb1.auction_time);
    try testing.expectEqual(2000, imb1.total_imbalance_qty);
    try testing.expectEqual('O', imb1.auction_type);
    try testing.expectEqual('B', imb1.side);
}

test "test_data.imbalance.v1.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.imbalance.v1.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v1
    try testing.expectEqual(.v1, meta.version);
    try testing.expectEqualStrings("XNAS.ITCH", meta.dataset);
    try testing.expectEqual(.imbalance, meta.schema);
    try testing.expectEqual(1633305600000000000, meta.start);
    try testing.expectEqual(1641254400000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(22, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("SPOT", meta.symbols[0]);

    // Read first imbalance record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v1 == .imbalance);

    // Check first imbalance record
    const imb1 = record1.?.v1.imbalance;
    try testing.expectEqual(1633353900633864350, imb1.ts_recv);
    try testing.expectEqual(1633353900633854579, imb1.hd.ts_event);
    try testing.expectEqual(.imbalance, imb1.hd.rtype);
    try testing.expectEqual(2, imb1.hd.publisher_id);
    try testing.expectEqual(9439, imb1.hd.instrument_id);
}

test "test_data.imbalance.v2.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.imbalance.v2.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v2
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("XNAS.ITCH", meta.dataset);
    try testing.expectEqual(.imbalance, meta.schema);
    try testing.expectEqual(1633305600000000000, meta.start);
    try testing.expectEqual(1641254400000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("SPOT", meta.symbols[0]);

    // Read first imbalance record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .imbalance);

    // Check first imbalance record
    const imb1 = record1.?.v2.imbalance;
    try testing.expectEqual(1633353900633864350, imb1.ts_recv);
    try testing.expectEqual(1633353900633854579, imb1.hd.ts_event);
    try testing.expectEqual(.imbalance, imb1.hd.rtype);
    try testing.expectEqual(2, imb1.hd.publisher_id);
    try testing.expectEqual(9439, imb1.hd.instrument_id);
}

test "test_data.imbalance.v3.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.imbalance.v3.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v3
    try testing.expectEqual(.v3, meta.version);
    try testing.expectEqualStrings("XNAS.ITCH", meta.dataset);
    try testing.expectEqual(.imbalance, meta.schema);
    try testing.expectEqual(1633305600000000000, meta.start);
    try testing.expectEqual(1641254400000000000, meta.end);
    try testing.expectEqual(2, meta.limit);
    try testing.expectEqual(.raw_symbol, meta.stype_in);
    try testing.expectEqual(.instrument_id, meta.stype_out);
    try testing.expectEqual(false, meta.ts_out);
    try testing.expectEqual(71, meta.symbol_cstr_len);

    // Assert symbols
    try testing.expectEqual(1, meta.symbols.len);
    try testing.expectEqualStrings("SPOT", meta.symbols[0]);

    // Read first imbalance record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v3 == .imbalance);

    // Check first imbalance record
    const imb1 = record1.?.v3.imbalance;
    try testing.expectEqual(1633353900633864350, imb1.ts_recv);
    try testing.expectEqual(1633353900633854579, imb1.hd.ts_event);
    try testing.expectEqual(.imbalance, imb1.hd.rtype);
    try testing.expectEqual(2, imb1.hd.publisher_id);
    try testing.expectEqual(9439, imb1.hd.instrument_id);
}
