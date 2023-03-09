const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Dependencies
    const http_dep = b.dependency("http", .{
        .target = target,
        .optimize = optimize,
    });

    const http_mod = http_dep.module("http");

    const lib = b.addStaticLibrary(.{
        .name = "requestz",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    lib.addModule("http", http_mod);
    lib.install();

    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    main_tests.addModule("http", http_mod);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
