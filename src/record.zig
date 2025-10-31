const std = @import("std");
const builtin = @import("builtin");

const constants = @import("constants.zig");
const enums = @import("enums.zig");
const metadata = @import("metadata.zig");
const flags = @import("flags.zig");

const RType = enums.RType;
const Version = enums.Version;
const FlagSet = flags.FlagSet;

pub const RecordHeader = extern struct {
    length: u8,
    rtype: RType,
    publisher_id: u16,
    instrument_id: u32,
    ts_event: u64,

    comptime {
        std.debug.assert(@sizeOf(RecordHeader) == 16);
    }
};

pub const v1 = @import("v1.zig");
pub const v2 = @import("v2.zig");
pub const v3 = @import("v3.zig");

pub const Record = union(enum) {
    const Self = @This();

    v1: v1.RecordV1,
    v2: v2.RecordV2,
    v3: v3.RecordV3,

    pub fn printSvHeader(self: Self, writer: *std.Io.Writer, sep: u8) !void {
        switch (self) {
            inline else => |v| switch (v) {
                inline else => |r| {
                    const info = @typeInfo(@TypeOf(r)).@"struct";
                    inline for (info.fields, 1..) |field, i| {
                        if (i == 1) { // print the RecordHeader
                            const value = @FieldType(@TypeOf(r), field.name);
                            inline for (@typeInfo(value).@"struct".fields) |header| {
                                try writer.writeAll(header.name);
                                try writer.writeByte(sep);
                            }
                        } else {
                            try writer.writeAll(field.name);
                            try writer.writeByte(if (i < info.fields.len) sep else '\n');
                        }
                    }
                },
            },
        }
    }

    pub fn printSvRow(self: Self, writer: *std.Io.Writer, sep: u8) !void {
        switch (self) {
            inline else => |v| switch (v) {
                inline else => |r| {
                    const info = @typeInfo(@TypeOf(r)).@"struct";
                    inline for (info.fields, 1..) |field, i| {
                        const fieldType = @FieldType(@TypeOf(r), field.name);
                        const fieldValue = @field(r, field.name);
                        if (i == 1) { // print the RecordHeader
                            const headerInfo = @typeInfo(fieldType).@"struct";
                            inline for (headerInfo.fields) |header| {
                                const headerType = @FieldType(fieldType, header.name);
                                const headerValue = @field(fieldValue, header.name);
                                switch (@typeInfo(headerType)) {
                                    .int => try writer.print("{d}", .{headerValue}),
                                    .@"enum" => try writer.print("{t}", .{headerValue}),
                                    else => {
                                        if (fieldType == FlagSet) {
                                            try writer.print("{d}", .{headerValue.raw});
                                        } else {
                                            try writer.print("{any}", .{headerValue});
                                        }
                                    },
                                }
                                try writer.writeByte(sep);
                            }
                        } else {
                            switch (@typeInfo(fieldType)) {
                                .int => try writer.print("{d}", .{fieldValue}),
                                .@"enum" => try writer.print("{t}", .{fieldValue}),
                                else => {
                                    if (fieldType == FlagSet) {
                                        try writer.print("{d}", .{fieldValue.raw});
                                    } else {
                                        try writer.print("{any}", .{fieldValue});
                                    }
                                },
                            }
                            try writer.writeByte(if (i < info.fields.len) sep else '\n');
                        }
                    }
                },
            },
        }
    }

    pub fn printCsvHeader(self: Self, writer: *std.Io.Writer) !void {
        return self.printSvHeader(writer, ',');
    }

    pub fn printCsvRow(self: Self, writer: *std.Io.Writer) !void {
        return self.printSvRow(writer, ',');
    }

    pub fn printTsvHeader(self: Self, writer: *std.Io.Writer) !void {
        return self.printSvHeader(writer, '\t');
    }

    pub fn printTsvRow(self: Self, writer: *std.Io.Writer) !void {
        return self.printSvRow(writer, '\t');
    }

    pub fn printJson(self: Self, writer: *std.Io.Writer) !void {
        switch (self) {
            inline else => |v| switch (v) {
                inline else => |r| {
                    try writer.writeByte('{');
                    const info = @typeInfo(@TypeOf(r)).@"struct";
                    inline for (info.fields, 1..) |field, i| {
                        const fieldType = @FieldType(@TypeOf(r), field.name);
                        const fieldValue = @field(r, field.name);
                        try writer.writeByte('"');
                        try writer.writeAll(field.name);
                        try writer.writeAll("\":");
                        if (i == 1) { // print the RecordHeader
                            try writer.writeByte('{');
                            const fields = @typeInfo(fieldType).@"struct".fields;
                            inline for (fields, 1..) |header, j| {
                                const headerType = @FieldType(fieldType, header.name);
                                const headerValue = @field(fieldValue, header.name);
                                try writer.writeByte('"');
                                try writer.writeAll(header.name);
                                try writer.writeAll("\":");
                                switch (@typeInfo(headerType)) {
                                    .int => try writer.print("{d}", .{headerValue}),
                                    .@"enum" => try writer.print("\"{t}\"", .{headerValue}),
                                    else => {
                                        if (headerType == FlagSet) {
                                            try writer.print("{d}", .{headerValue.raw});
                                        } else {
                                            try writer.print("\"{any}\"", .{fieldValue});
                                        }
                                    },
                                }
                                if (j < fields.len) {
                                    try writer.writeByte(',');
                                }
                            }
                            try writer.writeAll("},");
                        } else {
                            switch (@typeInfo(fieldType)) {
                                .int => try writer.print("{d}", .{fieldValue}),
                                .@"enum" => try writer.print("\"{t}\"", .{fieldValue}),
                                else => {
                                    if (fieldType == FlagSet) {
                                        try writer.print("{d}", .{fieldValue.raw});
                                    } else {
                                        try writer.print("\"{any}\"", .{fieldValue});
                                    }
                                },
                            }
                            if (i < info.fields.len) {
                                try writer.writeByte(',');
                            }
                        }
                    }
                    try writer.writeAll("}\n");
                },
            },
        }
    }

    pub fn printZon(self: Self, writer: *std.Io.Writer) !void {
        switch (self) {
            inline else => |v| switch (v) {
                inline else => |r| {
                    try writer.writeAll(".{ ");
                    const info = @typeInfo(@TypeOf(r)).@"struct";
                    inline for (info.fields, 1..) |field, i| {
                        const fieldType = @FieldType(@TypeOf(r), field.name);
                        const fieldValue = @field(r, field.name);
                        try writer.writeByte('.');
                        try writer.writeAll(field.name);
                        try writer.writeAll(" = ");
                        if (i == 1) { // print the RecordHeader
                            try writer.writeAll(".{ ");
                            const fields = @typeInfo(fieldType).@"struct".fields;
                            inline for (fields, 1..) |header, j| {
                                const headerValue = @field(fieldValue, header.name);
                                try writer.writeByte('.');
                                try writer.writeAll(header.name);
                                try writer.writeAll(" = ");
                                try writer.print("{any}", .{headerValue});
                                if (j < fields.len) {
                                    try writer.writeAll(", ");
                                }
                            }
                            try writer.writeAll(" }, ");
                        } else {
                            try writer.print("{any}", .{fieldValue});
                            if (i < info.fields.len) {
                                try writer.writeAll(", ");
                            }
                        }
                    }
                    try writer.writeAll(" }\n");
                },
            },
        }
    }
};

pub fn readRecord(reader: *std.Io.Reader, version: Version) !?Record {
    // 1. read the u8 that indicates length of the record in 32-bit words
    const length_words = reader.peekByte() catch |err| switch (err) {
        error.EndOfStream => return null,
        else => return err,
    };

    // 2. compute length in bytes
    const length_bytes = @as(usize, length_words) * 4;
    if (length_bytes > 1024) {
        return error.RecordTooLarge;
    }

    // 3. read the whole record
    const buffer = try reader.take(length_bytes);

    return try recordFromBytes(version, buffer);
}

pub fn recordFromBytes(version: Version, bytes: []const u8) !Record {
    return switch (version) {
        .v1 => Record{ .v1 = try v1.recordFromBytes(bytes) },
        .v2 => Record{ .v2 = try v2.recordFromBytes(bytes) },
        .v3 => Record{ .v3 = try v3.recordFromBytes(bytes) },
    };
}

pub fn readRecords(allocator: std.mem.Allocator, reader: anytype, version: Version) ![]Record {
    var records = std.ArrayList(Record).init(allocator);
    defer records.deinit();

    while (true) {
        const record = try readRecord(reader, version) orelse break;
        try records.append(record);
    }

    return try records.toOwnedSlice();
}
