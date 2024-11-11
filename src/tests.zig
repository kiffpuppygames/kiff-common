const std = @import("std");

const Logger = @import("logging.zig").Logger;
const DateTime = @import("DateTime.zig");

test "log test" 
{
    const logger = try Logger.new();

    logger.info("Hello, world!", .{});
    logger.debug("Hello, world!", .{});
    logger.warn("Hello, world!", .{});
    logger.err("Hello, world!", .{});
}