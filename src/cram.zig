const std = @import("std");

const BUCKET_ID_LENGTH = 5;

/// Get the response for a given challenge-response authentication mechanism (CRAM)
/// code provided by a Databento service.
///
/// A valid API key is hashed with the challenge string.
pub fn getChallengeResponse(allocator: std.mem.Allocator, challenge: []const u8, key: []const u8) ![]u8 {
    if (key.len < BUCKET_ID_LENGTH) {
        return error.InvalidKeyLength;
    }

    // Get bucket ID from last 5 characters of key
    const bucket_id = key[key.len - BUCKET_ID_LENGTH ..];

    // Create the string to hash: challenge|key
    const hash_input = try std.fmt.allocPrint(allocator, "{s}|{s}", .{ challenge, key });
    defer allocator.free(hash_input);

    // Compute SHA256 hash
    var hash: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(hash_input, &hash, .{});

    // Convert hash to hex string
    var hex_hash: [std.crypto.hash.sha2.Sha256.digest_length * 2]u8 = undefined;
    _ = std.fmt.bufPrint(&hex_hash, "{x}", .{&hash}) catch unreachable;

    // Format final response: sha-bucket_id
    return std.fmt.allocPrint(allocator, "{s}-{s}", .{ hex_hash, bucket_id });
}

test "getChallengeResponse" {
    const allocator = std.testing.allocator;

    // Test case with sample data
    const challenge = "test_challenge";
    const key = "test_api_key_12345";

    const response = try getChallengeResponse(allocator, challenge, key);
    defer allocator.free(response);

    // Verify format: should be 64 hex chars + dash + 5 char bucket_id
    try std.testing.expect(response.len == 64 + 1 + 5);
    try std.testing.expect(response[64] == '-');
    try std.testing.expectEqualStrings("12345", response[65..70]);
}

test "getChallengeResponse with short key" {
    const allocator = std.testing.allocator;

    const challenge = "test";
    const key = "1234"; // Too short

    const result = getChallengeResponse(allocator, challenge, key);
    try std.testing.expectError(error.InvalidKeyLength, result);
}
