const std = @import("std");

pub fn binaryQuickSort(comptime T: type, items: []T, context: anytype, leftBucketAt: fn (@TypeOf(context), T, usize) ?bool) void {
    bqsi(T, items, context, leftBucketAt, 0);
}

fn bqsi(comptime T: type, items: []T, context: anytype, leftBucketAt: fn (@TypeOf(context), T, usize) ?bool, index: usize) void {
    if (items.len <= 1) return;
    var finished: usize = 0;
    var left: usize = 0;
    var right = items.len - 1;
    while (left <= right) {
        const side = leftBucketAt(context, items[left], index);
        if (side == null) {
            std.mem.swap(T, &items[left], &items[finished]);
            finished += 1;
        }
        if (side orelse true) {
            left += 1;
        } else {
            std.mem.swap(T, &items[left], &items[right]);
            if (right == 0) break;
            right -= 1;
        }
    }
    if (finished < items.len) {
        bqsi(T, items[0..left], context, leftBucketAt, index + 1);
        bqsi(T, items[left..], context, leftBucketAt, index + 1);
    }
}

const testing = std.testing;
const asc_u32 = std.sort.asc(u32);

fn leftBucketAtAscU32(context: void, x: u32, i: usize) ?bool {
    if (i >= 32) return null;
    const mask = @shlExact(@intCast(u32, 1), 31 - @intCast(u5, i));
    return x & mask == 0;
}
test "bqs u32" {
    var items = [_]u32{ 4, 3, 2, 7, 2, 9, 2, 5 };
    binaryQuickSort(u32, &items, {}, leftBucketAtAscU32);
    testing.expect(std.sort.isSorted(u32, &items, {}, asc_u32));
}

const asc_i32 = std.sort.asc(i32);
fn leftBucketAtAscI32(context: void, x: i32, i: usize) ?bool {
    if (i >= 32) return null;
    const mask = @shlExact(@intCast(u32, 1), 31 - @intCast(u5, i));
    return (i == 0) != (@bitCast(u32, x) & mask == 0);
}
test "bqs i32" {
    var items = [_]i32{ 4, -3, 2, -7, 2, -9, -2, 5 };
    binaryQuickSort(i32, &items, {}, leftBucketAtAscI32);
    testing.expect(std.sort.isSorted(i32, &items, {}, asc_i32));
}

fn leftBucketAtAscStr(context: void, x: []const u8, i: usize) ?bool {
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
        "roaring",
    };
    binaryQuickSort([]const u8, &items, {}, leftBucketAtAscStr);
    testing.expectEqual(solution, items);
}

fn leftBucketAtAscU32Arr(context: void, x: []const u32, i: usize) ?bool {
    const index = @divTrunc(i, 32);
    const offset = @truncate(u5, i);
    if (index >= x.len) return null;
    const mask = @shlExact(@intCast(u32, 1), 31 - offset);
    return x[index] & mask == 0;
}
test "bqs []u32" {
    var items = [_][]const u32{
        &[_]u32{ 0, 0, 0 },
        &[_]u32{ 0, 0 },
        &[_]u32{0},
        &[_]u32{ 1, 2, 3, 0, 0, 0 },
        &[_]u32{ 1, 2, 3, 0, 0 },
        &[_]u32{ 1, 2, 3, 0 },
    };
    const solution = [_][]const u32{
        &[_]u32{0},
        &[_]u32{ 0, 0 },
        &[_]u32{ 0, 0, 0 },
        &[_]u32{ 1, 2, 3, 0 },
        &[_]u32{ 1, 2, 3, 0, 0 },
        &[_]u32{ 1, 2, 3, 0, 0, 0 },
    };
    binaryQuickSort([]const u32, &items, {}, leftBucketAtAscU32Arr);

    testing.expectEqual(solution.len, items.len);
    var i: usize = 0;
    while (i < solution.len) : (i += 1) {
        testing.expectEqual(solution[i].len, items[i].len);
        var j: usize = 0;
        while (j < solution[i].len) : (j += 1) {
            testing.expectEqual(solution[i][j], items[i][j]);
        }
    }
}
