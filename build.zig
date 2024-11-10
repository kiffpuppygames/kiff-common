const std = @import("std");

pub fn build(b: *std.Build) void 
{
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Define the test step
    const debug_unit_tests = b.addTest(.{
        .name = "common-tests",
        .root_source_file = b.path("src/tests.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(debug_unit_tests);

    const build_tests_step = b.step("test", "Build unit tests");
    build_tests_step.dependOn(&debug_unit_tests.step);
}