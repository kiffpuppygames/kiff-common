const std = @import("std");

pub const StringUnmanaged = @This();

chars: std.ArrayListUnmanaged(u8),
insert_point: []const u8 = "¬",

pub fn init(allocator: std.mem.Allocator, chars: []const u8) !StringUnmanaged {

    var new_chars = try std.ArrayListUnmanaged(u8).initCapacity(allocator, chars.len);
    try new_chars.appendSlice(allocator, chars);

    return .{
        .chars = new_chars
    };
}

pub fn build(allocator: std.mem.Allocator, fmt: []const u8, args: anytype ) !StringUnmanaged
{
    const args_info = @typeInfo(@TypeOf(args));

    var string = try StringUnmanaged.init(allocator, fmt);

    inline for (args_info.@"struct".fields) |arg|
    {
        const val = @field(args, arg.name);        
        const start_index = std.mem.indexOf(u8, string.chars.items, string.insert_point).?;
        std.log.debug("{d}", .{ start_index });        
        string.chars.items[start_index] = val[0];
        try string.chars.insertSlice(allocator, start_index + 1, val[1..]);
        _ = string.chars.orderedRemove(start_index + val.len);
    }

    return string;
}

pub fn deinit(self: *StringUnmanaged, allocator: std.mem.Allocator) void {
    self.chars.deinit(allocator);
}

test "build string" 
{
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer {
        if (gpa.deinit() == .leak) {
            std.log.debug("LEAK!!", .{});
        }
    }

    var str = try StringUnmanaged.build(gpa.allocator(), "Hello ¬ ¬", . { "Guy", "Lemmer" } );
    defer str.deinit(gpa.allocator());

    std.log.debug("Look here -> {s}", .{ str.chars.items });

    try std.testing.expect(std.mem.eql(u8, str.chars.items, "Hello Guy Lemmer"));
}