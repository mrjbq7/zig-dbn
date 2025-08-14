const std = @import("std");
const builtin = @import("builtin");
const enums = @import("enums.zig");

const SType = enums.SType;
const Compression = enums.Compression;

const Allocator = std.mem.Allocator;
const Parsed = std.json.Parsed;

const API_BASE_URL = "https://hist.databento.com/v0";

fn isUnreserved(c: u8) bool {
    return switch (c) {
        'A'...'Z', 'a'...'z', '0'...'9', '-', '.', '_', '~' => true,
        else => false,
    };
}

fn appendFormValue(writer: *std.io.Writer, field_name: []const u8, value: anytype, first: *bool) !void {
    const T = @TypeOf(value);

    switch (@typeInfo(T)) {
        .pointer => |ptr| if (ptr.child == u8) { // []const u8
            if (!first.*) try writer.writeByte('&');
            first.* = false;
            try writer.print("{s}=", .{field_name});
            try std.Uri.Component.percentEncode(writer, value, isUnreserved);
        } else if (ptr.size == .slice) { // []const []const u8
            for (value) |item| {
                if (!first.*) try writer.writeByte('&');
                first.* = false;
                try writer.print("{s}=", .{field_name});
                try std.Uri.Component.percentEncode(writer, item, isUnreserved);
            }
        },
        .@"enum" => {
            if (!first.*) try writer.writeByte('&');
            first.* = false;
            try writer.print("{s}={s}", .{ field_name, @tagName(value) });
        },
        .int, .comptime_int => {
            if (!first.*) try writer.writeByte('&');
            first.* = false;
            try writer.print("{s}={d}", .{ field_name, value });
        },
        .bool => {
            if (!first.*) try writer.writeByte('&');
            first.* = false;
            try writer.print("{s}={}", .{ field_name, value });
        },
        else => {},
    }
}

fn buildFormDataGeneric(comptime T: type, params: *const T, allocator: Allocator) ![]u8 {
    var writer: std.io.Writer.Allocating = .init(allocator);
    var first = true;

    inline for (std.meta.fields(T)) |field| {
        const value = @field(params, field.name);

        if (@typeInfo(field.type) == .optional) {
            if (value) |v| {
                try appendFormValue(&writer.writer, field.name, v, &first);
            }
        } else {
            try appendFormValue(&writer.writer, field.name, value, &first);
        }
    }
    return writer.toOwnedSlice();
}

pub const CorporateActionsIndex = enum {
    event_date,
    ex_date,
    ts_record,
};

pub const SecurityMasterIndex = enum {
    ts_effective,
    ts_record,
};

pub const CorporateActionsGetRangeParams = struct {
    start: []const u8,
    end: ?[]const u8 = null,
    index: ?CorporateActionsIndex = null,
    symbols: ?[]const []const u8 = null,
    stype_in: ?SType = null,
    events: ?[]const []const u8 = null,
    countries: ?[]const []const u8 = null,
    exchanges: ?[]const []const u8 = null,
    security_types: ?[]const []const u8 = null,
    compression: ?Compression = null,

    fn buildFormData(self: *const CorporateActionsGetRangeParams, allocator: Allocator) ![]u8 {
        return buildFormDataGeneric(CorporateActionsGetRangeParams, self, allocator);
    }
};

pub const DateInfo = struct {
    old_outstanding_date: ?[]const u8 = null,
    new_outstanding_date: ?[]const u8 = null,
};

pub const EventInfo = struct {
    old_shares_outstanding: ?[]const u8 = null,
    new_shares_outstanding: ?[]const u8 = null,
};

pub const AdjustmentFactorsGetRangeParams = struct {
    start: []const u8,
    end: ?[]const u8 = null,
    symbols: ?[]const []const u8 = null,
    stype_in: ?SType = null,
    countries: ?[]const []const u8 = null,
    security_types: ?[]const []const u8 = null,
    compression: ?Compression = null,

    fn buildFormData(self: *const AdjustmentFactorsGetRangeParams, allocator: Allocator) ![]u8 {
        return buildFormDataGeneric(AdjustmentFactorsGetRangeParams, self, allocator);
    }
};

pub const SecurityMasterGetLastParams = struct {
    symbols: ?[]const []const u8 = null,
    stype_in: ?SType = null,
    countries: ?[]const []const u8 = null,
    security_types: ?[]const []const u8 = null,
    compression: ?Compression = null,

    fn buildFormData(self: *const SecurityMasterGetLastParams, allocator: Allocator) ![]u8 {
        return buildFormDataGeneric(SecurityMasterGetLastParams, self, allocator);
    }
};

pub const SecurityMasterGetRangeParams = struct {
    start: []const u8,
    end: ?[]const u8 = null,
    index: ?SecurityMasterIndex = null,
    symbols: ?[]const []const u8 = null,
    stype_in: ?SType = null,
    countries: ?[]const []const u8 = null,
    security_types: ?[]const []const u8 = null,
    compression: ?Compression = null,

    fn buildFormData(self: *const SecurityMasterGetRangeParams, allocator: Allocator) ![]u8 {
        return buildFormDataGeneric(SecurityMasterGetRangeParams, self, allocator);
    }
};

pub const SecurityMaster = struct {
    ts_record: []const u8,
    ts_effective: []const u8,
    listing_id: []const u8,
    listing_group_id: []const u8,
    security_id: []const u8,
    issuer_id: []const u8,
    listing_status: []const u8,
    listing_source: []const u8,
    listing_created_date: []const u8,
    listing_date: []const u8,
    delisting_date: ?[]const u8,
    issuer_name: []const u8,
    security_type: []const u8,
    security_description: []const u8,
    primary_exchange: []const u8,
    exchange: []const u8,
    operating_mic: []const u8,
    symbol: []const u8,
    nasdaq_symbol: []const u8,
    local_code: []const u8,
    isin: []const u8,
    us_code: []const u8,
    bbg_comp_id: []const u8,
    bbg_comp_ticker: []const u8,
    figi: []const u8,
    figi_ticker: []const u8,
    fisn: ?[]const u8,
    lei: []const u8,
    sic: []const u8,
    cik: []const u8,
    gics: ?[]const u8,
    naics: []const u8,
    cic: []const u8,
    cfi: []const u8,
    incorporation_country: []const u8,
    listing_country: []const u8,
    register_country: []const u8,
    trading_currency: []const u8,
    multi_currency: bool,
    segment_mic_name: []const u8,
    segment_mic: []const u8,
    structure: ?[]const u8,
    lot_size: ?f64,
    par_value: ?f64,
    par_value_currency: ?[]const u8,
    voting: []const u8,
    vote_per_sec: ?f64,
    shares_outstanding: ?f64,
    shares_outstanding_date: ?[]const u8,
    ts_created: []const u8,
};

pub const AdjustmentFactor = struct {
    security_id: []const u8,
    event_id: []const u8,
    event: []const u8,
    issuer_name: []const u8,
    security_type: []const u8,
    primary_exchange: []const u8,
    exchange: ?[]const u8,
    operating_mic: []const u8,
    symbol: []const u8,
    nasdaq_symbol: []const u8,
    local_code: []const u8,
    local_code_resulting: ?[]const u8,
    isin: []const u8,
    isin_resulting: ?[]const u8,
    us_code: []const u8,
    status: []const u8,
    ex_date: []const u8,
    factor: f64,
    close: f64,
    currency: []const u8,
    sentiment: f64,
    reason: i32,
    gross_dividend: ?f64,
    dividend_currency: ?[]const u8,
    frequency: ?[]const u8,
    option: ?i32,
    detail: []const u8,
    ts_created: []const u8,
};

pub const CorporateAction = struct {
    ts_record: []const u8,
    event_unique_id: []const u8,
    event_id: []const u8,
    listing_id: []const u8,
    listing_group_id: []const u8,
    security_id: []const u8,
    issuer_id: []const u8,
    event_action: []const u8,
    event: []const u8,
    event_subtype: ?[]const u8,
    event_date_label: []const u8,
    event_date: []const u8,
    event_created_date: []const u8,
    effective_date: ?[]const u8,
    ex_date: ?[]const u8,
    record_date: ?[]const u8,
    record_date_id: ?[]const u8,
    related_event: ?[]const u8,
    related_event_id: ?[]const u8,
    global_status: []const u8,
    listing_status: []const u8,
    listing_source: []const u8,
    listing_date: []const u8,
    delisting_date: ?[]const u8,
    issuer_name: []const u8,
    security_type: []const u8,
    security_description: []const u8,
    primary_exchange: []const u8,
    exchange: []const u8,
    operating_mic: []const u8,
    symbol: []const u8,
    nasdaq_symbol: []const u8,
    local_code: []const u8,
    isin: []const u8,
    us_code: []const u8,
    bbg_comp_id: []const u8,
    bbg_comp_ticker: []const u8,
    figi: []const u8,
    figi_ticker: []const u8,
    listing_country: []const u8,
    register_country: []const u8,
    trading_currency: []const u8,
    multi_currency: bool,
    segment_mic_name: []const u8,
    segment_mic: []const u8,
    mand_volu_flag: []const u8,
    rd_priority: ?[]const u8,
    lot_size: ?f64,
    par_value: ?f64,
    par_value_currency: ?[]const u8,
    payment_date: ?[]const u8,
    duebills_redemption_date: ?[]const u8,
    from_date: ?[]const u8,
    to_date: ?[]const u8,
    registration_date: ?[]const u8,
    start_date: ?[]const u8,
    end_date: ?[]const u8,
    open_date: ?[]const u8,
    close_date: ?[]const u8,
    start_subscription_date: ?[]const u8,
    end_subscription_date: ?[]const u8,
    option_election_date: ?[]const u8,
    withdrawal_rights_from_date: ?[]const u8,
    withdrawal_rights_to_date: ?[]const u8,
    notification_date: ?[]const u8,
    financial_year_end_date: ?[]const u8,
    exp_completion_date: ?[]const u8,
    payment_type: ?[]const u8,
    option_id: ?[]const u8,
    serial_id: ?[]const u8,
    default_option_flag: bool,
    rate_currency: ?[]const u8,
    ratio_old: ?f64,
    ratio_new: ?f64,
    fraction: ?f64,
    outturn_style: ?[]const u8,
    outturn_security_type: ?[]const u8,
    outturn_security_id: ?[]const u8,
    outturn_isin: ?[]const u8,
    outturn_us_code: ?[]const u8,
    outturn_local_code: ?[]const u8,
    outturn_bbg_comp_id: ?[]const u8,
    outturn_bbg_comp_ticker: ?[]const u8,
    outturn_figi: ?[]const u8,
    outturn_figi_ticker: ?[]const u8,
    min_offer_qty: ?f64,
    max_offer_qty: ?f64,
    min_qualify_qty: ?f64,
    max_qualify_qty: ?f64,
    min_accept_qty: ?f64,
    max_accept_qty: ?f64,
    tender_strike_price: ?f64,
    tender_price_step: ?f64,
    option_expiry_time: ?[]const u8,
    option_expiry_tz: ?[]const u8,
    withdrawal_rights_flag: ?[]const u8,
    withdrawal_rights_expiry_time: ?[]const u8,
    withdrawal_rights_expiry_tz: ?[]const u8,
    expiry_time: ?[]const u8,
    expiry_tz: ?[]const u8,
    date_info: DateInfo,
    rate_info: std.json.Value,
    event_info: EventInfo,
    ts_created: []const u8,
};

pub const PublisherDetail = struct {
    publisher_id: u32,
    dataset: []const u8,
    venue: []const u8,
    description: []const u8,
};

pub const ListDatasetsParams = struct {
    start_date: ?[]const u8 = null,
    end_date: ?[]const u8 = null,

    fn buildQueryString(self: *const ListDatasetsParams, allocator: Allocator) ![]u8 {
        var query: std.Io.Writer.Allocating = .init(allocator);
        var writer = &query.writer;

        var first = true;

        if (self.start_date) |start_date| {
            try writer.writeByte('?');
            try writer.print("start_date={s}", .{start_date});
            first = false;
        }

        if (self.end_date) |end_date| {
            if (first) {
                try writer.writeByte('?');
            } else {
                try writer.writeByte('&');
            }
            try writer.print("end_date={s}", .{end_date});
        }

        return query.toOwnedSlice();
    }
};

pub const ListSchemasParams = struct {
    dataset: []const u8,

    fn buildQueryString(self: *const ListSchemasParams, allocator: Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator, "?dataset={s}", .{self.dataset});
    }
};

pub const UnitPrice = struct {
    mode: []const u8,
    unit_prices: std.json.Value,
};

pub const ListUnitPricesParams = struct {
    dataset: []const u8,

    fn buildQueryString(self: *const ListUnitPricesParams, allocator: Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator, "?dataset={s}", .{self.dataset});
    }
};

pub const DatasetCondition = struct {
    date: []const u8,
    condition: []const u8,
    last_modified_date: []const u8,
};

pub const GetDatasetConditionParams = struct {
    dataset: []const u8,
    start_date: ?[]const u8 = null,
    end_date: ?[]const u8 = null,

    fn buildQueryString(self: *const GetDatasetConditionParams, allocator: Allocator) ![]u8 {
        var query: std.Io.Writer.Allocating = .init(allocator);
        var writer = &query.writer;

        try writer.print("?dataset={s}", .{self.dataset});

        if (self.start_date) |start_date| {
            try writer.print("&start_date={s}", .{start_date});
        }

        if (self.end_date) |end_date| {
            try writer.print("&end_date={s}", .{end_date});
        }

        return query.toOwnedSlice();
    }
};

pub const SchemaRange = struct {
    start: []const u8,
    end: []const u8,
};

pub const DatasetRange = struct {
    start: []const u8,
    end: []const u8,
    schema: std.json.Value,
};

pub const GetDatasetRangeParams = struct {
    dataset: []const u8,

    fn buildQueryString(self: *const GetDatasetRangeParams, allocator: Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator, "?dataset={s}", .{self.dataset});
    }
};

pub const GetRecordCountParams = struct {
    dataset: []const u8,
    symbols: ?[]const []const u8 = null,
    schema: ?[]const u8 = null,
    start: []const u8,
    end: ?[]const u8 = null,
    stype_in: ?SType = null,
    limit: ?u64 = null,

    fn buildQueryString(self: *const GetRecordCountParams, allocator: Allocator) ![]u8 {
        var query: std.Io.Writer.Allocating = .init(allocator);
        var writer = &query.writer;

        try writer.print("?dataset={s}", .{self.dataset});

        if (self.symbols) |symbols| {
            for (symbols) |symbol| {
                try writer.print("&symbols={s}", .{symbol});
            }
        }

        if (self.schema) |schema| {
            try writer.print("&schema={s}", .{schema});
        }

        try writer.print("&start={s}", .{self.start});

        if (self.end) |end| {
            try writer.print("&end={s}", .{end});
        }

        if (self.stype_in) |stype_in| {
            try writer.print("&stype_in={s}", .{@tagName(stype_in)});
        }

        if (self.limit) |limit| {
            try writer.print("&limit={}", .{limit});
        }

        return query.toOwnedSlice();
    }
};

// GetBillableSizeParams has the same structure as GetRecordCountParams
pub const GetBillableSizeParams = GetRecordCountParams;

pub const GetCostParams = struct {
    dataset: []const u8,
    symbols: ?[]const []const u8 = null,
    schema: ?[]const u8 = null,
    start: []const u8,
    end: ?[]const u8 = null,
    mode: ?[]const u8 = null,
    stype_in: ?SType = null,
    limit: ?u64 = null,

    fn buildQueryString(self: *const GetCostParams, allocator: Allocator) ![]u8 {
        var query: std.Io.Writer.Allocating = .init(allocator);
        var writer = &query.writer;

        try writer.print("?dataset={s}", .{self.dataset});

        if (self.symbols) |symbols| {
            for (symbols) |symbol| {
                try writer.print("&symbols={s}", .{symbol});
            }
        }

        if (self.schema) |schema| {
            try writer.print("&schema={s}", .{schema});
        }

        try writer.print("&start={s}", .{self.start});

        if (self.end) |end| {
            try writer.print("&end={s}", .{end});
        }

        if (self.mode) |mode| {
            try writer.print("&mode={s}", .{mode});
        }

        if (self.stype_in) |stype_in| {
            try writer.print("&stype_in={s}", .{@tagName(stype_in)});
        }

        if (self.limit) |limit| {
            try writer.print("&limit={}", .{limit});
        }

        return query.toOwnedSlice();
    }
};

pub const TimeseriesGetRangeParams = struct {
    dataset: []const u8,
    start: []const u8,
    end: ?[]const u8 = null,
    symbols: ?[]const []const u8 = null,
    schema: ?[]const u8 = null,
    encoding: ?[]const u8 = null,
    compression: ?Compression = null,
    stype_in: ?SType = null,
    stype_out: ?SType = null,
    limit: ?u64 = null,
    pretty_px: ?bool = null,
    pretty_ts: ?bool = null,
    map_symbols: ?bool = null,

    fn buildFormData(self: *const TimeseriesGetRangeParams, allocator: Allocator) ![]u8 {
        return buildFormDataGeneric(TimeseriesGetRangeParams, self, allocator);
    }
};

pub const SymbologyResolveParams = struct {
    dataset: []const u8,
    symbols: []const []const u8,
    stype_in: SType,
    stype_out: SType,
    start_date: []const u8,
    end_date: ?[]const u8 = null,

    fn buildFormData(self: *const SymbologyResolveParams, allocator: Allocator) ![]u8 {
        return buildFormDataGeneric(SymbologyResolveParams, self, allocator);
    }
};

pub const SymbolResolution = struct {
    d0: []const u8,
    d1: []const u8,
    s: []const u8,
};

pub const SymbologyResolveResponse = struct {
    result: std.json.Value,
    symbols: [][]const u8,
    stype_in: []const u8,
    stype_out: []const u8,
    start_date: []const u8,
    end_date: []const u8,
    partial: [][]const u8,
    not_found: [][]const u8,
    message: []const u8,
    status: i32,
};

pub const BatchSubmitJobParams = struct {
    dataset: []const u8,
    start: []const u8,
    end: ?[]const u8 = null,
    symbols: ?[]const []const u8 = null,
    schema: []const u8,
    encoding: []const u8,
    compression: ?Compression = null,
    stype_in: ?SType = null,
    stype_out: ?SType = null,
    limit: ?u64 = null,
    pretty_px: ?bool = null,
    pretty_ts: ?bool = null,
    map_symbols: ?bool = null,
    split_symbols: ?bool = null,
    split_duration: ?[]const u8 = null,
    split_size: ?u64 = null,
    delivery: ?[]const u8 = null,

    fn buildFormData(self: *const BatchSubmitJobParams, allocator: Allocator) ![]u8 {
        return buildFormDataGeneric(BatchSubmitJobParams, self, allocator);
    }
};

pub const BatchJob = struct {
    id: []const u8,
    user_id: []const u8,
    api_key: ?[]const u8,
    bill_id: ?[]const u8,
    cost_usd: ?f64,
    dataset: []const u8,
    symbols: []const u8,
    stype_in: []const u8,
    stype_out: []const u8,
    schema: []const u8,
    start: []const u8,
    end: []const u8,
    limit: ?u64,
    encoding: []const u8,
    compression: []const u8,
    pretty_px: bool,
    pretty_ts: bool,
    map_symbols: bool,
    split_symbols: bool,
    split_duration: []const u8,
    split_size: ?u64,
    packaging: ?[]const u8,
    delivery: []const u8,
    record_count: ?u64,
    billed_size: ?u64,
    actual_size: ?u64,
    package_size: ?u64,
    state: []const u8,
    ts_received: []const u8,
    ts_queued: ?[]const u8,
    ts_process_start: ?[]const u8,
    ts_process_done: ?[]const u8,
    ts_expiration: ?[]const u8,
    progress: ?u8 = null,
};

pub const BatchListJobsParams = struct {
    states: ?[]const u8 = null,
    since: ?[]const u8 = null,

    fn buildQueryString(self: *const BatchListJobsParams, allocator: Allocator) ![]u8 {
        var query: std.Io.Writer.Allocating = .init(allocator);
        var writer = &query.writer;

        var first = true;

        if (self.states) |states| {
            try writer.writeByte('?');
            try writer.print("states={s}", .{states});
            first = false;
        }

        if (self.since) |since| {
            if (first) {
                try writer.writeByte('?');
            } else {
                try writer.writeByte('&');
            }
            try writer.print("since={s}", .{since});
        }

        return query.toOwnedSlice();
    }
};

pub const BatchListFilesParams = struct {
    job_id: []const u8,

    fn buildQueryString(self: *const BatchListFilesParams, allocator: Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator, "?job_id={s}", .{self.job_id});
    }
};

pub const BatchFile = struct {
    filename: []const u8,
    size: u64,
    hash: []const u8,
    urls: std.json.Value,
};

pub const BatchDownloadParams = struct {
    user_id: []const u8,
    job_id: []const u8,
    filename: []const u8,
};

pub const Client = struct {
    allocator: Allocator,
    api_key: []const u8,
    http_client: std.http.Client,

    pub fn init(allocator: Allocator, api_key: []const u8) Client {
        return .{
            .allocator = allocator,
            .api_key = api_key,
            .http_client = std.http.Client{ .allocator = allocator },
        };
    }

    pub fn deinit(self: *Client) void {
        self.http_client.deinit();
    }

    fn makeAuthenticatedRequest(
        self: *Client,
        method: std.http.Method,
        comptime endpoint: []const u8,
        form_data: ?[]const u8,
        query_string: ?[]const u8,
    ) ![]u8 {
        const base_url = API_BASE_URL ++ endpoint;
        const url = if (query_string) |qs|
            try std.fmt.allocPrint(self.allocator, "{s}{s}", .{ base_url, qs })
        else
            base_url;
        defer if (query_string != null) self.allocator.free(url);

        const uri = try std.Uri.parse(url);

        // HTTP Basic Auth: username:password format, where username is API key and password is empty
        const auth_string = try std.fmt.allocPrint(self.allocator, "{s}:", .{self.api_key});
        defer self.allocator.free(auth_string);

        const auth_base64_len = std.base64.standard.Encoder.calcSize(auth_string.len);
        const auth_base64 = try self.allocator.alloc(u8, auth_base64_len);
        defer self.allocator.free(auth_base64);
        _ = std.base64.standard.Encoder.encode(auth_base64, auth_string);

        const auth_header = try std.fmt.allocPrint(self.allocator, "Basic {s}", .{auth_base64});
        defer self.allocator.free(auth_header);

        var headers: std.http.Client.Request.Headers = .{};
        headers.authorization = .{ .override = auth_header };
        if (method == .POST and form_data != null) {
            headers.content_type = .{ .override = "application/x-www-form-urlencoded" };
        }

        var storage: std.Io.Writer.Allocating = .init(self.allocator);
        defer storage.deinit();

        const result = try self.http_client.fetch(.{
            .location = .{ .uri = uri },
            .method = method,
            .headers = headers,
            .payload = form_data,
            .response_writer = &storage.writer,
        });

        if (result.status != .ok) {
            std.debug.print("Error: {t}\n", .{result.status});
            std.debug.print("URL: {s}\n", .{url});
            if (form_data) |fd| {
                std.debug.print("Form data: {s}\n", .{fd});
            }
            return switch (result.status) {
                .unauthorized => error.Unauthorized,
                .too_many_requests => error.RateLimitExceeded,
                .internal_server_error, .bad_gateway, .service_unavailable => error.ServerError,
                else => error.HttpRequestFailed,
            };
        }

        return try storage.toOwnedSlice();
    }

    pub const CorporateActionIterator = struct {
        allocator: Allocator,
        body: []u8,
        lines: std.mem.TokenIterator(u8, .scalar),
        parsed_items: std.ArrayList(Parsed(CorporateAction)),

        pub fn deinit(self: *CorporateActionIterator) void {
            for (self.parsed_items.items) |*item| {
                item.deinit();
            }
            self.parsed_items.deinit(self.allocator);
            self.allocator.free(self.body);
        }

        pub fn next(self: *CorporateActionIterator) !?CorporateAction {
            while (self.lines.next()) |line| {
                if (line.len == 0) continue;

                const parsed = try std.json.parseFromSlice(CorporateAction, self.allocator, line, .{
                    .ignore_unknown_fields = false,
                    .allocate = .alloc_always,
                });
                try self.parsed_items.append(self.allocator, parsed);
                return parsed.value;
            }
            return null;
        }
    };

    pub fn corporateActionsGetRange(
        self: *Client,
        params: CorporateActionsGetRangeParams,
    ) !CorporateActionIterator {
        const form_data = try params.buildFormData(self.allocator);
        defer self.allocator.free(form_data);

        const body = try self.makeAuthenticatedRequest(.POST, "/corporate_actions.get_range", form_data, null);

        return CorporateActionIterator{
            .allocator = self.allocator,
            .body = body,
            .lines = std.mem.tokenizeScalar(u8, body, '\n'),
            .parsed_items = .empty,
        };
    }

    pub const AdjustmentFactorIterator = struct {
        allocator: Allocator,
        body: []u8,
        lines: std.mem.TokenIterator(u8, .scalar),
        parsed_items: std.ArrayList(Parsed(AdjustmentFactor)),

        pub fn deinit(self: *AdjustmentFactorIterator) void {
            for (self.parsed_items.items) |*item| {
                item.deinit();
            }
            self.parsed_items.deinit(self.allocator);
            self.allocator.free(self.body);
        }

        pub fn next(self: *AdjustmentFactorIterator) !?AdjustmentFactor {
            while (self.lines.next()) |line| {
                if (line.len == 0) continue;

                const parsed = try std.json.parseFromSlice(AdjustmentFactor, self.allocator, line, .{
                    .ignore_unknown_fields = false,
                    .allocate = .alloc_always,
                });
                try self.parsed_items.append(self.allocator, parsed);
                return parsed.value;
            }
            return null;
        }
    };

    pub fn adjustmentFactorsGetRange(
        self: *Client,
        params: AdjustmentFactorsGetRangeParams,
    ) !AdjustmentFactorIterator {
        const form_data = try params.buildFormData(self.allocator);
        defer self.allocator.free(form_data);

        const body = try self.makeAuthenticatedRequest(.POST, "/adjustment_factors.get_range", form_data, null);

        return AdjustmentFactorIterator{
            .allocator = self.allocator,
            .body = body,
            .lines = std.mem.tokenizeScalar(u8, body, '\n'),
            .parsed_items = .empty,
        };
    }

    pub const SecurityMasterIterator = struct {
        allocator: Allocator,
        body: []u8,
        lines: std.mem.TokenIterator(u8, .scalar),
        parsed_items: std.ArrayList(Parsed(SecurityMaster)),

        pub fn deinit(self: *SecurityMasterIterator) void {
            for (self.parsed_items.items) |*item| {
                item.deinit();
            }
            self.parsed_items.deinit(self.allocator);
            self.allocator.free(self.body);
        }

        pub fn next(self: *SecurityMasterIterator) !?SecurityMaster {
            while (self.lines.next()) |line| {
                if (line.len == 0) continue;

                const parsed = try std.json.parseFromSlice(SecurityMaster, self.allocator, line, .{
                    .ignore_unknown_fields = false,
                    .allocate = .alloc_always,
                });
                try self.parsed_items.append(self.allocator, parsed);
                return parsed.value;
            }
            return null;
        }
    };

    pub fn securityMasterGetLast(
        self: *Client,
        params: SecurityMasterGetLastParams,
    ) !SecurityMasterIterator {
        const form_data = try params.buildFormData(self.allocator);
        defer self.allocator.free(form_data);

        const body = try self.makeAuthenticatedRequest(.POST, "/security_master.get_last", form_data, null);

        return SecurityMasterIterator{
            .allocator = self.allocator,
            .body = body,
            .lines = std.mem.tokenizeScalar(u8, body, '\n'),
            .parsed_items = .empty,
        };
    }

    pub fn securityMasterGetRange(
        self: *Client,
        params: SecurityMasterGetRangeParams,
    ) !SecurityMasterIterator {
        const form_data = try params.buildFormData(self.allocator);
        defer self.allocator.free(form_data);

        const body = try self.makeAuthenticatedRequest(.POST, "/security_master.get_range", form_data, null);

        return SecurityMasterIterator{
            .allocator = self.allocator,
            .body = body,
            .lines = std.mem.tokenizeScalar(u8, body, '\n'),
            .parsed_items = std.ArrayList(Parsed(SecurityMaster)).init(self.allocator),
        };
    }

    pub fn listPublishers(self: *Client) !Parsed([]PublisherDetail) {
        const body = try self.makeAuthenticatedRequest(.GET, "/metadata.list_publishers", null, null);
        defer self.allocator.free(body);

        return try std.json.parseFromSlice([]PublisherDetail, self.allocator, body, .{
            .ignore_unknown_fields = true,
            .allocate = .alloc_always,
        });
    }

    pub fn listDatasets(self: *Client, params: ?ListDatasetsParams) !Parsed([][]const u8) {
        const query_string = if (params) |p| try p.buildQueryString(self.allocator) else null;
        defer if (query_string) |qs| self.allocator.free(qs);

        const body = try self.makeAuthenticatedRequest(.GET, "/metadata.list_datasets", null, query_string);
        defer self.allocator.free(body);

        return try std.json.parseFromSlice([][]const u8, self.allocator, body, .{
            .ignore_unknown_fields = true,
            .allocate = .alloc_always,
        });
    }

    pub fn listSchemas(self: *Client, params: ListSchemasParams) !Parsed([][]const u8) {
        const query_string = try params.buildQueryString(self.allocator);
        defer self.allocator.free(query_string);

        const body = try self.makeAuthenticatedRequest(.GET, "/metadata.list_schemas", null, query_string);
        defer self.allocator.free(body);

        return try std.json.parseFromSlice([][]const u8, self.allocator, body, .{
            .ignore_unknown_fields = true,
            .allocate = .alloc_always,
        });
    }

    pub fn listUnitPrices(self: *Client, params: ListUnitPricesParams) !Parsed([]UnitPrice) {
        const query_string = try params.buildQueryString(self.allocator);
        defer self.allocator.free(query_string);

        const body = try self.makeAuthenticatedRequest(.GET, "/metadata.list_unit_prices", null, query_string);
        defer self.allocator.free(body);

        return try std.json.parseFromSlice([]UnitPrice, self.allocator, body, .{
            .ignore_unknown_fields = true,
            .allocate = .alloc_always,
        });
    }

    pub fn getDatasetCondition(self: *Client, params: GetDatasetConditionParams) !Parsed([]DatasetCondition) {
        const query_string = try params.buildQueryString(self.allocator);
        defer self.allocator.free(query_string);

        const body = try self.makeAuthenticatedRequest(.GET, "/metadata.get_dataset_condition", null, query_string);
        defer self.allocator.free(body);

        return try std.json.parseFromSlice([]DatasetCondition, self.allocator, body, .{
            .ignore_unknown_fields = true,
            .allocate = .alloc_always,
        });
    }

    pub fn getDatasetRange(self: *Client, params: GetDatasetRangeParams) !Parsed(DatasetRange) {
        const query_string = try params.buildQueryString(self.allocator);
        defer self.allocator.free(query_string);

        const body = try self.makeAuthenticatedRequest(.GET, "/metadata.get_dataset_range", null, query_string);
        defer self.allocator.free(body);

        return try std.json.parseFromSlice(DatasetRange, self.allocator, body, .{
            .ignore_unknown_fields = true,
            .allocate = .alloc_always,
        });
    }

    pub fn getRecordCount(self: *Client, params: GetRecordCountParams) !u64 {
        const query_string = try params.buildQueryString(self.allocator);
        defer self.allocator.free(query_string);

        const body = try self.makeAuthenticatedRequest(.GET, "/metadata.get_record_count", null, query_string);
        defer self.allocator.free(body);

        // The response is just a plain number, so we parse it directly
        const trimmed = std.mem.trim(u8, body, " \t\r\n");
        return try std.fmt.parseInt(u64, trimmed, 10);
    }

    pub fn getBillableSize(self: *Client, params: GetBillableSizeParams) !u64 {
        const query_string = try params.buildQueryString(self.allocator);
        defer self.allocator.free(query_string);

        const body = try self.makeAuthenticatedRequest(.GET, "/metadata.get_billable_size", null, query_string);
        defer self.allocator.free(body);

        // The response is just a plain number, so we parse it directly
        const trimmed = std.mem.trim(u8, body, " \t\r\n");
        return try std.fmt.parseInt(u64, trimmed, 10);
    }

    pub fn getCost(self: *Client, params: GetCostParams) !f64 {
        const query_string = try params.buildQueryString(self.allocator);
        defer self.allocator.free(query_string);

        const body = try self.makeAuthenticatedRequest(.GET, "/metadata.get_cost", null, query_string);
        defer self.allocator.free(body);

        // The response is just a plain number, so we parse it directly
        const trimmed = std.mem.trim(u8, body, " \t\r\n");
        return try std.fmt.parseFloat(f64, trimmed);
    }

    pub fn timeseriesGetRange(self: *Client, params: TimeseriesGetRangeParams) ![]u8 {
        const form_data = try params.buildFormData(self.allocator);
        defer self.allocator.free(form_data);

        return try self.makeAuthenticatedRequest(.POST, "/timeseries.get_range", form_data);
    }

    pub fn symbologyResolve(self: *Client, params: SymbologyResolveParams) !Parsed(SymbologyResolveResponse) {
        const form_data = try params.buildFormData(self.allocator);
        defer self.allocator.free(form_data);

        const body = try self.makeAuthenticatedRequest(.POST, "/symbology.resolve", form_data);
        defer self.allocator.free(body);

        return try std.json.parseFromSlice(SymbologyResolveResponse, self.allocator, body, .{
            .ignore_unknown_fields = true,
            .allocate = .alloc_always,
        });
    }

    pub fn batchSubmitJob(self: *Client, params: BatchSubmitJobParams) !Parsed(BatchJob) {
        const form_data = try params.buildFormData(self.allocator);
        defer self.allocator.free(form_data);

        const body = try self.makeAuthenticatedRequest(.POST, "/batch.submit_job", form_data);
        defer self.allocator.free(body);

        return try std.json.parseFromSlice(BatchJob, self.allocator, body, .{
            .ignore_unknown_fields = true,
            .allocate = .alloc_always,
        });
    }

    pub fn batchListJobs(self: *Client, params: ?BatchListJobsParams) !Parsed([]BatchJob) {
        const query_string = if (params) |p| try p.buildQueryString(self.allocator) else null;
        defer if (query_string) |qs| self.allocator.free(qs);

        const body = try self.makeAuthenticatedRequest(.GET, "/batch.list_jobs", null, query_string);
        defer self.allocator.free(body);

        return try std.json.parseFromSlice([]BatchJob, self.allocator, body, .{
            .ignore_unknown_fields = true,
            .allocate = .alloc_always,
        });
    }

    pub fn batchListFiles(self: *Client, params: BatchListFilesParams) !Parsed([]BatchFile) {
        const query_string = try params.buildQueryString(self.allocator);
        defer self.allocator.free(query_string);

        const body = try self.makeAuthenticatedRequest(.GET, "/batch.list_files", null, query_string);
        defer self.allocator.free(body);

        return try std.json.parseFromSlice([]BatchFile, self.allocator, body, .{
            .ignore_unknown_fields = true,
            .allocate = .alloc_always,
        });
    }

    pub fn batchDownload(self: *Client, params: BatchDownloadParams) ![]u8 {
        // Build the full URL with path parameters
        const url = try std.fmt.allocPrint(
            self.allocator,
            "{s}/batch/download/{s}/{s}/{s}",
            .{ API_BASE_URL, params.user_id, params.job_id, params.filename },
        );
        defer self.allocator.free(url);

        const uri = try std.Uri.parse(url);

        // HTTP Basic Auth: username:password format, where username is API key and password is empty
        const auth_string = try std.fmt.allocPrint(self.allocator, "{s}:", .{self.api_key});
        defer self.allocator.free(auth_string);

        const auth_base64_len = std.base64.standard.Encoder.calcSize(auth_string.len);
        const auth_base64 = try self.allocator.alloc(u8, auth_base64_len);
        defer self.allocator.free(auth_base64);
        _ = std.base64.standard.Encoder.encode(auth_base64, auth_string);

        const auth_header = try std.fmt.allocPrint(self.allocator, "Basic {s}", .{auth_base64});
        defer self.allocator.free(auth_header);

        var headers: std.http.Client.Request.Headers = .{};
        headers.authorization = .{ .override = auth_header };

        var server_header_buffer: [1024]u8 = undefined;
        var req = try self.http_client.open(.GET, uri, .{
            .headers = headers,
            .server_header_buffer = &server_header_buffer,
        });
        defer req.deinit();

        try req.send();
        try req.finish();
        try req.wait();

        if (req.response.status != .ok) {
            std.debug.print("Error: {t}\n", .{req.response.status});
            return switch (req.response.status) {
                .unauthorized => error.Unauthorized,
                .too_many_requests => error.RateLimitExceeded,
                .internal_server_error, .bad_gateway, .service_unavailable => error.ServerError,
                else => error.HttpRequestFailed,
            };
        }

        // Return the body, caller is responsible for freeing it
        return try req.reader().readAllAlloc(self.allocator, 1024 * 1024 * 1000); // 1GB max for downloads
    }
};

test "buildFormDataCorporateActions basic" {
    const allocator = std.testing.allocator;
    const params = CorporateActionsGetRangeParams{
        .start = "2024-01",
        .symbols = &.{"AAPL"},
        .events = &.{"SHOCH"},
        .countries = &.{"US"},
    };

    const data = try params.buildFormData(allocator);
    defer allocator.free(data);

    try std.testing.expectEqualStrings("start=2024-01&symbols=AAPL&events=SHOCH&countries=US", data);
}

test "buildFormDataCorporateActions all params" {
    const allocator = std.testing.allocator;
    const params = CorporateActionsGetRangeParams{
        .start = "2024-01-01",
        .end = "2024-12-31",
        .index = .event_date,
        .symbols = &.{ "AAPL", "MSFT" },
        .stype_in = .raw_symbol,
        .events = &.{ "SHOCH", "DIVID" },
        .countries = &.{ "US", "CA" },
        .exchanges = &.{ "XNAS", "XNYS" },
        .security_types = &.{"EQS"},
        .compression = .zstd,
    };

    const data = try params.buildFormData(allocator);
    defer allocator.free(data);

    const expected = "start=2024-01-01&end=2024-12-31&index=event_date&symbols=AAPL&symbols=MSFT&stype_in=raw_symbol&events=SHOCH&events=DIVID&countries=US&countries=CA&exchanges=XNAS&exchanges=XNYS&security_types=EQS&compression=zstd";
    try std.testing.expectEqualStrings(expected, data);
}

test "buildFormDataAdjustmentFactors" {
    const allocator = std.testing.allocator;
    const params = AdjustmentFactorsGetRangeParams{
        .start = "2009",
        .end = "2010",
        .symbols = &.{"MSFT"},
        .countries = &.{"US"},
    };

    const data = try params.buildFormData(allocator);
    defer allocator.free(data);

    try std.testing.expectEqualStrings("start=2009&end=2010&symbols=MSFT&countries=US", data);
}

test "buildFormDataSecurityMaster" {
    const allocator = std.testing.allocator;
    const params = SecurityMasterGetLastParams{
        .symbols = &.{"AAPL"},
        .countries = &.{"US"},
    };

    const data = try params.buildFormData(allocator);
    defer allocator.free(data);

    try std.testing.expectEqualStrings("symbols=AAPL&countries=US", data);
}

test "buildFormDataSecurityMasterRange" {
    const allocator = std.testing.allocator;
    const params = SecurityMasterGetRangeParams{
        .start = "2024-08-01",
        .symbols = &.{"AAPL"},
        .countries = &.{"US"},
    };

    const data = try params.buildFormData(allocator);
    defer allocator.free(data);

    try std.testing.expectEqualStrings("start=2024-08-01&symbols=AAPL&countries=US", data);
}

test "ListDatasetsParams.buildQueryString with no params" {
    const allocator = std.testing.allocator;
    const params = ListDatasetsParams{};

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("", query);
}

test "ListDatasetsParams.buildQueryString with start_date only" {
    const allocator = std.testing.allocator;
    const params = ListDatasetsParams{
        .start_date = "2024-01-01",
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("?start_date=2024-01-01", query);
}

test "ListDatasetsParams.buildQueryString with end_date only" {
    const allocator = std.testing.allocator;
    const params = ListDatasetsParams{
        .end_date = "2024-12-31",
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("?end_date=2024-12-31", query);
}

test "ListDatasetsParams.buildQueryString with both dates" {
    const allocator = std.testing.allocator;
    const params = ListDatasetsParams{
        .start_date = "2024-01-01",
        .end_date = "2024-12-31",
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("?start_date=2024-01-01&end_date=2024-12-31", query);
}

test "ListSchemasParams.buildQueryString" {
    const allocator = std.testing.allocator;
    const params = ListSchemasParams{
        .dataset = "GLBX.MDP3",
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("?dataset=GLBX.MDP3", query);
}

test "ListUnitPricesParams.buildQueryString" {
    const allocator = std.testing.allocator;
    const params = ListUnitPricesParams{
        .dataset = "XNAS.ITCH",
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("?dataset=XNAS.ITCH", query);
}

test "GetDatasetConditionParams.buildQueryString with dataset only" {
    const allocator = std.testing.allocator;
    const params = GetDatasetConditionParams{
        .dataset = "XNAS.ITCH",
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("?dataset=XNAS.ITCH", query);
}

test "GetDatasetConditionParams.buildQueryString with all params" {
    const allocator = std.testing.allocator;
    const params = GetDatasetConditionParams{
        .dataset = "XNAS.ITCH",
        .start_date = "2024-01-01",
        .end_date = "2024-01-31",
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("?dataset=XNAS.ITCH&start_date=2024-01-01&end_date=2024-01-31", query);
}

test "GetDatasetRangeParams.buildQueryString" {
    const allocator = std.testing.allocator;
    const params = GetDatasetRangeParams{
        .dataset = "GLBX.MDP3",
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("?dataset=GLBX.MDP3", query);
}

test "GetRecordCountParams.buildQueryString minimal" {
    const allocator = std.testing.allocator;
    const params = GetRecordCountParams{
        .dataset = "XNAS.ITCH",
        .start = "2024-01-01",
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("?dataset=XNAS.ITCH&start=2024-01-01", query);
}

test "GetRecordCountParams.buildQueryString with symbols" {
    const allocator = std.testing.allocator;
    const params = GetRecordCountParams{
        .dataset = "XNAS.ITCH",
        .symbols = &.{ "AAPL", "MSFT", "GOOGL" },
        .start = "2024-01-01",
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("?dataset=XNAS.ITCH&symbols=AAPL&symbols=MSFT&symbols=GOOGL&start=2024-01-01", query);
}

test "GetRecordCountParams.buildQueryString all params" {
    const allocator = std.testing.allocator;
    const params = GetRecordCountParams{
        .dataset = "XNAS.ITCH",
        .symbols = &.{ "AAPL", "MSFT" },
        .schema = "mbo",
        .start = "2024-01-01",
        .end = "2024-01-31",
        .stype_in = .raw_symbol,
        .limit = 1000,
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    const expected = "?dataset=XNAS.ITCH&symbols=AAPL&symbols=MSFT&schema=mbo&start=2024-01-01&end=2024-01-31&stype_in=raw_symbol&limit=1000";
    try std.testing.expectEqualStrings(expected, query);
}

test "GetCostParams.buildQueryString minimal" {
    const allocator = std.testing.allocator;
    const params = GetCostParams{
        .dataset = "GLBX.MDP3",
        .start = "2024-01-01",
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("?dataset=GLBX.MDP3&start=2024-01-01", query);
}

test "GetCostParams.buildQueryString with mode" {
    const allocator = std.testing.allocator;
    const params = GetCostParams{
        .dataset = "GLBX.MDP3",
        .start = "2024-01-01",
        .mode = "streaming",
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("?dataset=GLBX.MDP3&start=2024-01-01&mode=streaming", query);
}

test "GetCostParams.buildQueryString all params" {
    const allocator = std.testing.allocator;
    const params = GetCostParams{
        .dataset = "GLBX.MDP3",
        .symbols = &.{ "ESH4", "CLH4" },
        .schema = "trades",
        .start = "2024-01-01T00:00:00",
        .end = "2024-01-01T23:59:59",
        .mode = "historical",
        .stype_in = .instrument_id,
        .limit = 5000,
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    const expected = "?dataset=GLBX.MDP3&symbols=ESH4&symbols=CLH4&schema=trades&start=2024-01-01T00:00:00&end=2024-01-01T23:59:59&mode=historical&stype_in=instrument_id&limit=5000";
    try std.testing.expectEqualStrings(expected, query);
}

test "BatchListJobsParams.buildQueryString empty" {
    const allocator = std.testing.allocator;
    const params = BatchListJobsParams{};

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("", query);
}

test "BatchListJobsParams.buildQueryString with states only" {
    const allocator = std.testing.allocator;
    const params = BatchListJobsParams{
        .states = "done,expired",
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("?states=done,expired", query);
}

test "BatchListJobsParams.buildQueryString with since only" {
    const allocator = std.testing.allocator;
    const params = BatchListJobsParams{
        .since = "2024-01-01T00:00:00Z",
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("?since=2024-01-01T00:00:00Z", query);
}

test "BatchListJobsParams.buildQueryString with both params" {
    const allocator = std.testing.allocator;
    const params = BatchListJobsParams{
        .states = "processing,done",
        .since = "2024-01-01T00:00:00Z",
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("?states=processing,done&since=2024-01-01T00:00:00Z", query);
}

test "BatchListFilesParams.buildQueryString" {
    const allocator = std.testing.allocator;
    const params = BatchListFilesParams{
        .job_id = "20240101-ABCD1234",
    };

    const query = try params.buildQueryString(allocator);
    defer allocator.free(query);

    try std.testing.expectEqualStrings("?job_id=20240101-ABCD1234", query);
}
