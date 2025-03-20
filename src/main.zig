const std = @import("std");
const kiff_common = @import("kiff_common");

pub fn main() !void 
{
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer {
        if (gpa.deinit() == .leak) {
            std.log.debug("LEAK!!", .{});
        }
    }

    var str = try kiff_common.StringUnmanaged.build(gpa.allocator(), "Hello ¬ ¬", . { "Guy", "Lemmer" } );
    defer str.deinit(gpa.allocator());

    std.log.debug("{s}", .{ str.chars.items });
    std.log.debug("{any}", .{ str.chars.items });
}