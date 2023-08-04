const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "png",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    if (target.isLinux()) {
        lib.linkSystemLibrary("m");
    }

    const zlib_dep = b.dependency("zlib", .{ .target = target, .optimize = optimize });
    lib.linkLibrary(zlib_dep.artifact("z"));
    lib.addIncludePath(.{ .path = "upstream" });
    lib.addIncludePath(.{ .path = "include" });

    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();
    try flags.appendSlice(&.{
        "-DPNG_ARM_NEON_OPT=0",
        "-DPNG_POWERPC_VSX_OPT=0",
        "-DPNG_INTEL_SSE_OPT=0",
        "-DPNG_MIPS_MSA_OPT=0",
    });
    lib.addCSourceFiles(srcs, flags.items);

    lib.installHeader("include/pnglibconf.h", "pnglibconf.h");
    inline for (headers) |header| {
        lib.installHeader("upstream/" ++ header, header);
    }

    b.installArtifact(lib);
}

const headers = &.{
    "png.h",
    "pngconf.h",
    "pngdebug.h",
    "pnginfo.h",
    "pngpriv.h",
    "pngstruct.h",
};

const srcs = &.{
    "upstream/png.c",
    "upstream/pngerror.c",
    "upstream/pngget.c",
    "upstream/pngmem.c",
    "upstream/pngpread.c",
    "upstream/pngread.c",
    "upstream/pngrio.c",
    "upstream/pngrtran.c",
    "upstream/pngrutil.c",
    "upstream/pngset.c",
    "upstream/pngtrans.c",
    "upstream/pngwio.c",
    "upstream/pngwrite.c",
    "upstream/pngwtran.c",
    "upstream/pngwutil.c",
};
