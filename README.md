# AVLTree for LuaJIT

A high-performance AVL Tree implementation for Lua, specifically optimized for LuaJIT.

## Motivation

LuaJIT is a powerful just-in-time compiled scripting language, renowned for its speed and efficiency. However, it lacks a built-in high-performance, balanced tree data structure. This module addresses that gap by providing an AVL tree implementation that delivers exceptional performance, particularly when used with LuaJIT.

The AVLTree is designed with cache locality in mind, storing node properties (left, right, parent pointers, and height) in the array part of a Lua table. This approach minimizes memory fragmentation and maximizes cache efficiency, critical for performance in LuaJIT. Unlike red-black trees, which require more complex balancing operations and branching, AVL trees have a simpler and less branch-heavy implementation. This characteristic allows LuaJIT's trace compiler to optimize the code more effectively, avoiding trace explosion and ensuring predictable, high-speed execution.

By choosing an AVL tree over a red-black tree, this library achieves a balance of simplicity, performance, and reliability, making it an ideal choice for applications requiring fast key-value storage and retrieval in LuaJIT environments.

## Features

- **High Performance**: Optimized for LuaJIT with minimal branching and excellent cache locality.
- **Balanced Tree**: Maintains O(log n) time complexity for insertions, deletions, and searches.
- **Flexible Key Types**: Supports custom comparators for non-numeric keys.
- **Rich API**: Includes operations like `insert`, `delete`, `get`, `successor`, `predecessor`, `floor`, `ceil`, `range`, and iteration.
- **Safe Iteration**: Allows tree traversal with `nextNodeIndex` and `prevNodeIndex`, even during modifications (with key validation).
- **Memory Efficient**: Uses a single table for node properties, reducing overhead.
- **Comprehensive Tests**: Includes unit tests for correctness and benchmark tests for performance evaluation.

## Installation

1. **Download the Library**:
   - Copy the `avltree.lua` file into your project directory or into your lua module path.
2. **Requirements**:
   - Lua 5.1 or LuaJIT 2.0+ (optimized for LuaJIT).
   - No external dependencies.

3. **Usage in Code**:
   - Require the module in your Lua script:
     ```lua
     local AVLTree = require('avltree')
     ```

## Usage

### Creating a Tree

Create a new AVL tree with an optional custom comparator for non-numeric keys:

```lua
local AVLTree = require('avltree3')

-- Default comparator (works with numbers and strings)
local tree = AVLTree:new()

-- Custom comparator for complex keys
local function customComparator(a, b)
    return (a < b and -1) or (a > b and 1) or 0
end
local customTree = AVLTree:new(customComparator)
```

### Basic Operations

```lua
-- Insert key-value pairs
tree:insert(10, "value10")
tree:insert(20, "value20")
tree:insert(15, "value15")

-- Retrieve a value
local key, value = tree:get(15)
print(key, value) -- 15, "value15"

-- Delete a key
tree:delete(20)
assert(tree:get(20) == nil)

-- Get tree size
print(tree:len()) -- 2
```

### Iteration

```lua
-- Using pairs
for key, value in pairs(tree) do
    print(key, value)
end

-- Manual traversal (in-order)
local index = tree:successor(nil) -- Start at smallest key
while index do
    local key, value = tree:getKeyVal(index)
    print(key, value)
    index = tree:successor(index)
end
```

### Advanced Operations

```lua
-- Find floor (largest key <= given key)
local index = tree:floor(12)
local key, value = tree:getKeyVal(index)
print(key, value) -- 10, "value10"

-- Find ceil (smallest key >= given key)
index = tree:ceil(12)
key, value = tree:getKeyVal(index)
print(key, value) -- 15, "value15"

-- Range query (keys between minKey and maxKey)
local keys = tree:range(10, 20)
for _, key in ipairs(keys) do
    print(key) -- 10, 15
end
```

### Custom Comparator Example

```lua
local function tableComparator(a, b)
    return (a.id < b.id and -1) or (a.id > b.id and 1) or 0
end

local tree = AVLTree:new(tableComparator)
tree:insert({ id = 1, name = "Alice" }, "data1")
tree:insert({ id = 2, name = "Bob" }, "data2")

local key, value = tree:get({ id = 1 })
print(key.name, value) -- Alice, data1
```

## Testing

The library includes a comprehensive test suite (tests.lua) that verifies correctness and measures performance. The tests cover:
* Insertion and deletion with all rotation cases (LL, RR, LR, RL).
* Traversal using successor and predecessor.
* Edge cases for floor, ceil, and range.
* Performance benchmarks for random and sequential operations.

To run the tests:
```bash
luajit avltree_tests.lua
```

## Performance

The AVLTree is optimized for LuaJIT, leveraging its trace compiler for high performance.
Benchmark tests (included in avltree_tests.lua) demonstrate its efficiency.
Here are results running on an AMD Ryzen 7 8840U (3.3 GHz).

```
Test performance, every round 1,000,000, then clear
round 1: 0.2s, avg: 0.2s
round 2: 0.198s, avg: 0.199s
round 3: 0.207s, avg: 0.20166666666667s
round 4: 0.2s, avg: 0.20125s
round 5: 0.198s, avg: 0.2006s
round 6: 0.202s, avg: 0.20083333333333s
round 7: 0.2s, avg: 0.20071428571429s
round 8: 0.205s, avg: 0.20125s
round 9: 0.215s, avg: 0.20277777777778s
round 10: 0.202s, avg: 0.2027s

Extended Benchmark Tests (1,000,000 operations each, random keys)

Benchmark: Insert Random Keys
Round 1: 0.984s
Round 2: 0.971s
Round 3: 0.988s
Round 4: 0.973s
Round 5: 1.004s
Insert Average: 0.984s

Benchmark: Find Random Keys
Round 1: 0.878s
Round 2: 0.845s
Round 3: 0.894s
Round 4: 0.886s
Round 5: 0.879s
Find Average: 0.876s

Benchmark: Get Random Keys
Round 1: 1.012s
Round 2: 0.982s
Round 3: 1.007s
Round 4: 0.985s
Round 5: 1.017s
Get Average: 1.001s

Benchmark: Delete Random Keys
Round 1: 1.123s
Round 2: 1.202s
Round 3: 1.128s
Round 4: 1.195s
Round 5: 1.188s
Delete Average: 1.167s

Benchmark: Successor
Round 1: 0.135s
Round 2: 0.133s
Round 3: 0.125s
Round 4: 0.124s
Round 5: 0.129s
Successor Average: 0.129s

Benchmark: Predecessor
Round 1: 0.118s
Round 2: 0.134s
Round 3: 0.136s
Round 4: 0.132s
Round 5: 0.130s
Predecessor Average: 0.130s

Benchmark: Floor Random Keys
Round 1: 0.917s
Round 2: 0.903s
Round 3: 0.881s
Round 4: 0.878s
Round 5: 0.887s
Floor Average: 0.893s

Benchmark: Ceil Random Keys
Round 1: 0.898s
Round 2: 0.889s
Round 3: 0.910s
Round 4: 0.897s
Round 5: 0.910s
Ceil Average: 0.901s

Benchmark: Range Queries
Round 1: 0.118s
Round 2: 0.107s
Round 3: 0.095s
Round 4: 0.104s
Round 5: 0.102s
Range Average: 0.105s (for 10000 ranges)
```

## License

This library is licensed under the Apache License, Version 2.0. See the LICENSE file for details.

```
Copyright 2025 Jeff Solinsky

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

