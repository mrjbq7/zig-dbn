const std = @import("std");

pub const Version = enum(u8) {
    v1 = 1,
    v2 = 2,
    v3 = 3,
};

pub const SType = enum(u8) {
    /// Symbology using a unique numeric ID.
    instrument_id = 0,
    /// Symbology using the original symbols provided by the publisher.
    raw_symbol = 1,
    /// A set of Databento-specific symbologies for referring to groups of symbols.
    /// Deprecated since 0.5.0, use `continuous` or `parent` instead.
    smart = 2,
    /// A Databento-specific symbology where one symbol may point to different
    /// instruments at different points of time, e.g. to always refer to the front month
    /// future.
    continuous = 3,
    /// A Databento-specific symbology for referring to a group of symbols by one
    /// "parent" symbol, e.g. ES.FUT to refer to all ES futures.
    parent = 4,
    /// Symbology for US equities using NASDAQ Integrated suffix conventions.
    nasdaq_symbol = 5,
    /// Symbology for US equities using CMS suffix conventions.
    cms_symbol = 6,
    /// Symbology using International Security Identification Numbers (ISIN) - ISO 6166.
    isin = 7,
    /// Symbology using US domestic Committee on Uniform Securities Identification Procedure (CUSIP) codes.
    us_code = 8,
    /// Symbology using Bloomberg composite global IDs.
    bbg_comp_id = 9,
    /// Symbology using Bloomberg composite tickers.
    bbg_comp_ticker = 10,
    /// Symbology using Bloomberg FIGI exchange level IDs.
    figi = 11,
    /// Symbology using Bloomberg exchange level tickers.
    figi_ticker = 12,
};

pub const Schema = enum(u16) {
    /// Market by order.
    mbo = 0,
    /// Market by price with a book depth of 1.
    mbp_1 = 1,
    /// Market by price with a book depth of 10.
    mbp_10 = 2,
    /// All trade events with the best bid and offer (BBO) immediately **before** the
    /// effect of the trade.
    tbbo = 3,
    /// All trade events.
    trades = 4,
    /// Open, high, low, close, and volume at a one-second interval.
    ohlcv_1s = 5,
    /// Open, high, low, close, and volume at a one-minute interval.
    ohlcv_1m = 6,
    /// Open, high, low, close, and volume at an hourly interval.
    ohlcv_1h = 7,
    /// Open, high, low, close, and volume at a daily interval based on the UTC date.
    ohlcv_1d = 8,
    /// Instrument definitions.
    definition = 9,
    /// Additional data disseminated by publishers.
    statistics = 10,
    /// Trading status events.
    status = 11,
    /// Auction imbalance events.
    imbalance = 12,
    /// Open, high, low, close, and volume at a daily cadence based on the end of the
    /// trading session.
    ohlcv_eod = 13,
    /// Consolidated best bid and offer.
    cmbp_1 = 14,
    /// Consolidated best bid and offer subsampled at one-second intervals, in addition
    /// to trades.
    cbbo_1s = 15,
    /// Consolidated best bid and offer subsampled at one-minute intervals, in addition
    /// to trades.
    cbbo_1m = 16,
    /// All trade events with the consolidated best bid and offer (CBBO) immediately
    /// **before** the effect of the trade.
    tcbbo = 17,
    /// Best bid and offer subsampled at one-second intervals, in addition to trades.
    bbo_1s = 18,
    /// Best bid and offer subsampled at one-minute intervals, in addition to trades.
    bbo_1m = 19,
};

pub const RType = enum(u8) {
    /// Denotes a market-by-price record with a book depth of 0 (used for the
    /// `Trades` schema).
    mbp_0 = 0,
    /// Denotes a market-by-price record with a book depth of 1 (also used for the
    /// `Tbbo` schema).
    mbp_1 = 0x01,
    /// Denotes a market-by-price record with a book depth of 10.
    mbp_10 = 0x0A,
    /// Denotes an open, high, low, close, and volume record at an unspecified cadence.
    /// Deprecated since 0.3.3, use `ohlcv_1s`, `ohlcv_1m`, `ohlcv_1h`, or `ohlcv_1d` instead.
    ohlcv_deprecated = 0x11,
    /// Denotes an open, high, low, close, and volume record at a 1-second cadence.
    ohlcv_1s = 0x20,
    /// Denotes an open, high, low, close, and volume record at a 1-minute cadence.
    ohlcv_1m = 0x21,
    /// Denotes an open, high, low, close, and volume record at an hourly cadence.
    ohlcv_1h = 0x22,
    /// Denotes an open, high, low, close, and volume record at a daily cadence
    /// based on the UTC date.
    ohlcv_1d = 0x23,
    /// Denotes an open, high, low, close, and volume record at a daily cadence
    /// based on the end of the trading session.
    ohlcv_eod = 0x24,
    /// Denotes an exchange status record.
    status = 0x12,
    /// Denotes an instrument definition record.
    instrument_def = 0x13,
    /// Denotes an order imbalance record.
    imbalance = 0x14,
    /// Denotes an error from gateway.
    @"error" = 0x15,
    /// Denotes a symbol mapping record.
    symbol_mapping = 0x16,
    /// Denotes a non-error message from the gateway. Also used for heartbeats.
    system = 0x17,
    /// Denotes a statistics record from the publisher (not calculated by Databento).
    statistics = 0x18,
    /// Denotes a market by order record.
    mbo = 0xA0,
    /// Denotes a consolidated best bid and offer record.
    cmbp_1 = 0xB1,
    /// Denotes a consolidated best bid and offer record subsampled on a one-second
    /// interval.
    cbbo_1s = 0xC0,
    /// Denotes a consolidated best bid and offer record subsampled on a one-minute
    /// interval.
    cbbo_1m = 0xC1,
    /// Denotes a consolidated best bid and offer trade record containing the
    /// consolidated BBO before the trade.
    tcbbo = 0xC2,
    /// Denotes a best bid and offer record subsampled on a one-second interval.
    bbo_1s = 0xC3,
    /// Denotes a best bid and offer record subsampled on a one-minute interval.
    bbo_1m = 0xC4,
};

pub const Action = enum(u8) {
    /// An existing order was modified: price and/or size.
    modify = 'M',
    /// An aggressing order traded. Does not affect the book.
    trade = 'T',
    /// An existing order was filled. Does not affect the book.
    fill = 'F',
    /// An order was fully or partially cancelled.
    cancel = 'C',
    /// A new order was added to the book.
    add = 'A',
    /// Reset the book; clear all orders for an instrument.
    clear = 'R',
    /// Has no effect on the book, but may carry `flags` or other information.
    none = 'N',
};

pub const Side = enum(u8) {
    /// A sell order or sell aggressor in a trade.
    ask = 'A',
    /// A buy order or a buy aggressor in a trade.
    bid = 'B',
    /// No side specified by the original source.
    none = 'N',
};

pub const InstrumentClass = enum(u8) {
    /// A bond.
    bond = 'B',
    /// A call option.
    call = 'C',
    /// A future.
    future = 'F',
    /// A stock.
    stock = 'K',
    /// A spread composed of multiple instrument classes.
    mixed_spread = 'M',
    /// A put option.
    put = 'P',
    /// A spread composed of futures.
    future_spread = 'S',
    /// A spread composed of options.
    option_spread = 'T',
    /// A foreign exchange spot.
    fx_spot = 'X',
    /// A commodity being traded for immediate delivery.
    commodity_spot = 'Y',
};

pub const MatchAlgorithm = enum(u8) {
    /// No matching algorithm was specified.
    undefined = ' ',
    /// First-in-first-out matching.
    fifo = 'F',
    /// A configurable match algorithm.
    configurable = 'K',
    /// Trade quantity is allocated to resting orders based on a pro-rata percentage:
    /// resting order quantity divided by total quantity.
    pro_rata = 'C',
    /// Like `Fifo` but with LMM allocations prior to FIFO allocations.
    fifo_lmm = 'T',
    /// Like `ProRata` but includes a configurable allocation to the first order that
    /// improves the market.
    threshold_pro_rata = 'O',
    /// Like `FifoLmm` but includes a configurable allocation to the first order that
    /// improves the market.
    fifo_top_lmm = 'S',
    /// Like `ThresholdProRata` but includes a special priority to LMMs.
    threshold_pro_rata_lmm = 'Q',
    /// Special variant used only for Eurodollar futures on CME.
    eurodollar_futures = 'Y',
    /// Trade quantity is shared between all orders at the best price. Orders with the
    /// highest time priority receive a higher matched quantity.
    time_pro_rata = 'P',
    /// A two-pass FIFO algorithm. The first pass fills the Institutional Group the aggressing
    /// order is associated with. The second pass matches orders without an Institutional Group
    /// association. See [CME documentation](https://cmegroupclientsite.atlassian.net/wiki/spaces/EPICSANDBOX/pages/457217267#InstitutionalPrioritizationMatchAlgorithm).
    institutional_prioritization = 'V',
};

pub const UserDefinedInstrument = enum(u8) {
    /// The instrument is not user-defined.
    no = 'N',
    /// The instrument is user-defined.
    yes = 'Y',
};

pub const Encoding = enum(u8) {
    /// Databento Binary Encoding.
    dbn = 0,
    /// Comma-separated values.
    csv = 1,
    /// JavaScript object notation.
    json = 2,
};

pub const Compression = enum(u8) {
    /// Uncompressed.
    none = 0,
    /// Zstandard compressed.
    zstd = 1,
};

pub const SecurityUpdateAction = enum(u8) {
    /// A new instrument definition.
    add = 'A',
    /// A modified instrument definition of an existing one.
    modify = 'M',
    /// Removal of an instrument definition.
    delete = 'D',
    /// Invalid action.
    invalid = '~',
};

pub const StatusAction = enum(u16) {
    /// No change.
    none = 0,
    /// The instrument is in a pre-open period.
    pre_open = 1,
    /// The instrument is in a pre-cross period.
    pre_cross = 2,
    /// The instrument is quoting but not trading.
    quoting = 3,
    /// The instrument is in a cross/auction.
    cross = 4,
    /// The instrument is being opened through a trading rotation.
    rotation = 5,
    /// A new price indication is available for the instrument.
    new_price_indication = 6,
    /// The instrument is trading.
    trading = 7,
    /// Trading in the instrument has been halted.
    halt = 8,
    /// Trading in the instrument has been paused.
    pause = 9,
    /// Trading in the instrument has been suspended.
    @"suspend" = 10,
    /// The instrument is in a pre-close period.
    pre_close = 11,
    /// Trading in the instrument has closed.
    close = 12,
    /// The instrument is in a post-close period.
    post_close = 13,
    /// A change in short-selling restrictions.
    ssr_change = 14,
    /// The instrument is not available for trading, either trading has closed or been
    /// halted.
    not_available_for_trading = 15,
};

pub const StatusReason = enum(u16) {
    /// No reason is given.
    none = 0,
    /// The change in status occurred as scheduled.
    scheduled = 1,
    /// The instrument stopped due to a market surveillance intervention.
    surveillance_intervention = 2,
    /// The status changed due to activity in the market.
    market_event = 3,
    /// The derivative instrument began trading.
    instrument_activation = 4,
    /// The derivative instrument expired.
    instrument_expiration = 5,
    /// Recovery in progress.
    recovery_in_process = 6,
    /// The status change was caused by a regulatory action.
    regulatory = 10,
    /// The status change was caused by an administrative action.
    administrative = 11,
    /// The status change was caused by the issuer not being compliance with regulatory
    /// requirements.
    non_compliance = 12,
    /// Trading halted because the issuer's filings are not current.
    filings_not_current = 13,
    /// Trading halted due to an SEC trading suspension.
    sec_trading_suspension = 14,
    /// The status changed because a new issue is available.
    new_issue = 15,
    /// The status changed because an issue is available.
    issue_available = 16,
    /// The status changed because the issue(s) were reviewed.
    issues_reviewed = 17,
    /// The status changed because the filing requirements were satisfied.
    filing_reqs_satisfied = 18,
    /// Relevant news is pending.
    news_pending = 30,
    /// Relevant news was released.
    news_released = 31,
    /// The news has been fully disseminated and times are available for the resumption
    /// in quoting and trading.
    news_and_resumption_times = 32,
    /// The relevant news was not forthcoming.
    news_not_forthcoming = 33,
    /// Halted for order imbalance.
    order_imbalance = 40,
    /// The instrument hit limit up or limit down.
    luld_pause = 50,
    /// An operational issue occurred with the venue.
    operational = 60,
    /// The status changed until the exchange receives additional information.
    additional_information_requested = 70,
    /// Trading halted due to merger becoming effective.
    merger_effective = 80,
    /// Trading is halted in an ETF due to conditions with the component securities.
    etf = 90,
    /// Trading is halted for a corporate action.
    corporate_action = 100,
    /// Trading is halted because the instrument is a new offering.
    new_security_offering = 110,
    /// Halted due to the market-wide circuit breaker level 1.
    market_wide_halt_level_1 = 120,
    /// Halted due to the market-wide circuit breaker level 2.
    market_wide_halt_level_2 = 121,
    /// Halted due to the market-wide circuit breaker level 3.
    market_wide_halt_level = 122,
    /// Halted due to the carryover of a market-wide circuit breaker from the previous
    /// trading day.
    market_wide_halt_carryover = 123,
    /// Resumption due to the end of a market-wide circuit breaker halt.
    market_wide_halt_resumption = 124,
    /// Halted because quotation is not available.
    quotation_not_available = 130,
};

pub const TradingEvent = enum(u16) {
    /// No additional information given.
    none = 0,
    /// Order entry and modification are not allowed.
    no_cancel = 1,
    /// A change of trading session occurred. Daily statistics are reset.
    change_trading_session = 2,
    /// Implied matching is available.
    implied_matching_on = 3,
    /// Implied matching is not available.
    implied_matching_off = 4,
};

pub const TriState = enum(u8) {
    /// The value is not applicable or not known.
    not_available = '~',
    /// False
    no = 'N',
    /// True
    yes = 'Y',
};

pub const StatType = enum(u8) {
    /// The price of the first trade of an instrument. `price` will be set.
    /// `quantity` will be set when provided by the venue.
    opening_price = 1,
    /// The probable price of the first trade of an instrument published during pre-
    /// open. Both `price` and `quantity` will be set.
    indicative_opening_price = 2,
    /// The settlement price of an instrument. `price` will be set and `flags` indicate
    /// whether the price is final or preliminary and actual or theoretical. `ts_ref`
    /// will indicate the trading date of the settlement price.
    settlement_price = 3,
    /// The lowest trade price of an instrument during the trading session. `price` will
    /// be set.
    trading_session_low_price = 4,
    /// The highest trade price of an instrument during the trading session. `price` will
    /// be set.
    trading_session_high_price = 5,
    /// The number of contracts cleared for an instrument on the previous trading date.
    /// `quantity` will be set. `ts_ref` will indicate the trading date of the volume.
    cleared_volume = 6,
    /// The lowest offer price for an instrument during the trading session. `price`
    /// will be set.
    lowest_offer = 7,
    /// The highest bid price for an instrument during the trading session. `price`
    /// will be set.
    highest_bid = 8,
    /// The current number of outstanding contracts of an instrument. `quantity` will
    /// be set. `ts_ref` will indicate the trading date for which the open interest was
    /// calculated.
    open_interest = 9,
    /// The volume-weighted average price (VWAP) for a fixing period. `price` will be
    /// set.
    fixing_price = 10,
    /// The last trade price during a trading session. `price` will be set.
    /// `quantity` will be set when provided by the venue.
    close_price = 11,
    /// The change in price from the close price of the previous trading session to the
    /// most recent trading session. `price` will be set.
    net_change = 12,
    /// The volume-weighted average price (VWAP) during the trading session.
    /// `price` will be set to the VWAP while `quantity` will be the traded
    /// volume.
    vwap = 13,
    /// The implied volatility associated with the settlement price. `price` will be set
    /// with the standard precision.
    volatility = 14,
    /// The option delta associated with the settlement price. `price` will be set with
    /// the standard precision.
    delta = 15,
    /// The auction uncrossing price. This is used for auctions that are neither the
    /// official opening auction nor the official closing auction. `price` will be set.
    /// `quantity` will be set when provided by the venue.
    uncrossing_price = 16,
};

pub const StatUpdateAction = enum(u8) {
    /// A new statistic.
    new = 1,
    /// A removal of a statistic.
    delete = 2,
};

pub const ErrorCode = enum(u8) {
    /// The authentication step failed.
    auth_failed = 1,
    /// The user account or API key were deactivated.
    api_key_deactivated = 2,
    /// The user has exceeded their open connection limit
    connection_limit_exceeded = 3,
    /// One or more symbols failed to resolve.
    symbol_resolution_failed = 4,
    /// There was an issue with a subscription request (other than symbol resolution).
    invalid_subscription = 5,
    /// An error occurred in the gateway.
    internal_error = 6,
};

pub const SystemCode = enum(u8) {
    /// A message sent in the absence of other records to indicate the connection
    /// remains open.
    heartbeat = 0,
    /// An acknowledgement of a subscription request.
    subscription_ack = 1,
    /// The gateway has detected this session is falling behind real-time.
    slow_reader_warning = 2,
    /// Indicates a replay subscription has caught up with real-time data.
    replay_completed = 3,
};
