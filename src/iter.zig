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
    const Decompressor = zstd.Decompressor(BufferedReader);

    allocator: std.mem.Allocator,
    meta: metadata.Metadata,
    file: std.fs.File,
    file_reader: BufferedReader,
    zstd_buffer: ?[]u8,
    zstd_reader: ?*Decompressor,

    pub fn init(allocator: std.mem.Allocator, path: []const u8) !Self {
        const file = if (std.fs.path.isAbsolute(path))
            try std.fs.openFileAbsolute(path, .{})
        else
            try std.fs.cwd().openFile(path, .{});

        var file_reader = std.io.bufferedReader(file.deprecatedReader());

        var zstd_buffer: ?[]u8 = null;
        var zstd_reader: ?*Decompressor = null;

        // Check for compressed files
        if (std.mem.endsWith(u8, path, ".zst")) {
            zstd_buffer = try allocator.alloc(u8, zstd.DecompressorOptions.default_window_buffer_len);
            zstd_reader = try allocator.create(Decompressor);
            zstd_reader.?.* = .init(file_reader, .{ .window_buffer = zstd_buffer.? });
        }

        // Parse DBN or DBZ metadata
        const meta = blk: {
            if (zstd_reader) |reader| {
                break :blk try metadata.readMetadata(allocator, reader.reader());
            } else {
                var buf: [3]u8 = undefined;
                _ = try file.pread(&buf, 0);
                if (std.mem.eql(u8, &buf, "DBN")) {
                    break :blk try metadata.readMetadata(allocator, file_reader.reader());
                } else {
                    std.debug.assert(zstd_reader == null);
                    const meta = try dbz.readMetadata(allocator, file_reader.reader());
                    zstd_buffer = try allocator.alloc(u8, zstd.DecompressorOptions.default_window_buffer_len);
                    zstd_reader = try allocator.create(Decompressor);
                    zstd_reader.?.* = .init(file_reader, .{ .window_buffer = zstd_buffer.? });
                    break :blk meta;
                }
            }
        };

        return .{
            .allocator = allocator,
            .meta = meta,
            .file = file,
            .file_reader = file_reader,
            .zstd_buffer = zstd_buffer,
            .zstd_reader = zstd_reader,
        };
    }

    pub fn deinit(self: *Self) void {
        self.file.close();
        self.meta.deinit();
        if (self.zstd_buffer) |buffer| {
            self.allocator.free(buffer);
        }
        if (self.zstd_reader) |reader| {
            self.allocator.destroy(reader);
        }
    }

    pub fn next(self: *Self) !?Record {
        if (self.zstd_reader) |reader| {
            return self.meta.readRecord(reader.reader());
        } else {
            return self.meta.readRecord(self.file_reader.reader());
        }
    }
};
