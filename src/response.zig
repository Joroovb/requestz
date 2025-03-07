const Allocator = std.mem.Allocator;
const std = @import("std");
const ValueTree = std.json.ValueTree;
const JsonParser = std.json.Parser;
const Connection = @import("connection.zig").Connection;
const http = @import("http");
const Headers = http.Headers;
const StatusCode = http.StatusCode;
const Version = http.Version;

pub const Response = struct {
    allocator: *const Allocator,
    buffer: []const u8,
    status: StatusCode,
    version: Version,
    headers: Headers,
    body: []const u8,

    pub fn deinit(self: *Response) void {
        self.headers.deinit();
        self.allocator.free(self.buffer);
        self.allocator.free(self.body);
    }

    pub fn json(self: Response) !ValueTree {
        var parser = JsonParser.init(self.allocator, false);
        defer parser.deinit();

        return try parser.parse(self.body);
    }
};

pub fn StreamingResponse(comptime ConnectionType: type) type {
    return struct {
        const Self = @This();
        allocator: *Allocator,
        buffer: []const u8,
        connection: *ConnectionType,
        headers: Headers,
        status: StatusCode,
        version: Version,

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.buffer);
            self.headers.deinit();
            self.connection.deinit();
        }

        pub fn read(self: *Self, buffer: []u8) !usize {
            var event = try self.connection.nextEvent(.{ .buffer = buffer });
            switch (event) {
                .Data => |data| return data.bytes.len,
                .EndOfMessage => return 0,
                else => unreachable,
            }
        }
    };
}
