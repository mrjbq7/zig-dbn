const std = @import("std");

/// Indicates it's the last record in the event from the venue for a given
/// `instrument_id`.
pub const FLAG_LAST: u8 = 1 << 7;
/// Indicates a top-of-book record, not an individual order.
pub const FLAG_TOB: u8 = 1 << 6;
/// Indicates the record was sourced from a replay, such as a snapshot server.
pub const FLAG_SNAPSHOT: u8 = 1 << 5;
/// Indicates an aggregated price level record, not an individual order.
pub const FLAG_MBP: u8 = 1 << 4;
/// Indicates the `ts_recv` value is inaccurate due to clock issues or packet
/// reordering.
pub const FLAG_BAD_TS_RECV: u8 = 1 << 3;
/// Indicates an unrecoverable gap was detected in the channel.
pub const FLAG_MAYBE_BAD_BOOK: u8 = 1 << 2;
/// Used to indicate a publisher-specific event.
pub const FLAG_PUBLISHER_SPECIFIC: u8 = 1 << 1;

pub const FlagSet = extern struct {
    raw: u8,

    pub fn empty() FlagSet {
        return FlagSet{ .raw = 0 };
    }

    pub fn new(raw: u8) FlagSet {
        return FlagSet{ .raw = raw };
    }

    pub fn clear(self: *FlagSet) void {
        self.raw = 0;
    }

    pub fn setRaw(self: *FlagSet, raw: u8) void {
        self.raw = raw;
    }

    pub fn any(self: FlagSet) bool {
        return self.raw != 0;
    }

    pub fn isEmpty(self: FlagSet) bool {
        return self.raw == 0;
    }

    // Flag checking methods
    pub fn isLast(self: FlagSet) bool {
        return (self.raw & FLAG_LAST) > 0;
    }

    pub fn isTob(self: FlagSet) bool {
        return (self.raw & FLAG_TOB) > 0;
    }

    pub fn isSnapshot(self: FlagSet) bool {
        return (self.raw & FLAG_SNAPSHOT) > 0;
    }

    pub fn isMbp(self: FlagSet) bool {
        return (self.raw & FLAG_MBP) > 0;
    }

    pub fn isBadTsRecv(self: FlagSet) bool {
        return (self.raw & FLAG_BAD_TS_RECV) > 0;
    }

    pub fn isMaybeBadBook(self: FlagSet) bool {
        return (self.raw & FLAG_MAYBE_BAD_BOOK) > 0;
    }

    pub fn isPublisherSpecific(self: FlagSet) bool {
        return (self.raw & FLAG_PUBLISHER_SPECIFIC) > 0;
    }

    // Flag setting methods
    pub fn setLast(self: *FlagSet) void {
        self.raw |= FLAG_LAST;
    }

    pub fn setTob(self: *FlagSet) void {
        self.raw |= FLAG_TOB;
    }

    pub fn setSnapshot(self: *FlagSet) void {
        self.raw |= FLAG_SNAPSHOT;
    }

    pub fn setMbp(self: *FlagSet) void {
        self.raw |= FLAG_MBP;
    }

    pub fn setBadTsRecv(self: *FlagSet) void {
        self.raw |= FLAG_BAD_TS_RECV;
    }

    pub fn setMaybeBadBook(self: *FlagSet) void {
        self.raw |= FLAG_MAYBE_BAD_BOOK;
    }

    pub fn setPublisherSpecific(self: *FlagSet) void {
        self.raw |= FLAG_PUBLISHER_SPECIFIC;
    }

    pub fn format(
        self: FlagSet,
        writer: *std.io.Writer,
    ) !void {
        if (self.raw == 0) {
            try writer.writeAll("0");
            return;
        }

        var first = true;
        if (self.isLast()) {
            try writer.writeAll("LAST");
            first = false;
        }
        if (self.isTob()) {
            if (!first) try writer.writeAll(" | ");
            try writer.writeAll("TOB");
            first = false;
        }
        if (self.isSnapshot()) {
            if (!first) try writer.writeAll(" | ");
            try writer.writeAll("SNAPSHOT");
            first = false;
        }
        if (self.isMbp()) {
            if (!first) try writer.writeAll(" | ");
            try writer.writeAll("MBP");
            first = false;
        }
        if (self.isBadTsRecv()) {
            if (!first) try writer.writeAll(" | ");
            try writer.writeAll("BAD_TS_RECV");
            first = false;
        }
        if (self.isMaybeBadBook()) {
            if (!first) try writer.writeAll(" | ");
            try writer.writeAll("MAYBE_BAD_BOOK");
        }
        if (self.isPublisherSpecific()) {
            if (!first) try writer.writeAll(" | ");
            try writer.writeAll("PUBLISHER_SPECIFIC");
        }
        try writer.print(" ({d})", .{self.raw});
    }
};

test {
    var buffer: [64]u8 = undefined;

    var writer: std.io.Writer = .fixed(&buffer);

    const flags: FlagSet = .{ .raw = 130 };

    try writer.print("{f}", .{flags});

    try std.testing.expectEqualStrings("LAST | PUBLISHER_SPECIFIC (130)", writer.buffered());
}
