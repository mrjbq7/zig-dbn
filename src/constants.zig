const std = @import("std");

pub const FIXED_PRICE_SCALE: i64 = 1_000_000_000;
pub const UNDEF_PRICE: i64 = std.math.maxInt(i64);
pub const UNDEF_TIMESTAMP: u64 = std.math.maxInt(u64);
