const std = @import("std");

pub fn build(b: *std.Build) void 
{
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Define the library
    const lib = b.addStaticLibrary(.{
        .name = "kiff-common",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    
    lib.root_module.addImport("kiff-common", b.addModule("kiff-common", .{ .root_source_file = b.path("src/root.zig") } ));
    b.installArtifact(lib);

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