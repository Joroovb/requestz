const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    b.addModule(.{ .name = "requestz", .source_file = .{ .path = "src/main.zig" } });

    const http_dep = b.dependency("http", .{});
    const net_dep = b.dependency("network", .{});

    try b.modules.put("http", http_dep.module("http"));
    try b.modules.put("network", net_dep.module("network"));

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
