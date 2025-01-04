const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var client = std.http.Client{
        .allocator = allocator,
    };

    client.initDefaultProxies(allocator) catch |err| {
        std.debug.print("Unable to initialize default proxies: {}\n", .{err});
    };
    defer client.deinit();

    std.debug.print("http proxy settings: {any}\n", .{client.http_proxy});
    std.debug.print("https proxy settings: {any}\n", .{client.https_proxy});

    var response_http = std.ArrayList(u8).init(allocator);
    defer response_http.deinit();

    const result_http = try client.fetch(.{
        .method = .GET,
        .location = .{ .url = "http://httpbin.org/get" },
        .response_storage = .{ .dynamic = &response_http },
    });

    std.debug.print("Result: {}\n", .{result_http});

    std.debug.print("============================\n", .{});

    var response_https = std.ArrayList(u8).init(allocator);
    defer response_https.deinit();

    const result_https = try client.fetch(.{
        .method = .GET,
        .location = .{ .url = "https://httpbin.org/get" },
        .response_storage = .{ .dynamic = &response_https },
    });

    std.debug.print("Result: {}\n", .{result_https});
    std.debug.print("Response: {s}\n", .{response_https.items});
}
