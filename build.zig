const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("dbn", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const lib = b.addLibrary(.{
        .name = "dbn",
        .root_module = mod,
        .linkage = .static,
    });

    b.installArtifact(lib);

    var iter: SrcIterator = try .init(b, "src/bin");
    defer iter.deinit();

    while (try iter.next(b.allocator)) |entry| {
        defer entry.deinit(b.allocator);

        const exe = b.addExecutable(.{
            .name = entry.name,
            .root_module = b.createModule(.{
                .root_source_file = b.path(entry.path),
                .target = target,
                .optimize = optimize,
            }),
            .use_llvm = true,
        });

        exe.root_module.addImport("dbn", mod);
        b.installArtifact(exe);

        var cmd = b.addRunArtifact(exe);
        if (b.args) |args| cmd.addArgs(args);
        var run = b.step(b.fmt("run:{s}", .{entry.name}), b.fmt("run {s} binary", .{entry.name}));
        run.dependOn(&cmd.step);
    }

    const unit_tests = b.addTest(.{ .root_module = mod, .use_llvm = true });
    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    const docs_step = b.step("docs", "Build docs");
    const install_docs = b.addInstallDirectory(.{
        .source_dir = lib.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });
    docs_step.dependOn(&install_docs.step);
}

pub const SrcIterator = struct {
    dir: std.fs.Dir,
    iter: std.fs.Dir.Iterator,
    path: []const u8,

    const Entry = struct {
        name: []const u8,
        path: []const u8,

        pub fn deinit(self: @This(), allocator: std.mem.Allocator) void {
            allocator.free(self.path);
        }
    };

    pub fn init(b: *std.Build, path: []const u8) !@This() {
        const dir = try b.build_root.handle.openDir(path, .{ .iterate = true });
        return .{ .dir = dir, .iter = dir.iterate(), .path = path };
    }

    pub fn next(self: *@This(), allocator: std.mem.Allocator) !?Entry {
        while (true) {
            const entry = (try self.iter.next()) orelse return null;

            // Skip if the file doesn't end in .zig
            if (!std.mem.endsWith(u8, entry.name, ".zig")) continue;

            // Get the index of the last '.' so we can strip the extension.
            const index = std.mem.lastIndexOfScalar(u8, entry.name, '.') orelse continue;
            if (index == 0) continue;

            // Name of the app and full path to the entrypoint.
            return .{
                .name = entry.name[0..index],
                .path = try std.fs.path.join(allocator, &.{ self.path, entry.name }),
            };
        }
    }

    pub fn deinit(self: *@This()) void {
        self.dir.close();
        self.* = undefined;
    }
};
