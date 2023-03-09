const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const net_mod = b.dependency("network", .{}).module("network");
    const h11_mod = b.dependency("h11", .{}).module("h11");

    const http_mod = h11_mod.dependencies.get("http").?;

    b.addModule(.{
        .name = "requestz",
        .source_file = .{ .path = "src/main.zig" },
        .dependencies = &.{ .{
            .name = "network",
            .module = net_mod,
        }, .{
            .name = "h11",
            .module = h11_mod,
        }, .{
            .name = "http",
            .module = http_mod,
        } },
    });

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
