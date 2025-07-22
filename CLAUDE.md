# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Essential Commands

### Build Commands
```bash
# Build the entire project (library + binaries)
zig build

# Build with optimizations
zig build --release=fast
```

### Testing
```bash
# Run all tests
zig build test

# Run tests for a specific module
zig test src/api.zig
zig test src/iter.zig
```

### Running Tools
```bash
# Display DBN file contents
./zig-out/bin/dbn_cat test_data/bbo-1s.dbn.zst

# Check DBN file validity
./zig-out/bin/dbn_check test_data/trades-1m.dbn

# Convert between formats
./zig-out/bin/dbn_convert input.dbn output.csv
```

### Documentation
```bash
# Generate documentation
zig build docs

# View docs (after building)
open zig-out/docs/index.html
```

## Architecture Overview

### Core Library Structure
The library (`src/`) implements the Databento Binary Encoding (DBN) format:
- **Version Support**: Handles DBN v1, v2, v3 and legacy DBZ formats through dedicated modules
- **Record Types**: Supports various market data types (BBO, MBO, MBP, trades, OHLCV, statistics, definitions, imbalance)
- **Compression**: Built-in support for Zstandard compression (.zst files)
- **Iterator Pattern**: `RecordIterator` provides streaming access to large DBN files

### Key Components
1. **api.zig**: HTTP/WebSocket client for Databento API
2. **iter.zig**: Core iterator for reading DBN files efficiently
3. **metadata.zig**: Handles DBN file metadata parsing and validation
4. **record.zig**: Type definitions for all DBN record types
5. **live.zig**: Real-time data handling via socket

### Binary Tools
Located in `src/bin/`, each tool serves a specific purpose:
- **dbn_api**: Interact with Databento API directly
- **dbn_cat**: Swiss-army knife for displaying DBN data in various formats (csv, json, zon)
- **dbn_check**: Validate DBN file integrity
- **dbn_convert**: Transform between DBN and other formats

### Testing Strategy
- Unit tests are embedded within source files using Zig's built-in test framework
- Integration tests use real DBN files from `test_data/` directory
- Test data covers various schemas, time intervals, and compression formats

### Development Notes
- Minimum Zig version: 0.15.0-dev
- No external dependencies - self-contained project
- Follow existing patterns when adding new record types or tools
- Use `RecordIterator` for all file reading operations
