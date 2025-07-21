const std = @import("std");
const dbn = @import("dbn");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Get API key from environment variable
    const api_key = try std.process.getEnvVarOwned(allocator, "DATABENTO_API_KEY");
    defer allocator.free(api_key);

    // Initialize the client
    var client = dbn.api.Client.init(allocator, api_key);
    defer client.deinit();

    // Make a request
    std.debug.print("listSchemas()\n", .{});
    const list = try client.listSchemas(.{ .dataset = "GLBX.MDP3" });
    defer list.deinit();
    for (list.value) |item| {
        std.debug.print("  {s}\n", .{item});
    }

    // Make another request
    std.debug.print("securityMasterGetLast()\n", .{});
    var iter = try client.securityMasterGetLast(.{
        .symbols = &.{"AAPL"},
        .stype_in = .raw_symbol,
        .countries = &.{"US"},
    });
    defer iter.deinit();

    var buffer: [4096]u8 = undefined;
    var stdout = std.fs.File.stdout().writerStreaming(&buffer);
    const writer = &stdout.interface;

    // Print the results
    try writer.print("Security Master data for AAPL:\n", .{});
    try writer.print("=====================================\n", .{});

    while (try iter.next()) |security| {
        try writer.print("Symbol: {s}\n", .{security.symbol});
        try writer.print("Issuer Name: {s}\n", .{security.issuer_name});
        try writer.print("Security Type: {s}\n", .{security.security_type});
        try writer.print("Security Description: {s}\n", .{security.security_description});
        try writer.print("Primary Exchange: {s}\n", .{security.primary_exchange});
        try writer.print("ISIN: {s}\n", .{security.isin});
        try writer.print("Trading Currency: {s}\n", .{security.trading_currency});
        try writer.print("Listing Date: {s}\n", .{security.listing_date});
        if (security.shares_outstanding) |shares| {
            try writer.print("Shares Outstanding: {d:.0}\n", .{shares});
        }
        if (security.shares_outstanding_date) |date| {
            try writer.print("Shares Outstanding Date: {s}\n", .{date});
        }
        try writer.print("=====================================\n", .{});
    }

    try writer.flush();
}
