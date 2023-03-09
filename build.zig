const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const http_dep = b.dependency("http", .{});
    const net_dep = b.dependency("network", .{});

    b.addModule(.{ .name = "requestz", .source_file = .{ .path = "src/main.zig" } });

    const lib = b.addSharedLibrary(.{
        .name = "requestz",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    lib.addModule("http", http_dep.module("http"));
    lib.addModule("network", net_dep.module("network"));

    lib.install();

    tests(b, target, optimize);
    clean(b);
}

fn tests(b: *std.Build, target: std.zig.CrossTarget, mode: std.builtin.OptimizeMode) void {
    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/test.zig" },
        .target = target,
        .optimize = mode,
    });

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}

fn clean(b: *std.Build) void {
    const cmd = b.addSystemCommand(&[_][]const u8{
        "rm",
        "-rf",
        "zig-out",
        "zig-cache",
    });

    const clean_step = b.step("clean", "Remove project artifacts");
    clean_step.dependOn(&cmd.step);
}
