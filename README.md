# zig-dbn

[![test](https://github.com/mrjbq7/zig-dbn/actions/workflows/test.yml/badge.svg)](https://github.com/mrjbq7/zig-dbn/actions/workflows/test.yml)

Support for working with [Databento](https://databento.com) APIs and data
files in their [Databento Binary
Encoding](https://databento.com/docs/standards-and-conventions/databento-binary-encoding)
file format.

## Quick Start

```zig
const dbn = @import("dbn");

// Open a DBN records file as an iterator
var iter = try dbn.iter.RecordIterator.init(allocator, path);
defer iter.deinit();

// Iterate through all the records
while (try iter.next()) |record| {
    std.debug.print("{any}\n", .{record});
}
```
