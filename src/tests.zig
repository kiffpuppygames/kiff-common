const std = @import("std");

const Logger = @import("logging.zig").Logger;
const DateTime = @import("DateTime.zig");

test "log test" 
{
    Logger.info("Hello, world!", .{});
    Logger.debug("Hello, world!", .{});
    Logger.warn("Hello, world!", .{});
    Logger.err("Hello, world!", .{});
}