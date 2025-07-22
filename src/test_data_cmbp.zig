const std = @import("std");
const testing = std.testing;

const RecordIterator = @import("iter.zig").RecordIterator;

test "test_data.cmbp-1.dbn" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.cmbp-1.dbn");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.cmbp_1, meta.schema);
    try testing.expectEqual(1609160400000000000, meta.start);
    try testing.expectEqual(1609200000000000000, meta.end);
    try testing.expectEqual(2, meta.limit);

    // Read first CMBP record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .cmbp_1);

    // Check first CMBP record
    const cmbp1 = record1.?.v2.cmbp_1;
    try testing.expectEqual(1609160400006136329, cmbp1.ts_recv);
    try testing.expectEqual(1609160400006001487, cmbp1.hd.ts_event);
    try testing.expectEqual(.cmbp_1, cmbp1.hd.rtype);
    try testing.expectEqual(1, cmbp1.hd.publisher_id);
    try testing.expectEqual(5482, cmbp1.hd.instrument_id);
    try testing.expectEqual(.add, cmbp1.action);
    try testing.expectEqual(.ask, cmbp1.side);
    try testing.expectEqual(3720500000000, cmbp1.price);
    try testing.expectEqual(1, cmbp1.size);
    try testing.expectEqual(128, cmbp1.flags.raw);
    try testing.expectEqual(17214, cmbp1.ts_in_delta);
}

test "test_data.cmbp-1.v2.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.cmbp-1.v2.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v2
    try testing.expectEqual(.v2, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.cmbp_1, meta.schema);
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

    // Read first CMBP record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v2 == .cmbp_1);

    // Check first CMBP record
    const cmbp1 = record1.?.v2.cmbp_1;
    try testing.expectEqual(1609160400006136329, cmbp1.ts_recv);
    try testing.expectEqual(1609160400006001487, cmbp1.hd.ts_event);
    try testing.expectEqual(.cmbp_1, cmbp1.hd.rtype);
    try testing.expectEqual(1, cmbp1.hd.publisher_id);
    try testing.expectEqual(5482, cmbp1.hd.instrument_id);
    try testing.expectEqual(.add, cmbp1.action);
    try testing.expectEqual(.ask, cmbp1.side);
    try testing.expectEqual(3720500000000, cmbp1.price);
    try testing.expectEqual(1, cmbp1.size);
    try testing.expectEqual(128, cmbp1.flags.raw);
    try testing.expectEqual(17214, cmbp1.ts_in_delta);
    try testing.expectEqual(3720250000000, cmbp1.levels[0].bid_px);
    try testing.expectEqual(3720500000000, cmbp1.levels[0].ask_px);
    try testing.expectEqual(24, cmbp1.levels[0].bid_sz);
    try testing.expectEqual(11, cmbp1.levels[0].ask_sz);
    try testing.expectEqual(1, cmbp1.levels[0].bid_pb);
    try testing.expectEqual(1, cmbp1.levels[0].ask_pb);
}

test "test_data.cmbp-1.v3.dbn.zst" {
    const allocator = testing.allocator;

    var iter = try RecordIterator.init(allocator, "test_data/test_data.cmbp-1.v3.dbn.zst");
    defer iter.deinit();
    const meta = iter.meta;

    // Assert metadata contents for v3
    try testing.expectEqual(.v3, meta.version);
    try testing.expectEqualStrings("GLBX.MDP3", meta.dataset);
    try testing.expectEqual(.cmbp_1, meta.schema);
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

    // Read first CMBP record
    const record1 = try iter.next();
    try testing.expect(record1 != null);
    try testing.expect(record1.?.v3 == .cmbp_1);

    // Check first CMBP record
    const cmbp1 = record1.?.v3.cmbp_1;
    try testing.expectEqual(1609160400006136329, cmbp1.ts_recv);
    try testing.expectEqual(1609160400006001487, cmbp1.hd.ts_event);
    try testing.expectEqual(.cmbp_1, cmbp1.hd.rtype);
    try testing.expectEqual(1, cmbp1.hd.publisher_id);
    try testing.expectEqual(5482, cmbp1.hd.instrument_id);
}
