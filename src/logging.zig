const std = @import("std");
const builtin = @import("builtin");

const handleError = @import("errors.zig").handleError;

const DateTime = @import("DateTime.zig");

const LogLevel = struct {
    const debug: []const u8 = "DEBUG";
    const info: []const u8 = "INFO ";
    const warn: []const u8 = "WARN ";
    const eror: []const u8 = "ERROR";
};


pub const Logger = struct 
{
    var gpa =  std.heap.GeneralPurposeAllocator(.{}){};
    
    pub fn write(msg: []const u8) void 
    {
        _ = std.io.getStdOut().writer().print("{s}\n", .{msg});
    }

    pub fn print(comptime msg: []const u8, args: anytype) void 
    {
        const formatted_msg = handleLoggerResult([]u8, std.fmt.allocPrint(gpa.allocator(), msg, args));
        handleLoggerResult(void, std.io.getStdOut().writer().print(msg ++ "\n", .{ formatted_msg }));    
    }

    pub fn info(comptime msg: []const u8, args: anytype) void 
    {
        log(msg, args, LogLevel.info);
    }

    pub fn warn(comptime msg: []const u8, args: anytype) void 
    {
        log(msg, args, LogLevel.warn);
    }

    pub fn err(comptime msg: []const u8, args: anytype) void 
    {
        log(msg, args, LogLevel.eror);
    }

    pub fn debug(comptime msg: []const u8, args: anytype) void 
    {
        if (builtin.mode == .Debug)
        {
            log(msg, args, LogLevel.debug);
        }
    }

    inline fn log(comptime msg: []const u8, args: anytype, level: []const u8) void
    {
        const date_time = handleLoggerResult([]u8, DateTime.getNow().toString());
        const formatted_msg = handleLoggerResult([]u8, std.fmt.allocPrint(gpa.allocator(), msg, args));
        handleLoggerResult(void, std.io.getStdOut().writer().print("\x1b[36m[{s}]\x1b[0m {s}\t" ++ "{s}" ++ "\n", .{ level, date_time, formatted_msg }));       
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

    inline fn handleLoggerResult(T: type, result: anyerror!T) T
    {        
        const value = result catch |res_error| {
            print("\x1b[31m Error in logger!!! {s}\x1b[0m\n", .{ @errorName(res_error) });
            @panic("");
        };

        return value;
    }
};




