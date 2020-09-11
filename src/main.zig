const std = @import("std");

pub fn binaryQuickSort(items: []u32, bit: u5) void {
    if (items.len <= 1) return;
    const mask = @shlExact(@intCast(u32, 1), 31 - bit);
    var left: usize = 0;
    var right = items.len - 1;
    while (left <= right) {
        if (items[left] & mask == 0) {
            left += 1;
        } else {
            std.mem.swap(u32, &items[right], &items[left]);
            if (right == 0) break;
            right -= 1;
        }
    }
    if (bit < 31) {
        binaryQuickSort(items[0..left], bit + 1);
        binaryQuickSort(items[left..], bit + 1);
    }
}

const testing = std.testing;
const asc_u32 = std.sort.asc(u32);
test "bqs u32" {
    var items = [_]u32{ 4, 3, 2, 7, 2, 9, 2, 5 };
    binaryQuickSort(&items, 0);
    // std.sort.sort(u32, &items, {}, asc_u32);
    testing.expect(std.sort.isSorted(u32, &items, {}, asc_u32));
}
