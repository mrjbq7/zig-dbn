const std = @import("std");

pub const ALL_SYMBOLS = "ALL_SYMBOLS";

pub fn getHostName(allocator: std.mem.Allocator, code: []const u8) ![]u8 {
    var hostname: std.ArrayList(u8) = try .initCapacity(allocator, code.len + 20);
    defer hostname.deinit(allocator);

    // Convert to lowercase and replace periods with dashes
    for (code) |c| {
        if (c == '.') {
            try hostname.append(allocator, '-');
        } else {
            try hostname.append(allocator, std.ascii.toLower(c));
        }
    }

    // Append the domain
    try hostname.appendSlice(allocator, ".lsg.databento.com");

    return hostname.toOwnedSlice(allocator);
}

test "getHostName" {
    const allocator = std.testing.allocator;

    {
        const hostname = try getHostName(allocator, "GLBX.MDP3");
        defer allocator.free(hostname);
        try std.testing.expectEqualStrings("glbx-mdp3.lsg.databento.com", hostname);
    }

    {
        const hostname = try getHostName(allocator, "XNAS.ITCH");
        defer allocator.free(hostname);
        try std.testing.expectEqualStrings("xnas-itch.lsg.databento.com", hostname);
    }
}

// TODO: before starting a session, messages are newline delimited

// TODO: after ``start_session=1\n``, the server will start streaming data records

pub const AuthenticationRequest = struct {
    auth: []const u8,
    dataset: []const u8,
    encoding: ?[]const u8 = null,
    compression: ?[]const u8 = null,
    ts_out: ?u8 = null,
    pretty_px: ?u8 = null,
    pretty_ts: ?u8 = null,
    heartbeat_interval_s: ?u32 = null,
};

pub fn writeAuthenticationRequest(writer: anytype, req: AuthenticationRequest) !void {
    // Required fields
    try writer.print("auth={s}|dataset={s}", .{ req.auth, req.dataset });

    // Optional fields
    if (req.encoding) |encoding| {
        try writer.print("|encoding={s}", .{encoding});
    }
    if (req.compression) |compression| {
        try writer.print("|compression={s}", .{compression});
    }
    if (req.ts_out) |ts_out| {
        try writer.print("|ts_out={d}", .{ts_out});
    }
    if (req.pretty_px) |pretty_px| {
        try writer.print("|pretty_px={d}", .{pretty_px});
    }
    if (req.pretty_ts) |pretty_ts| {
        try writer.print("|pretty_ts={d}", .{pretty_ts});
    }
    if (req.heartbeat_interval_s) |interval| {
        try writer.print("|heartbeat_interval_s={d}", .{interval});
    }

    // Terminate with newline
    try writer.writeByte('\n');
}

test "writeAuthenticationRequest" {
    var buffer: [256]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);
    const writer = stream.writer();

    const req = AuthenticationRequest{
        .auth = "6c476f2214fa0509607a968b7d62e3a3b605ee740f9c6d70f1bd3a34a9213f61-mNUM6",
        .dataset = "GLBX.MDP3",
        .encoding = "dbn",
        .ts_out = 0,
    };

    try writeAuthenticationRequest(writer, req);
    const result = stream.getWritten();

    try std.testing.expectEqualStrings(
        "auth=6c476f2214fa0509607a968b7d62e3a3b605ee740f9c6d70f1bd3a34a9213f61-mNUM6|dataset=GLBX.MDP3|encoding=dbn|ts_out=0\n",
        result,
    );
}

pub const SubscriptionRequest = struct {
    schema: []const u8,
    stype_in: []const u8,
    symbols: []const u8,
    start: ?union(enum) {
        timestamp: i64,
        iso8601: []const u8,
    } = null,
    snapshot: ?u8 = null,
    id: ?u32 = null,
    is_last: ?u8 = null,
};

pub fn writeSubscriptionRequest(writer: anytype, req: SubscriptionRequest) !void {
    // Required fields
    try writer.print("schema={s}|stype_in={s}|symbols={s}", .{ req.schema, req.stype_in, req.symbols });

    // Optional fields
    if (req.start) |start| {
        switch (start) {
            .timestamp => |ts| try writer.print("|start={d}", .{ts}),
            .iso8601 => |str| try writer.print("|start={s}", .{str}),
        }
    }
    if (req.snapshot) |snapshot| {
        try writer.print("|snapshot={d}", .{snapshot});
    }
    if (req.id) |id| {
        try writer.print("|id={d}", .{id});
    }
    if (req.is_last) |is_last| {
        try writer.print("|is_last={d}", .{is_last});
    }

    // Terminate with newline
    try writer.writeByte('\n');
}

test "writeSubscriptionRequest" {
    var buffer: [256]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);
    const writer = stream.writer();

    const req = SubscriptionRequest{
        .schema = "trades",
        .stype_in = "raw_symbol",
        .symbols = "SPY,QQQ",
        .start = .{ .timestamp = 1671717080706865759 },
    };

    try writeSubscriptionRequest(writer, req);
    const result = stream.getWritten();

    try std.testing.expectEqualStrings(
        "schema=trades|stype_in=raw_symbol|symbols=SPY,QQQ|start=1671717080706865759\n",
        result,
    );
}
