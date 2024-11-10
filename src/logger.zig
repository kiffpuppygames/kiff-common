const std = @import("std");
const DateTime = @import("DateTime.zig");

var allocator: std.mem.Allocator = undefined;

pub fn init(alloc: std.mem.Allocator) void {
    allocator = alloc;
}

pub fn write(msg: []const u8) void {
    _ = std.io.getStdOut().writer().print("{s}\n", .{msg}) catch unreachable;
}

pub fn info(comptime msg: []const u8, args: anytype) void {
    const date_time = DateTime.getNowString(allocator);
    defer allocator.free(date_time);
    const formatted_msg = formatMsg(msg, args);
    defer allocator.free(formatted_msg);
    const final_msg = formatMsg("[INFO]  {s} : {s}", .{ date_time, formatted_msg });
    std.io.getStdOut().writer().print("{s}\n", .{final_msg}) catch unreachable;
}

pub fn warn(comptime msg: []const u8, args: anytype) void {
    const date_time = DateTime.getNowString(allocator);
    defer allocator.free(date_time);
    const formatted_msg = formatMsg(msg, args);
    defer allocator.free(formatted_msg);
    const final_msg = formatMsg("[WARN]  {s} : {s}", .{ date_time, formatted_msg });
    std.io.getStdOut().writer().print("{s}\n", .{final_msg}) catch unreachable;
}

pub fn err(comptime msg: []const u8, args: anytype) void {
    const date_time = DateTime.getNowString(allocator);
    defer allocator.free(date_time);
    const formatted_msg = formatMsg(msg, args);
    defer allocator.free(formatted_msg);
    const final_msg = formatMsg("[ERROR] {s} : {s}", .{ date_time, formatted_msg });
    std.io.getStdOut().writer().print("{s}\n", .{final_msg}) catch unreachable;
}

pub fn debug(comptime msg: []const u8, args: anytype) void {
    const date_time = DateTime.getNowString(allocator);
    defer allocator.free(date_time);
    const formatted_msg = formatMsg(msg, args);
    defer allocator.free(formatted_msg);
    const final_msg = formatMsg("[ERROR] {s} : {s}", .{ date_time, formatted_msg });
    std.io.getStdOut().writer().print("{s}\n", .{final_msg}) catch unreachable;
}

inline fn formatMsg(msg: []const u8, args: anytype) []const u8 {
    return std.fmt.allocPrint(allocator, msg, args) catch unreachable;
}
