const std = @import("std");
const builtin = @import("builtin");

const handleError = @import("errors.zig").handleError;

const DateTime = @import("DateTime.zig");

pub const Logger = struct 
{
    var gpa =  std.heap.GeneralPurposeAllocator(.{}){};
    
    pub fn write(msg: []const u8) void 
    {
        _ = std.io.getStdOut().writer().print("{s}\n", .{msg});
    }

    pub fn print(comptime msg: []const u8, args: anytype) void 
    {
        const formatted_msg = formatMsg(msg, args);
        defer gpa.allocator().free(formatted_msg);
        std.io.getStdOut().writer().print("{s}\n", .{formatted_msg}) catch |e| 
        { 
            std.debug.panic("Failed to format message: {?}", .{e});
        };
    }

    pub fn info(comptime msg: []const u8, args: anytype) void 
    {
        const date_time = DateTime.getNowString(gpa.allocator());
        defer gpa.allocator().free(date_time);
        const formatted_msg = formatMsg(msg, args);
        defer gpa.allocator().free(formatted_msg);
        const final_msg = formatMsg("\x1b[32m[INFO]\x1b[0m  {s} : {s}", .{ date_time, formatted_msg });
        std.io.getStdOut().writer().print("{s}\n", .{final_msg}) catch |e| 
        { 
            std.debug.panic("Failed to format message: {?}", .{e});
        };
    }

    pub fn warn(comptime msg: []const u8, args: anytype) void 
    {
        const date_time = DateTime.getNowString(gpa.allocator());
        defer gpa.allocator().free(date_time);
        const formatted_msg = formatMsg(msg, args);
        defer gpa.allocator().free(formatted_msg);
        const final_msg = formatMsg("\x1b[33m[WARN]\x1b[0m  {s} : {s}", .{ date_time, formatted_msg });
        std.io.getStdOut().writer().print("{s}\n", .{final_msg}) catch |e| 
        { 
            std.debug.panic("Failed to format message: {?}", .{e});
        };
    }

    pub fn err(comptime msg: []const u8, args: anytype) void 
    {
        const date_time = DateTime.getNowString(gpa.allocator());
        defer gpa.allocator().free(date_time);
        const formatted_msg = formatMsg(msg, args);
        defer gpa.allocator().free(formatted_msg);
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
            const date_time = handleLoggerResult([]u8, DateTime.getNow().toString());
            const formatted_msg = handleLoggerResult([]u8, std.fmt.allocPrint(gpa.allocator(), msg, args));
            handleLoggerResult(void, std.io.getStdOut().writer().print("\x1b[36m[DEBUG]\x1b[0m {s}\t" ++ "{s}" ++ "\n", .{ date_time, formatted_msg }));            
            //handleLoggerResult(void, std.io.getStdOut().writer().print( msg ++ "\n", args));
        }
    }

    pub inline fn handleResult(result: anyerror!void) void
    {
        const trace = @errorReturnTrace() orelse return;    
        if (!result) |e| 
        {
            switch (e)
            {
                _ => 
                {
                    Logger.err("Unhandled Error {}", .{e});
                    for (trace) |frame| 
                    {
                        print("\t{s}:{d}:{d}\n", .{ frame.source_file, frame.line, frame.column });
                    }
                }
            }

            for (trace) |frame| 
            {
                print("  {s}:{d}:{d}\n", .{ frame.source_file, frame.line, frame.column });
            }
        }
    }

    inline fn formatMsg(msg: []const u8, args: anytype) []const u8 
    {
        return std.fmt.allocPrint(gpa.allocator(), msg, args) catch |e| 
        { 
            std.debug.panic("Failed to format message: {?}", .{e});
        };
    }

    inline fn handleLoggerResult(T: type, result: anyerror!T) T
    {
        const trace: *std.builtin.StackTrace = @errorReturnTrace() orelse undefined;    

        const value = result catch |res_error| {
            print("\x1b[31m Error in logger!!! {s}\x1b[0m\n", .{ @errorName(res_error) });

            const debug_info = std.debug.getSelfDebugInfo() catch |e| 
            { 
                print("\nUnable to print stack trace: Unable to open debug info: {s}\n", .{@errorName(e)});
                @panic("");
            }; 
            
            std.debug.writeStackTrace(trace.*, std.io.getStdOut().writer(), debug_info, std.io.tty.detectConfig(std.io.getStdOut()) ) catch |e|
            { 
                print("\nUnable to print stack trace: {s}\n", .{@errorName(e)});
                @panic("");
            };

            @panic("");
        };

        return value;
    }
};




