const Record = @import("record.zig").Record;
const RecordHeader = @import("record.zig").RecordHeader;
const UserDefinedInstrument = @import("enums.zig").UserDefinedInstrument;
const SType = @import("enums.zig").SType;
const RType = @import("enums.zig").RType;

const v1 = @import("v1.zig");

pub const SYMBOL_CSTR_LEN: usize = 71;
pub const ASSET_CSTR_LEN: usize = v1.ASSET_CSTR_LEN;
pub const UNDEF_STAT_QUANTITY: i32 = v1.UNDEF_STAT_QUANTITY;
pub const METADATA_RESERVED_LEN: usize = 53;

/// Definition of an instrument in DBN version 2. The record of the
/// `Definition` schema.
pub const InstrumentDefMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The capture-server-received timestamp expressed as the number of nanoseconds
    /// since the UNIX epoch.
    ts_recv: u64,
    /// The minimum constant tick for the instrument in units of 1e-9, i.e.
    /// 1/1,000,000,000 or 0.000000001.
    min_price_increment: i64,
    /// The multiplier to convert the venue’s display price to the conventional price,
    /// in units of 1e-9, i.e. 1/1,000,000,000 or 0.000000001.
    display_factor: i64,
    /// The last eligible trade time expressed as a number of nanoseconds since the
    /// UNIX epoch.
    ///
    /// Will be `UNDEF_TIMESTAMP` when null, such as for equities. Some publishers
    /// only provide date-level granularity.
    expiration: u64,
    /// The time of instrument activation expressed as a number of nanoseconds since the
    /// UNIX epoch.
    ///
    /// Will be `UNDEF_TIMESTAMP` when null, such as for equities. Some publishers
    /// only provide date-level granularity.
    activation: u64,
    /// The allowable high limit price for the trading day in units of 1e-9, i.e.
    /// 1/1,000,000,000 or 0.000000001.
    high_limit_price: i64,
    /// The allowable low limit price for the trading day in units of 1e-9, i.e.
    /// 1/1,000,000,000 or 0.000000001.
    low_limit_price: i64,
    /// The differential value for price banding in units of 1e-9, i.e. 1/1,000,000,000
    /// or 0.000000001.
    max_price_variation: i64,
    /// The trading session settlement price on `trading_reference_date`.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    trading_reference_price: i64,
    /// The contract size for each instrument, in combination with `unit_of_measure`, in units
    /// of 1e-9, i.e. 1/1,000,000,000 or 0.000000001.
    unit_of_measure_qty: i64,
    /// The value currently under development by the venue. Converted to units of 1e-9, i.e.
    /// 1/1,000,000,000 or 0.000000001.
    min_price_increment_amount: i64,
    /// The value used for price calculation in spread and leg pricing in units of 1e-9,
    /// i.e. 1/1,000,000,000 or 0.000000001.
    price_ratio: i64,
    /// The strike price of the option. Converted to units of 1e-9, i.e. 1/1,000,000,000
    /// or 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    strike_price: i64,
    /// A bitmap of instrument eligibility attributes.
    inst_attrib_value: i32,
    /// The `instrument_id` of the first underlying instrument.
    ///
    /// See [Instrument identifiers](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#instrument-identifiers)
    underlying_id: u32,
    /// The instrument ID assigned by the publisher. May be the same as `instrument_id`.
    ///
    /// See [Instrument identifiers](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#instrument-identifiers)
    raw_instrument_id: u32,
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
    /// The trading session date corresponding to the settlement price in
    /// `trading_reference_price`, in number of days since the UNIX epoch.
    trading_reference_date: u16,
    /// The channel ID assigned at the venue.
    appl_id: i16,
    /// The calendar year reflected in the instrument symbol.
    maturity_year: u16,
    /// The date at which a contract will begin to decay.
    decay_start_date: u16,
    /// The channel ID assigned by Databento as an incrementing integer starting at
    /// zero.
    channel_id: u16,
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
    asset: [7]u8,
    /// The ISO standard instrument categorization code.
    cfi: [7]u8,
    /// The [Security type](https://databento.com/docs/schemas-and-data-formats/instrument-definitions#security-type)
    /// of the instrument, e.g. FUT for future or future spread.
    security_type: [7]u8,
    /// The unit of measure for the instrument’s original contract size, e.g. USD or LBS.
    unit_of_measure: [31]u8,
    /// The symbol of the first underlying instrument.
    underlying: [21]u8,
    /// The currency of [`strike_price`](Self::strike_price).
    strike_price_currency: [4]u8,
    /// The classification of the instrument.
    instrument_class: u8,
    /// The matching algorithm used for the instrument, typically **F**IFO.
    match_algorithm: u8,
    /// The current trading state of the instrument.
    md_security_trading_status: u8,
    /// The price denominator of the main fraction.
    main_fraction: u8,
    ///  The number of digits to the right of the tick mark, to display fractional prices.
    price_display_format: u8,
    /// The type indicators for the settlement price, as a bitmap.
    settl_price_type: u8,
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
    user_defined_instrument: UserDefinedInstrument,
    /// The type of `contract_multiplier`. Either `1` for hours, or `2` for days.
    contract_multiplier_unit: i8,
    /// The schedule for delivering electricity.
    flow_schedule_type: i8,
    /// The tick rule of the spread.
    tick_rule: u8,
    // Filler for alignment.
    _reserved: [10]u8,
};

/// A statistics message. A catchall for various data disseminated by publishers. The
/// `stat_type` indicates the statistic contained in the message.
pub const StatisticsMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The capture-server-received timestamp expressed as the number of nanoseconds
    /// since the UNIX epoch.
    ///
    /// See [ts_recv](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#ts-recv).
    ts_recv: u64,
    /// The reference timestamp of the statistic value expressed as the number of
    /// nanoseconds since the UNIX epoch. Will be `UNDEF_TIMESTAMP` when
    /// unused.
    ts_ref: u64,
    /// The value for price statistics where every 1 unit corresponds to 1e-9, i.e.
    /// 1/1,000,000,000 or 0.000000001. Will be `UNDEF_PRICE`
    /// when unused.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices)
    price: i64,
    /// The value for non-price statistics. Will be `UNDEF_STAT_QUANTITY` when
    /// unused.
    quantity: i64,
    /// The message sequence number assigned at the venue.
    sequence: u32,
    /// The matching-engine-sending timestamp expressed as the number of nanoseconds
    /// before `ts_recv`.
    ///
    /// See [ts_in_delta](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#ts-in-delta).
    ts_in_delta: i32,
    /// The type of statistic value contained in the message. Refer to the
    /// `StatType` enum for possible variants.
    stat_type: u16,
    /// The channel ID assigned by Databento as an incrementing integer starting at
    /// zero.
    channel_id: u16,
    /// Indicates if the statistic is newly added (1) or deleted (2). (Deleted is only
    /// used with some stat types)
    update_action: u8,
    /// Additional flags associate with certain stat types.
    stat_flags: u8,
    // Filler for alignment
    _reserved: [18]u8,
};

/// An error message from the Databento Live Subscription Gateway (LSG).
pub const ErrorMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The error message.
    err: [302]u8,
    /// The error code. See the `ErrorCode` enum
    /// for possible values.
    code: u8,
    /// Sometimes multiple errors are sent together. This field will be non-zero for the
    /// last error.
    is_last: u8,
};

/// A symbol mapping message which maps a symbol of one `SType`
/// to another.
pub const SymbolMappingMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The input symbology type of `stype_in_symbol`.
    stype_in: SType,
    /// The input symbol.
    stype_in_symbol: [SYMBOL_CSTR_LEN]u8,
    /// The output symbology type of `stype_out_symbol`.
    stype_out: SType,
    /// The output symbol.
    stype_out_symbol: [SYMBOL_CSTR_LEN]u8,
    /// The start of the mapping interval expressed as the number of nanoseconds since
    /// the UNIX epoch.
    start_ts: u64,
    /// The end of the mapping interval expressed as the number of nanoseconds since
    /// the UNIX epoch.
    end_ts: u64,
};

/// A non-error message from the Databento Live Subscription Gateway (LSG). Also used
/// for heartbeating.
pub const SystemMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The message from the Databento Live Subscription Gateway (LSG).
    msg: [303]u8,
    /// Type of system message. See the `SystemCode` enum
    /// for possible values.
    code: u8,
};

/// A record in DBN version 2.
pub const RecordV2 = union(enum) {
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
    statistics: StatisticsMsg,
    error_msg: ErrorMsg,
    system: SystemMsg,
    instrument_def: InstrumentDefMsg,
    symbol_mapping: SymbolMappingMsg,
};

pub fn recordFromBytes(bytes: []const u8) !RecordV2 {
    const header: RecordHeader = @bitCast(bytes[0..@sizeOf(RecordHeader)].*);

    return switch (header.rtype) {
        .mbo => RecordV2{ .mbo = @bitCast(bytes[0..@sizeOf(v1.MboMsg)].*) },
        .mbp_0 => RecordV2{ .trade = @bitCast(bytes[0..@sizeOf(v1.TradeMsg)].*) },
        .mbp_1 => RecordV2{ .mbp_1 = @bitCast(bytes[0..@sizeOf(v1.Mbp1Msg)].*) },
        .mbp_10 => RecordV2{ .mbp_10 = @bitCast(bytes[0..@sizeOf(v1.Mbp10Msg)].*) },
        .ohlcv_1s, .ohlcv_1m, .ohlcv_1h, .ohlcv_1d, .ohlcv_eod => RecordV2{ .ohlcv = @bitCast(bytes[0..@sizeOf(v1.OhlcvMsg)].*) },
        .bbo_1s, .bbo_1m => RecordV2{ .bbo = @bitCast(bytes[0..@sizeOf(v1.BboMsg)].*) },
        .cbbo_1s, .cbbo_1m => RecordV2{ .cbbo = @bitCast(bytes[0..@sizeOf(v1.CbboMsg)].*) },
        .cmbp_1 => RecordV2{ .cmbp_1 = @bitCast(bytes[0..@sizeOf(v1.Cmbp1Msg)].*) },
        .status => RecordV2{ .status = @bitCast(bytes[0..@sizeOf(v1.StatusMsg)].*) },
        .imbalance => RecordV2{ .imbalance = @bitCast(bytes[0..@sizeOf(v1.ImbalanceMsg)].*) },
        .@"error" => RecordV2{ .error_msg = @bitCast(bytes[0..@sizeOf(ErrorMsg)].*) },
        .system => RecordV2{ .system = @bitCast(bytes[0..@sizeOf(SystemMsg)].*) },
        .statistics => RecordV2{ .statistics = @bitCast(bytes[0..@sizeOf(StatisticsMsg)].*) },
        .instrument_def => RecordV2{ .instrument_def = @bitCast(bytes[0..@sizeOf(InstrumentDefMsg)].*) },
        .symbol_mapping => RecordV2{ .symbol_mapping = @bitCast(bytes[0..@sizeOf(SymbolMappingMsg)].*) },
        else => error.InvalidRecordType,
    };
}
