// stdlib imports
const std = @import("std");
const zstd = std.compress.zstd;

// local imports
const metadata = @import("metadata.zig");
const dbz = @import("dbz.zig");
const Record = @import("record.zig").Record;

pub const RecordIterator = struct {
    const Self = @This();

    const BufferedReader = std.io.BufferedReader(4096, std.fs.File.DeprecatedReader);

    allocator: std.mem.Allocator,
    meta: metadata.Metadata,
    file: std.fs.File,
    file_buffer: []u8,
    file_reader: std.fs.File.Reader,
    zstd_buffer: ?[]u8,
    zstd_reader: ?zstd.Decompress,
    reader: *std.Io.Reader,

    pub fn init(allocator: std.mem.Allocator, path: []const u8) !*Self {
        var self = try allocator.create(Self);
        errdefer allocator.destroy(self);

        self.allocator = allocator;

        self.file = if (std.fs.path.isAbsolute(path))
            try std.fs.openFileAbsolute(path, .{})
        else
            try std.fs.cwd().openFile(path, .{});
        errdefer self.file.close();

        self.file_buffer = try allocator.alloc(u8, 4096);
        errdefer allocator.free(self.file_buffer);
        self.file_reader = self.file.reader(self.file_buffer);
        self.reader = &self.file_reader.interface;

        self.zstd_buffer = null;
        self.zstd_reader = null;

        // Check for compressed files
        if (std.mem.endsWith(u8, path, ".zst")) {
            self.zstd_buffer = try allocator.alloc(u8, zstd.default_window_len + zstd.block_size_max);
            errdefer allocator.free(self.zstd_buffer.?);
            self.zstd_reader = zstd.Decompress.init(&self.file_reader.interface, self.zstd_buffer.?, .{});
            self.reader = &self.zstd_reader.?.reader;
        }

        // Parse DBN or DBZ metadata
        self.meta = blk: {
            if (self.zstd_reader != null) {
                break :blk try metadata.readMetadata(allocator, &self.zstd_reader.?.reader);
            } else {
                var buf: [3]u8 = undefined;
                _ = try self.file.pread(&buf, 0);
                if (std.mem.eql(u8, &buf, "DBN")) {
                    break :blk try metadata.readMetadata(allocator, &self.file_reader.interface);
                } else {
                    std.debug.assert(self.zstd_reader == null);
                    var meta = try dbz.readMetadata(allocator, &self.file_reader.interface);
                    errdefer meta.deinit();
                    self.zstd_buffer = try allocator.alloc(u8, zstd.default_window_len + zstd.block_size_max);
                    errdefer allocator.free(self.zstd_buffer.?);
                    self.zstd_reader = zstd.Decompress.init(&self.file_reader.interface, self.zstd_buffer.?, .{});
                    self.reader = &self.zstd_reader.?.reader;
                    break :blk meta;
                }
            }
        };

        return self;
    }

    pub fn deinit(self: *Self) void {
        self.file.close();
        self.meta.deinit();
        self.allocator.free(self.file_buffer);
        if (self.zstd_buffer) |buffer| {
            self.allocator.free(buffer);
        }
        self.allocator.destroy(self);
    }

    pub fn next(self: *Self) !?Record {
        return self.meta.readRecord(self.reader);
    }
};
