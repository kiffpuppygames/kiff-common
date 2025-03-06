const std = @import("std");

const Logger = @import("logging.zig").Logger;

pub inline fn padString(value: anytype, comptime padded_size: usize, comptime pad_char: u8) ![]u8 
{
    // TODO: make this configurable
    var buf: [10]u8 = undefined;

    const string = try std.fmt.bufPrint(&buf, "{}", . { value });

    const number_of_chars_to_add = padded_size - string.len;
    var pad_buffer = [_]u8 { pad_char } ** padded_size;

    if (number_of_chars_to_add == 0)
    {
        return string;
    }

    std.mem.copyBackwards(u8, pad_buffer[number_of_chars_to_add..], string);
    return &pad_buffer;
}

pub inline fn toNullTerminated(alloc: std.mem.Allocator, str: []const u8) [*:0]const u8 
{
    return std.fmt.allocPrintZ(alloc, "{s}", .{str}) catch unreachable;
}

pub inline fn string_arr_to_slice(text: [256]u8) []const u8
{
    const text_ptr = @as([]u8, @constCast(&text));
    const text_len = std.mem.indexOfScalar(u8, text_ptr, 0);
    return text_ptr[0..text_len.?];
}
