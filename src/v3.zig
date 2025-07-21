const std = @import("std");

const Record = @import("record.zig").Record;
const RecordHeader = @import("record.zig").RecordHeader;
const UserDefinedInstrument = @import("enums.zig").UserDefinedInstrument;
const RType = @import("enums.zig").RType;

const v1 = @import("v1.zig");
const v2 = @import("v2.zig");

pub const SYMBOL_CSTR_LEN: usize = v2.SYMBOL_CSTR_LEN;
pub const ASSET_CSTR_LEN: usize = 11;
pub const UNDEF_STAT_QUANTITY: i64 = std.math.maxInt(i64);
pub const METADATA_RESERVED_LEN: usize = v2.METADATA_RESERVED_LEN;

/// Definition of an instrument. The record of the
/// `Definition` schema.
pub const InstrumentDefMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The capture-server-received timestamp expressed as the number of nanoseconds
    /// since the UNIX epoch.
    ///
    /// See [ts_recv](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#ts-recv).
    ts_recv: u64,
    /// The minimum constant tick for the instrument where every 1 unit corresponds to 1e-9, i.e.
    /// 1/1,000,000,000 or 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    min_price_increment: i64,
    /// The multiplier to convert the venue’s display price to the conventional price where every
    /// 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or 0.000000001.
    display_factor: i64,
    /// The last eligible trade time expressed as the number of nanoseconds since the
    /// UNIX epoch.
    ///
    /// Will be `UNDEF_TIMESTAMP` when null, such as for equities. Some publishers
    /// only provide date-level granularity.
    expiration: u64,
    /// The time of instrument activation expressed as the number of nanoseconds since the
    /// UNIX epoch.
    ///
    /// Will be `UNDEF_TIMESTAMP` when null, such as for equities. Some publishers
    /// only provide date-level granularity.
    activation: u64,
    /// The allowable high limit price for the trading day where every 1 unit corresponds to
    /// 1e-9, i.e. 1/1,000,000,000 or 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    high_limit_price: i64,
    /// The allowable low limit price for the trading day where every 1 unit corresponds to
    /// 1e-9, i.e. 1/1,000,000,000 or 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    low_limit_price: i64,
    /// The differential value for price banding where every 1 unit corresponds to 1e-9,
    /// i.e. 1/1,000,000,000 or 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    max_price_variation: i64,
    /// The contract size for each instrument, in combination with `unit_of_measure`, where every
    /// 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or 0.000000001.
    unit_of_measure_qty: i64,
    /// The value currently under development by the venue where every 1 unit corresponds to 1e-9,
    /// i.e. 1/1,000,000,000 or 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    min_price_increment_amount: i64,
    /// The value used for price calculation in spread and leg pricing where every 1 unit
    /// corresponds to 1e-9, i.e. 1/1,000,000,000 or 0.000000001.
    price_ratio: i64,
    /// The strike price of the option where every 1 unit corresponds to 1e-9, i.e.
    /// 1/1,000,000,000 or 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    strike_price: i64,
    /// The instrument ID assigned by the publisher. May be the same as `instrument_id`.
    ///
    /// See [Instrument identifiers](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#instrument-identifiers)
    raw_instrument_id: u64,
    /// The tied price (if any) of the leg.
    leg_price: i64,
    /// The associated delta (if any) of the leg.
    leg_delta: i64,
    /// A bitmap of instrument eligibility attributes.
    inst_attrib_value: i32,
    /// The `instrument_id` of the first underlying instrument.
    ///
    /// See [Instrument identifiers](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#instrument-identifiers)
    underlying_id: u32,
    /// The implied book depth on the price level data feed.
    market_depth_implied: i32,
    /// The (outright) book depth on the price level data feed.
    market_depth: i32,
    /// The market segment of the instrument.
    market_segment_id: u32,
    /// The maximum trading volume for the instrument.
    max_trade_vol: u32,
    /// The minimum order entry quantity for the instrument.
    min_lot_size: i32,
    /// The minimum quantity required for a block trade of the instrument.
    min_lot_size_block: i32,
    /// The minimum quantity required for a round lot of the instrument. Multiples of
    /// this quantity are also round lots.
    min_lot_size_round_lot: i32,
    /// The minimum trading volume for the instrument.
    min_trade_vol: u32,
    /// The number of deliverables per instrument, i.e. peak days.
    contract_multiplier: i32,
    /// The quantity that a contract will decay daily, after `decay_start_date` has
    /// been reached.
    decay_quantity: i32,
    /// The fixed contract value assigned to each instrument.
    original_contract_size: i32,
    /// The numeric ID assigned to the leg instrument.
    ///
    /// See [Instrument identifiers](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#instrument-identifiers)
    leg_instrument_id: u32,
    /// The numerator of the price ratio of the leg within the spread.
    leg_ratio_price_numerator: i32,
    /// The denominator of the price ratio of the leg within the spread.
    leg_ratio_price_denominator: i32,
    /// The numerator of the quantity ratio of the leg within the spread.
    leg_ratio_qty_numerator: i32,
    /// The denominator of the quantity ratio of the leg within the spread.
    leg_ratio_qty_denominator: i32,
    /// The numeric ID of the leg instrument's underlying instrument.
    ///
    /// See [Instrument identifiers](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#instrument-identifiers)
    leg_underlying_id: u32,
    /// The channel ID assigned at the venue.
    appl_id: i16,
    /// The calendar year reflected in the instrument symbol.
    maturity_year: u16,
    /// The date at which a contract will begin to decay.
    decay_start_date: u16,
    /// The channel ID assigned by Databento as an incrementing integer starting at
    /// zero.
    channel_id: u16,
    /// The number of legs in the strategy or spread. Will be 0 for outrights.
    leg_count: u16,
    /// The 0-based index of the leg.
    leg_index: u16,
    /// The currency used for price fields.
    currency: [4]u8,
    /// The currency used for settlement, if different from `currency`.
    settl_currency: [4]u8,
    /// The strategy type of the spread.
    secsubtype: [6]u8,
    /// The instrument raw symbol assigned by the publisher.
    raw_symbol: [SYMBOL_CSTR_LEN]u8,
    /// The security group code of the instrument.
    group: [21]u8,
    /// The exchange used to identify the instrument.
    exchange: [5]u8,
    /// The underlying asset code (product code) of the instrument.
    asset: [ASSET_CSTR_LEN]u8,
    /// The ISO standard instrument categorization code.
    cfi: [7]u8,
    /// The security type of the instrument, e.g. FUT for future or future spread.
    ///
    /// See [Security type](https://databento.com/docs/schemas-and-data-formats/instrument-definitions#security-type).
    security_type: [7]u8,
    /// The unit of measure for the instrument’s original contract size, e.g. USD or LBS.
    unit_of_measure: [31]u8,
    /// The symbol of the first underlying instrument.
    underlying: [21]u8,
    /// The currency of [`strike_price`](Self::strike_price).
    strike_price_currency: [4]u8,
    /// The leg instrument's raw symbol assigned by the publisher.
    leg_raw_symbol: [SYMBOL_CSTR_LEN]u8,
    /// The classification of the instrument.
    ///
    /// See [Instrument class](https://databento.com/docs/schemas-and-data-formats/instrument-definitions#instrument-class).
    instrument_class: u8,
    /// The matching algorithm used for the instrument, typically **F**IFO.
    ///
    /// See [Matching algorithm](https://databento.com/docs/schemas-and-data-formats/instrument-definitions#matching-algorithm).
    match_algorithm: u8,
    /// The price denominator of the main fraction.
    main_fraction: u8,
    /// The number of digits to the right of the tick mark, to display fractional prices.
    price_display_format: u8,
    /// The price denominator of the sub fraction.
    sub_fraction: u8,
    /// The product complex of the instrument.
    underlying_product: u8,
    /// Indicates if the instrument definition has been added, modified, or deleted.
    security_update_action: u8,
    /// The calendar month reflected in the instrument symbol.
    maturity_month: u8,
    /// The calendar day reflected in the instrument symbol, or 0.
    maturity_day: u8,
    /// The calendar week reflected in the instrument symbol, or 0.
    maturity_week: u8,
    /// Indicates if the instrument is user defined: **Y**es or **N**o.
    user_defined_instrument: u8,
    /// The type of `contract_multiplier`. Either `1` for hours, or `2` for days.
    contract_multiplier_unit: i8,
    /// The schedule for delivering electricity.
    flow_schedule_type: i8,
    /// The tick rule of the spread.
    tick_rule: u8,
    /// The classification of the leg instrument.
    leg_instrument_class: u8,
    /// The side taken for the leg when purchasing the spread.
    leg_side: u8,
    // Filler for alignment.
    _reserved: [17]u8,
};

/// A record in DBN version 3.
pub const RecordV3 = union(enum) {
    mbo: v1.MboMsg,
    trade: v1.TradeMsg,
    mbp_1: v1.Mbp1Msg,
    mbp_10: v1.Mbp10Msg,
    ohlcv: v1.OhlcvMsg,
    bbo: v1.BboMsg,
    cbbo: v1.CbboMsg,
    cmbp_1: v1.Cmbp1Msg,
    status: v1.StatusMsg,
    imbalance: v1.ImbalanceMsg,
    statistics: v2.StatisticsMsg,
    error_msg: v2.ErrorMsg,
    system: v2.SystemMsg,
    instrument_def: InstrumentDefMsg,
    symbol_mapping: v2.SymbolMappingMsg,
};

pub fn recordFromBytes(bytes: []const u8) !RecordV3 {
    const header: RecordHeader = @bitCast(bytes[0..@sizeOf(RecordHeader)].*);

    return switch (header.rtype) {
        .mbo => RecordV3{ .mbo = @bitCast(bytes[0..@sizeOf(v1.MboMsg)].*) },
        .mbp_0 => RecordV3{ .trade = @bitCast(bytes[0..@sizeOf(v1.TradeMsg)].*) },
        .mbp_1 => RecordV3{ .mbp_1 = @bitCast(bytes[0..@sizeOf(v1.Mbp1Msg)].*) },
        .mbp_10 => RecordV3{ .mbp_10 = @bitCast(bytes[0..@sizeOf(v1.Mbp10Msg)].*) },
        .ohlcv_1s, .ohlcv_1m, .ohlcv_1h, .ohlcv_1d, .ohlcv_eod => RecordV3{ .ohlcv = @bitCast(bytes[0..@sizeOf(v1.OhlcvMsg)].*) },
        .bbo_1s, .bbo_1m => RecordV3{ .bbo = @bitCast(bytes[0..@sizeOf(v1.BboMsg)].*) },
        .cbbo_1s, .cbbo_1m => RecordV3{ .cbbo = @bitCast(bytes[0..@sizeOf(v1.CbboMsg)].*) },
        .cmbp_1 => RecordV3{ .cmbp_1 = @bitCast(bytes[0..@sizeOf(v1.Cmbp1Msg)].*) },
        .status => RecordV3{ .status = @bitCast(bytes[0..@sizeOf(v1.StatusMsg)].*) },
        .imbalance => RecordV3{ .imbalance = @bitCast(bytes[0..@sizeOf(v1.ImbalanceMsg)].*) },
        .@"error" => RecordV3{ .error_msg = @bitCast(bytes[0..@sizeOf(v2.ErrorMsg)].*) },
        .system => RecordV3{ .system = @bitCast(bytes[0..@sizeOf(v2.SystemMsg)].*) },
        .statistics => RecordV3{ .statistics = @bitCast(bytes[0..@sizeOf(v2.StatisticsMsg)].*) },
        .instrument_def => RecordV3{ .instrument_def = @bitCast(bytes[0..@sizeOf(InstrumentDefMsg)].*) },
        .symbol_mapping => RecordV3{ .symbol_mapping = @bitCast(bytes[0..@sizeOf(v2.SymbolMappingMsg)].*) },
        else => error.InvalidRecordType,
    };
}
