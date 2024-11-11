const std = @import("std");
const builtin = @import("builtin");
const DateTime = @import("DateTime.zig");

pub const Logger = struct 
{
    var allocator =  std.heap.GeneralPurposeAllocator(.{}){};
    
    pub fn write(msg: []const u8) void 
    {
        _ = std.io.getStdOut().writer().print("{s}\n", .{msg});
    }

    pub fn print(comptime msg: []const u8, args: anytype) void 
    {
        const formatted_msg = formatMsg(msg, args);
        defer allocator.allocator().free(formatted_msg);
        std.io.getStdOut().writer().print("{s}\n", .{formatted_msg}) catch |e| 
        { 
            std.debug.panic("Failed to format message: {?}", .{e});
        };
    }

    pub fn info(comptime msg: []const u8, args: anytype) void 
    {
        const date_time = DateTime.getNowString(allocator.allocator());
        defer allocator.allocator().free(date_time);
        const formatted_msg = formatMsg(msg, args);
        defer allocator.allocator().free(formatted_msg);
        const final_msg = formatMsg("\x1b[32m[INFO]\x1b[0m  {s} : {s}", .{ date_time, formatted_msg });
        std.io.getStdOut().writer().print("{s}\n", .{final_msg}) catch |e| 
        { 
            std.debug.panic("Failed to format message: {?}", .{e});
        };
    }

    pub fn warn(self: *const Logger, comptime msg: []const u8, args: anytype) void 
    {
        const date_time = DateTime.getNowString(allocator.allocator());
        defer allocator.allocator().free(date_time);
        const formatted_msg = self.formatMsg(msg, args);
        defer allocator.allocator().free(formatted_msg);
        const final_msg = self.formatMsg("\x1b[33m[WARN]\x1b[0m  {s} : {s}", .{ date_time, formatted_msg });
        std.io.getStdOut().writer().print("{s}\n", .{final_msg}) catch |e| 
        { 
            std.debug.panic("Failed to format message: {?}", .{e});
        };
    }

    pub fn err(comptime msg: []const u8, args: anytype) void 
    {
        const date_time = DateTime.getNowString(allocator.allocator());
        defer allocator.allocator().free(date_time);
        const formatted_msg = formatMsg(msg, args);
        defer allocator.allocator().free(formatted_msg);
        const final_msg = formatMsg("\x1b[31m[ERROR]\x1b[0m {s} : {s}", .{ date_time, formatted_msg });
        std.io.getStdOut().writer().print("{s}\n", .{final_msg}) catch |e| 
        { 
            std.debug.panic("Failed to format message: {?}", .{e});
        };
    }

    pub fn debug(comptime msg: []const u8, args: anytype) void 
    {
        if (builtin.mode == .Debug)
        {
            const date_time = DateTime.getNowString(allocator.allocator());
            defer allocator.allocator().free(date_time);
            const formatted_msg = formatMsg(msg, args);
            defer allocator.allocator().free(formatted_msg);
            const final_msg = formatMsg("\x1b[36m[DEBUG]\x1b[0m {s} : {s}", .{ date_time, formatted_msg });
            std.io.getStdOut().writer().print("{s}\n", .{final_msg}) catch |e| 
            { 
                std.debug.panic("Failed to format message: {?}", .{e});
            };
        }
    }

    inline fn formatMsg(msg: []const u8, args: anytype) []const u8 
    {
        return std.fmt.allocPrint(allocator.allocator(), msg, args) catch |e| 
        { 
            std.debug.panic("Failed to format message: {?}", .{e});
        };
    }
};




