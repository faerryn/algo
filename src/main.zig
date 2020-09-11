const std = @import("std");

pub fn binaryQuickSort(comptime T: type, items: []T, context: anytype, at: fn (@TypeOf(context), T, usize) ?bool) void {
    return bqs_internal(T, items, context, at, 0);
}

fn bqs_internal(comptime T: type, items: []T, context: anytype, at: fn (@TypeOf(context), T, usize) ?bool, index: usize) void {
    if (items.len <= 1) return;
    var left: usize = 0;
    var right = items.len - 1;
    var unfinished: usize = 0;
    while (left <= right) {
        const side = at(context, items[left], index);
        if (side != null) unfinished += 1;
        if (side orelse true) {
            left += 1;
        } else {
            std.mem.swap(T, &items[right], &items[left]);
            if (right == 0) break;
            right -= 1;
        }
    }
    if (unfinished > 0) {
        bqs_internal(T, items[0..left], context, at, index + 1);
        bqs_internal(T, items[left..], context, at, index + 1);
    }
}

const testing = std.testing;
const asc_u32 = std.sort.asc(u32);
fn at_asc_u32(context: void, x: u32, i: usize) ?bool {
    if (i > 31) return null;
    const mask = @shlExact(@intCast(u32, 1), 31 - @intCast(u5, i));
    return x & mask == 0;
}
test "bqs u32" {
    var items = [_]u32{ 4, 3, 2, 7, 2, 9, 2, 5 };
    binaryQuickSort(u32, &items, {}, at_asc_u32);
    testing.expect(std.sort.isSorted(u32, &items, {}, asc_u32));
}

fn at_asc_str(context: void, x: []const u8, i: usize) ?bool {
    const index = @divTrunc(i, 8);
    const offset = @truncate(u3, i);
    if (index >= x.len) return null;
    const mask = @shlExact(@intCast(u8, 1), 7 - offset);
    return x[index] & mask == 0;
}
test "bqs str" {
    var items = [_][]const u8{
        "roar",
        "roaming",
        "caterpillar",
        "roaring",
        "fire",
        "cat",
        "firefighter",
        "roam",
    };
    const solution = [_][]const u8{
        "cat",
        "caterpillar",
        "fire",
        "firefighter",
        "roam",
        "roaming",
        "roar",
        "roaring",
    };
    binaryQuickSort([]const u8, &items, {}, at_asc_str);
    testing.expectEqual(solution, items);
}
