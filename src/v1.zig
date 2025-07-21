const std = @import("std");

const RecordHeader = @import("record.zig").RecordHeader;
const SecurityUpdateAction = @import("enums.zig").SecurityUpdateAction;
const UserDefinedInstrument = @import("enums.zig").UserDefinedInstrument;
const FlagSet = @import("flags.zig").FlagSet;
const Action = @import("enums.zig").Action;
const Side = @import("enums.zig").Side;
const RType = @import("enums.zig").RType;

pub const SYMBOL_CSTR_LEN: usize = 22;
pub const ASSET_CSTR_LEN: usize = 7;
pub const UNDEF_STAT_QUANTITY: i32 = std.math.maxInt(i64);
pub const METADATA_RESERVED_LEN: usize = 47;

/// Definition of an instrument in DBN version 1. The record of the
/// `Definition` schema.
pub const InstrumentDefMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The capture-server-received timestamp expressed as the number of nanoseconds
    /// since the UNIX epoch.
    ///
    /// See [ts_recv](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#ts-recv).
    ts_recv: u64,
    /// The minimum constant tick for the instrument in units of 1e-9, i.e.
    /// 1/1,000,000,000 or 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    min_price_increment: i64,
    /// The multiplier to convert the venue’s display price to the conventional price.
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
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    high_limit_price: i64,
    /// The allowable low limit price for the trading day in units of 1e-9, i.e.
    /// 1/1,000,000,000 or 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    low_limit_price: i64,
    /// The differential value for price banding in units of 1e-9, i.e. 1/1,000,000,000
    /// or 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    max_price_variation: i64,
    /// The trading session settlement price on `trading_reference_date`.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    trading_reference_price: i64,
    /// The contract size for each instrument, in combination with `unit_of_measure`.
    unit_of_measure_qty: i64,
    /// The value currently under development by the venue. Converted to units of 1e-9, i.e.
    /// 1/1,000,000,000 or 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    min_price_increment_amount: i64,
    /// The value used for price calculation in spread and leg pricing in units of 1e-9,
    /// i.e. 1/1,000,000,000 or 0.000000001.
    price_ratio: i64,
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
    _reserved2: [4]u8,
    /// The number of deliverables per instrument, i.e. peak days.
    contract_multiplier: i32,
    /// The quantity that a contract will decay daily, after `decay_start_date` has
    /// been reached.
    decay_quantity: i32,
    /// The fixed contract value assigned to each instrument.
    original_contract_size: i32,
    _reserved3: [4]u8,
    /// The trading session date corresponding to the settlement price in
    /// `trading_reference_price`, in number of days since the UNIX epoch.
    trading_reference_date: u16,
    /// The channel ID assigned at the venue.
    appl_id: i16,
    /// The calendar year reflected in the instrument symbol.
    maturity_year: u16,
    /// The date at which a contract will begin to decay.
    decay_start_date: u16,
    /// The channel ID assigned by Databento as an incrementing integer starting at zero.
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
    _reserved4: [2]u8,
    /// The strike price of the option. Converted to units of 1e-9, i.e. 1/1,000,000,000
    /// or 0.000000001.
    strike_price: i64,
    _reserved5: [6]u8,
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
    security_update_action: SecurityUpdateAction,
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
    _dummy: [3]u8,
};

/// An error message from the Databento Live Subscription Gateway (LSG) in DBN version
/// 1.
pub const ErrorMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The error message.
    err: [64]u8,
};

/// A symbol mapping message in DBN version 1.
pub const SymbolMappingMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The input symbol.
    stype_in_symbol: [SYMBOL_CSTR_LEN]u8,
    /// The output symbol.
    stype_out_symbol: [SYMBOL_CSTR_LEN]u8,
    // Filler for alignment.
    _dummy: [4]u8,
    /// The start of the mapping interval expressed as the number of nanoseconds since
    /// the UNIX epoch.
    start_ts: u64,
    /// The end of the mapping interval expressed as the number of nanoseconds since
    /// the UNIX epoch.
    end_ts: u64,
};

/// A non-error message from the Databento Live Subscription Gateway (LSG) in DBN
/// version 1. Also used for heartbeating.
pub const SystemMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The message from the Databento Live Subscription Gateway (LSG).
    msg: [64]u8,
};

/// A statistics message in DBN versions 1 and 2. A catchall for various data
/// disseminated by publishers. The [`stat_type`](Self::stat_type) indicates the
/// statistic contained in the message.
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
    /// The value for price statistics expressed as a signed integer where every
    /// 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or 0.000000001. Will be
    /// `UNDEF_PRICE` when unused.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices)
    price: i64,
    /// The value for non-price statistics. Will be `UNDEF_STAT_QUANTITY` when
    /// unused.
    quantity: i32,
    /// The message sequence number assigned at the venue.
    sequence: u32,
    /// The delta of `ts_recv - ts_exchange_send`, max 2 seconds.
    ts_in_delta: i32,
    /// The type of statistic value contained in the message. Refer to the
    /// `StatType` for variants.
    stat_type: u16,
    /// The channel ID assigned by Databento as an incrementing integer starting at
    /// zero.
    channel_id: u16,
    /// Indicates if the statistic is newly added (1) or deleted (2). (Deleted is only used with
    /// some stat types)
    update_action: u8,
    /// Additional flags associate with certain stat types.
    stat_flags: u8,
    // Filler for alignment
    _reserved: [6]u8,
};

/// A market-by-order (MBO) tick message. The record of the
/// `Mbo` schema.
pub const MboMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The order ID assigned at the venue.
    order_id: u64,
    /// The order price where every 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or
    /// 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    price: i64,
    /// The order quantity.
    size: u32,
    /// A bit field indicating event end, message characteristics, and data quality. See
    /// `enums::flags` for possible values.
    flags: FlagSet,
    /// The channel ID assigned by Databento as an incrementing integer starting at
    /// zero.
    channel_id: u8,
    /// The event action. Can be **A**dd, **C**ancel, **M**odify, clea**R** book, **T**rade,
    /// **F**ill, or **N**one.
    ///
    /// See [Action](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#action).
    action: Action,
    /// The side that initiates the event. Can be **A**sk for a sell order
    /// (or sell aggressor in a trade), **B**id for a buy order (or buy aggressor in a trade),
    /// or **N**one where no side is specified.
    ///
    /// See [Side](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#side).
    side: Side,
    /// The capture-server-received timestamp expressed as the number of nanoseconds
    /// since the UNIX epoch.
    ///
    /// See [ts_recv](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#ts-recv).
    ts_recv: u64,
    /// The matching-engine-sending timestamp expressed as the number of nanoseconds before
    /// `ts_recv`.
    ///
    /// See [ts_in_delta](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#ts-in-delta).
    ts_in_delta: i32,
    /// The message sequence number assigned at the venue.
    sequence: u32,
};

/// A level.
pub const BidAskPair = extern struct {
    /// The bid price where every 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or
    /// 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    bid_px: i64,
    /// The ask price where every 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or
    /// 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    ask_px: i64,
    /// The bid size.
    bid_sz: u32,
    /// The ask size.
    ask_sz: u32,
    /// The bid order count.
    bid_ct: u32,
    /// The ask order count.
    ask_ct: u32,
};

/// A price level consolidated from multiple venues.
pub const ConsolidatedBidAskPair = extern struct {
    /// The bid price where every 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or
    /// 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    bid_px: i64,
    /// The ask price where every 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or
    /// 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    ask_px: i64,
    /// The bid size.
    bid_sz: u32,
    /// The ask size.
    ask_sz: u32,
    /// The publisher ID indicating the venue containing the best bid.
    ///
    /// See [Publishers](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#publishers-datasets-and-venues).
    bid_pb: u16,
    // Reserved for later usage.
    _reserved1: u16,
    /// The publisher ID indicating the venue containing the best ask.
    ///
    /// See [Publishers](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#publishers-datasets-and-venues).
    ask_pb: u16,
    // Reserved for later usage.
    _reserved2: u16,
};

/// Market by price implementation with a book depth of 0. Equivalent to
/// MBP-0. The record of the `Trades` schema.
pub const TradeMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The order price where every 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or
    /// 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    price: i64,
    /// The order quantity.
    size: u32,
    /// The event action. Always **T**rade in the trades schema.
    ///
    /// See [Action](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#action).
    action: Action,
    /// The side that initiates the trade. Can be **A**sk for a sell aggressor in a trade,
    /// **B**id for a buy aggressor in a trade, or **N**one where no side is specified.
    ///
    /// See [Side](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#side).
    side: Side,
    /// A bit field indicating event end, message characteristics, and data quality. See
    /// `enums::flags` for possible values.
    flags: FlagSet,
    /// The book level where the update event occurred.
    depth: u8,
    /// The capture-server-received timestamp expressed as the number of nanoseconds
    /// since the UNIX epoch.
    ///
    /// See [ts_recv](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#ts-recv).
    ts_recv: u64,
    /// The matching-engine-sending timestamp expressed as the number of nanoseconds before
    /// `ts_recv`.
    ///
    /// See [ts_in_delta](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#ts-in-delta).
    ts_in_delta: i32,
    /// The message sequence number assigned at the venue.
    sequence: u32,
};

/// Market by price implementation with a known book depth of 1. The record of the
/// `Mbp1` schema.
pub const Mbp1Msg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The order price where every 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or
    /// 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    price: i64,
    /// The order quantity.
    size: u32,
    /// The event action. Can be **A**dd, **C**ancel, **M**odify, clea**R** book, or **T**rade.
    ///
    /// See [Action](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#action).
    action: Action,
    /// The side that initiates the event. Can be **A**sk for a sell order
    /// (or sell aggressor in a trade), **B**id for a buy order (or buy aggressor in a trade),
    /// or **N**one where no side is specified.
    ///
    /// See [Side](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#side).
    side: Side,
    /// A bit field indicating event end, message characteristics, and data quality. See
    /// `enums::flags` for possible values.
    flags: FlagSet,
    /// The book level where the update event occurred.
    depth: u8,
    /// The capture-server-received timestamp expressed as the number of nanoseconds
    /// since the UNIX epoch.
    ///
    /// See [ts_recv](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#ts-recv).
    ts_recv: u64,
    /// The matching-engine-sending timestamp expressed as the number of nanoseconds before
    /// `ts_recv`.
    ///
    /// See [ts_in_delta](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#ts-in-delta).
    ts_in_delta: i32,
    /// The message sequence number assigned at the venue.
    sequence: u32,
    /// The top of the order book.
    levels: [1]BidAskPair,
};

/// Market by price implementation with a known book depth of 10. The record of the
/// `Mbp10` schema.
pub const Mbp10Msg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The order price where every 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or
    /// 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    price: i64,
    /// The order quantity.
    size: u32,
    /// The event action. Can be **A**dd, **C**ancel, **M**odify, clea**R** book, or **T**rade.
    ///
    /// See [Action](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#action).
    action: Action,
    /// The side that initiates the event. Can be **A**sk for a sell order
    /// (or sell aggressor in a trade), **B**id for a buy order (or buy aggressor in a trade),
    /// or **N**one where no side is specified.
    ///
    /// See [Side](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#side).
    side: Side,
    /// A bit field indicating event end, message characteristics, and data quality. See
    /// `enums::flags` for possible values.
    flags: FlagSet,
    /// The book level where the update event occurred.
    depth: u8,
    /// The capture-server-received timestamp expressed as the number of nanoseconds
    /// since the UNIX epoch.
    ///
    /// See [ts_recv](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#ts-recv).
    ts_recv: u64,
    /// The matching-engine-sending timestamp expressed as the number of nanoseconds before
    /// `ts_recv`.
    ///
    /// See [ts_in_delta](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#ts-in-delta).
    ts_in_delta: i32,
    /// The message sequence number assigned at the venue.
    sequence: u32,
    /// The top 10 levels of the order book.
    levels: [10]BidAskPair,
};

/// Subsampled market by price with a known book depth of 1. The record of the
/// `Bbo1S` and `Bbo1M` schemas.
pub const BboMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The last trade price where every 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or
    /// 0.000000001. Will be `UNDEF_PRICE` if there was no last trade in
    /// the session.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    price: i64,
    /// The last trade quantity.
    size: u32,
    // Reserved for later usage.
    _reserved1: u8,
    /// The side that initiated the last trade. Can be **A**sk for a sell aggressor, **B**id
    /// for a buy aggressor, or **N**one where no side is specified.
    ///
    /// See [Side](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#side).
    side: Side,
    /// A bit field indicating event end, message characteristics, and data quality. See
    /// `enums::flags` for possible values.
    flags: FlagSet,
    // Reserved for later usage.
    _reserved2: u8,
    /// The end timestamp of the interval, clamped to the second/minute boundary, expressed
    /// as the number of nanoseconds since the UNIX epoch.
    ts_recv: u64,
    // Reserved for later usage.
    _reserved3: [4]u8,
    /// The sequence number assigned at the venue of the last update.
    sequence: u32,
    /// The top of the order book.
    levels: [1]BidAskPair,
};

/// Consolidated market by price implementation with a known book depth of 1. The record of the
/// `Cmbp1` schema.
pub const Cmbp1Msg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The order price where every 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or
    /// 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    price: i64,
    /// The order quantity.
    size: u32,
    /// The event action. Can be **A**dd, **C**ancel, **M**odify, clea**R** book, or
    /// **T**rade.
    ///
    /// See [Action](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#action).
    action: Action,
    /// The side that initiates the event. Can be **A**sk for a sell order
    /// (or sell aggressor in a trade), **B**id for a buy order (or buy aggressor in a trade),
    /// or **N**one where no side is specified.
    ///
    /// See [Side](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#side).
    side: Side,
    /// A bit field indicating event end, message characteristics, and data quality. See
    /// `enums::flags` for possible values.
    flags: FlagSet,
    // Reserved for future usage.
    _reserved1: [1]u8,
    /// The capture-server-received timestamp expressed as the number of nanoseconds
    /// since the UNIX epoch.
    ///
    /// See [ts_recv](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#ts-recv).
    ts_recv: u64,
    /// The matching-engine-sending timestamp expressed as the number of nanoseconds before
    /// `ts_recv`.
    ///
    /// See [ts_in_delta](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#ts-in-delta).
    ts_in_delta: i32,
    _reserved2: [4]u8,
    /// The top of the order book.
    levels: [1]ConsolidatedBidAskPair,
};

/// Subsampled consolidated market by price with a known book depth of 1. The record of the
/// `Cbbo1S` and `Cbbo1M` schemas.
pub const CbboMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The last trade price where every 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or
    /// 0.000000001. Will be `UNDEF_PRICE` if there was no last trade in
    /// the session.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    price: i64,
    /// The quantity of the last trade.
    size: u32,
    // Reserved for later usage.
    _reserved1: u8,
    /// The side that initiated the last trade. Can be **A**sk for a sell aggressor, **B**id
    /// for a buy aggressor, or **N**one where no side is specified.
    ///
    /// See [Side](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#side).
    side: Side,
    /// A bit field indicating event end, message characteristics, and data quality. See
    /// `enums::flags` for possible values.
    flags: FlagSet,
    // Reserved for later usage.
    _reserved2: u8,
    /// The end timestamp of the interval, clamped to the second/minute boundary, expressed
    /// as the number of nanoseconds since the UNIX epoch.
    ts_recv: u64,
    // Reserved for later usage.
    _reserved3: [8]u8,
    /// The top of the order book.
    levels: [1]ConsolidatedBidAskPair,
};

/// The record of the `Tbbo` schema.
pub const TbboMsg = Mbp1Msg;
/// The record of the `Bbo1S` schema.
pub const Bbo1SMsg = BboMsg;
/// The record of the `Bbo1M` schema.
pub const Bbo1MMsg = BboMsg;

/// The record of the `Tcbbo` schema.
pub const TcbboMsg = Cmbp1Msg;
/// The record of the `Cbbo1S` schema.
pub const Cbbo1SMsg = CbboMsg;
/// The record of the `Cbbo1M` schema.
pub const Cbbo1MMsg = CbboMsg;

/// Open, high, low, close, and volume. The record of the following schemas:
/// - `Ohlcv1S`
/// - `Ohlcv1M`
/// - `Ohlcv1H`
/// - `Ohlcv1D`
/// - `OhlcvEod`
pub const OhlcvMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The open price for the bar where every 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or
    /// 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    open: i64,
    /// The high price for the bar where every 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or
    /// 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    high: i64,
    /// The low price for the bar where every 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or
    /// 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    low: i64,
    /// The close price for the bar where every 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or
    /// 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    close: i64,
    /// The total volume traded during the aggregation period.
    volume: u64,
};

/// A trading status update message. The record of the
/// `Status` schema.
pub const StatusMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The capture-server-received timestamp expressed as the number of nanoseconds
    /// since the UNIX epoch.
    ///
    /// See [ts_recv](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#ts-recv).
    ts_recv: u64,
    /// The type of status change.
    action: u16,
    /// Additional details about the cause of the status change.
    reason: u16,
    /// Further information about the status change and its effect on trading.
    trading_event: u16,
    /// The best-efforts state of trading in the instrument, either `Y`, `N` or `~`.
    is_trading: u8,
    /// The best-efforts state of quoting in the instrument, either `Y`, `N` or `~`.
    is_quoting: u8,
    /// The best-efforts state of short sell restrictions for the instrument (if applicable),
    /// either `Y`, `N`, or `~`.
    is_short_sell_restricted: u8,
    // Filler for alignment.
    _reserved: [7]u8,
};

/// An auction imbalance message.
pub const ImbalanceMsg = extern struct {
    /// The common header.
    hd: RecordHeader,
    /// The capture-server-received timestamp expressed as the number of nanoseconds
    /// since the UNIX epoch.
    ///
    /// See [ts_recv](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#ts-recv).
    ts_recv: u64,
    /// The price at which the imbalance shares are calculated, where every 1 unit corresponds
    /// to 1e-9, i.e. 1/1,000,000,000 or 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    ref_price: i64,
    /// Reserved for future use.
    auction_time: u64,
    /// The hypothetical auction-clearing price for both cross and continuous orders where every
    /// 1 unit corresponds to 1e-9, i.e. 1/1,000,000,000 or 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    cont_book_clr_price: i64,
    /// The hypothetical auction-clearing price for cross orders only where every 1 unit corresponds
    /// to 1e-9, i.e. 1/1,000,000,000 or 0.000000001.
    ///
    /// See [Prices](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#prices).
    auct_interest_clr_price: i64,
    /// Reserved for future use.
    ssr_filling_price: i64,
    /// Reserved for future use.
    ind_match_price: i64,
    /// Reserved for future use.
    upper_collar: i64,
    /// Reserved for future use.
    lower_collar: i64,
    /// The quantity of shares that are eligible to be matched at `ref_price`.
    paired_qty: u32,
    /// The quantity of shares that are not paired at `ref_price`.
    total_imbalance_qty: u32,
    /// Reserved for future use.
    market_imbalance_qty: u32,
    /// Reserved for future use.
    unpaired_qty: u32,
    /// Venue-specific character code indicating the auction type.
    auction_type: u8,
    /// The market side of the `total_imbalance_qty`. Can be **A**sk, **B**id, or **N**one.
    ///
    /// See [Side](https://databento.com/docs/standards-and-conventions/common-fields-enums-types#side).
    side: u8,
    /// Reserved for future use.
    auction_status: u8,
    /// Reserved for future use.
    freeze_status: u8,
    /// Reserved for future use.
    num_extensions: u8,
    /// Reserved for future use.
    unpaired_side: u8,
    /// Venue-specific character code. For Nasdaq, contains the raw Price Variation Indicator.
    significant_imbalance: u8,
    // Filler for alignment.
    _reserved: [1]u8,
};

/// A record in DBN version 1.
pub const RecordV1 = union(enum) {
    mbo: MboMsg,
    trade: TradeMsg,
    mbp_1: Mbp1Msg,
    mbp_10: Mbp10Msg,
    ohlcv: OhlcvMsg,
    bbo: BboMsg,
    cbbo: CbboMsg,
    cmbp_1: Cmbp1Msg,
    status: StatusMsg,
    imbalance: ImbalanceMsg,
    statistics: StatisticsMsg,
    error_msg: ErrorMsg,
    system: SystemMsg,
    instrument_def: InstrumentDefMsg,
    symbol_mapping: SymbolMappingMsg,
};

pub fn recordFromBytes(bytes: []const u8) !RecordV1 {
    const header: RecordHeader = @bitCast(bytes[0..@sizeOf(RecordHeader)].*);

    return switch (header.rtype) {
        .mbo => RecordV1{ .mbo = @bitCast(bytes[0..@sizeOf(MboMsg)].*) },
        .mbp_0 => RecordV1{ .trade = @bitCast(bytes[0..@sizeOf(TradeMsg)].*) },
        .mbp_1 => RecordV1{ .mbp_1 = @bitCast(bytes[0..@sizeOf(Mbp1Msg)].*) },
        .mbp_10 => RecordV1{ .mbp_10 = @bitCast(bytes[0..@sizeOf(Mbp10Msg)].*) },
        .ohlcv_1s, .ohlcv_1m, .ohlcv_1h, .ohlcv_1d, .ohlcv_eod, .ohlcv_deprecated => RecordV1{ .ohlcv = @bitCast(bytes[0..@sizeOf(OhlcvMsg)].*) },
        .bbo_1s, .bbo_1m => RecordV1{ .bbo = @bitCast(bytes[0..@sizeOf(BboMsg)].*) },
        .cbbo_1s, .cbbo_1m => RecordV1{ .cbbo = @bitCast(bytes[0..@sizeOf(CbboMsg)].*) },
        .cmbp_1 => RecordV1{ .cmbp_1 = @bitCast(bytes[0..@sizeOf(Cmbp1Msg)].*) },
        .status => RecordV1{ .status = @bitCast(bytes[0..@sizeOf(StatusMsg)].*) },
        .imbalance => RecordV1{ .imbalance = @bitCast(bytes[0..@sizeOf(ImbalanceMsg)].*) },
        .@"error" => RecordV1{ .error_msg = @bitCast(bytes[0..@sizeOf(ErrorMsg)].*) },
        .system => RecordV1{ .system = @bitCast(bytes[0..@sizeOf(SystemMsg)].*) },
        .statistics => RecordV1{ .statistics = @bitCast(bytes[0..@sizeOf(StatisticsMsg)].*) },
        .instrument_def => RecordV1{ .instrument_def = @bitCast(bytes[0..@sizeOf(InstrumentDefMsg)].*) },
        .symbol_mapping => RecordV1{ .symbol_mapping = @bitCast(bytes[0..@sizeOf(SymbolMappingMsg)].*) },
        else => error.InvalidRecordType,
    };
}
