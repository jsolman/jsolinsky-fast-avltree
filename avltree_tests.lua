local AVLTree = require('avltree')

-- Helper function to check if the tree is balanced
local function isBalanced(tree, nodeIndex)
    if nodeIndex == nil then return true end
    local leftIndex = tree:getLeft(nodeIndex)
    local leftHeight = leftIndex and tree:getHeight(leftIndex) or 0
    local rightIndex = tree:getRight(nodeIndex)
    local rightHeight = rightIndex and tree:getHeight(rightIndex) or 0
    local balanceFactor = leftHeight - rightHeight
    if balanceFactor < -1 or balanceFactor > 1 then
        print("bf", balanceFactor)
        return false
    end
    if not isBalanced(tree, leftIndex) then return false end
    if not isBalanced(tree, rightIndex) then return false end
    return true
end

-- Create a new AVL tree instance
local tree = AVLTree:new()

print("Testing Insertions with Rotations:")

-- Test RR rotation (single left rotation)
tree:clear()
tree:insert(10)
tree:insert(20)
tree:insert(30) -- Should trigger RR rotation
assert(isBalanced(tree, tree.root), "Tree is not balanced after insertion (RR rotation)")
print("Passed RR rotation test")

-- Test LL rotation (single right rotation)
tree:clear()
tree:insert(30)
tree:insert(20)
tree:insert(10) -- Should trigger LL rotation
assert(isBalanced(tree, tree.root), "Tree is not balanced after insertion (LL rotation)")
print("Passed LL rotation test")

-- Test LR rotation (double rotation: left then right)
tree:clear()
tree:insert(30)
tree:insert(10)
tree:insert(20) -- Should trigger LR rotation
assert(isBalanced(tree, tree.root), "Tree is not balanced after insertion (LR rotation)")
print("Passed LR rotation test")

-- Test RL rotation (double rotation: right then left)
tree:clear()
tree:insert(10)
tree:insert(30)
tree:insert(20) -- Should trigger RL rotation
assert(isBalanced(tree, tree.root), "Tree is not balanced after insertion (RL rotation)")
print("Passed RL rotation test")

-- **Test Deletions with Rotations**
print("\nTesting Deletions with Rotations:")

-- LL rotation on deletion
tree:clear()
tree:insert(30)
tree:insert(20)
tree:insert(40)
tree:insert(10)
tree:delete(40)
assert(isBalanced(tree, tree.root), "Tree is not balanced after deletion (LL rotation)")
print("Passed LL rotation test on deletion")

-- RR rotation on deletion
tree:clear()
tree:insert(10)
tree:insert(20)
tree:insert(5)
tree:insert(30)
tree:delete(5)
assert(isBalanced(tree, tree.root), "Tree is not balanced after deletion (RR rotation)")
print("Passed RR rotation test on deletion")

-- LR rotation on deletion
tree:clear()
tree:insert(50)
tree:insert(30)
tree:insert(70)
tree:insert(20)
tree:insert(40)
tree:insert(60)
tree:insert(80)
tree:delete(70)
assert(isBalanced(tree, tree.root), "Tree is not balanced after deletion (LR rotation)")
print("Passed LR rotation test on deletion")

-- RL rotation on deletion
tree:clear()
tree:insert(40)
tree:insert(60)
tree:insert(20)
tree:insert(50)
tree:insert(70)
tree:insert(45)
tree:delete(20)
assert(isBalanced(tree, tree.root), "Tree is not balanced after deletion (RL rotation)")
print("Passed RL rotation test on deletion")

-- **Additional Test Case: Insert and Delete to Ensure Balance**
print("\nAdditional Test Case: Insert and Delete to Ensure Balance")
tree:clear()
local values = {30, 20, 10, 50, 40, 25}
for _, value in ipairs(values) do
    tree:insert(value)
end
assert(isBalanced(tree, tree.root), "Tree is not balanced after multiple insertions")
print("Passed balance test after multiple insertions")

-- Test getNextNode
local nodeIndex = tree:successor(nil)
assert(tree.keys[nodeIndex] == 10, "Failed: successor(nodeIndex) != 10")
local nextIndex = tree:successor(nodeIndex)
assert(tree.keys[nextIndex] == 20, "Failed: successor(nodeIndex) != 20")
nextIndex = tree:successor(nextIndex)
assert(tree.keys[nextIndex] == 25, "Failed: successor(nodeIndex) != 25")
nextIndex = tree:successor(nextIndex)
assert(tree.keys[nextIndex] == 30, "Failed: successor(nodeIndex) != 30")
nextIndex = tree:successor(nextIndex)
assert(tree.keys[nextIndex] == 40, "Failed: successor(nodeIndex) != 40")
nextIndex = tree:successor(nextIndex)
assert(tree.keys[nextIndex] == 50, "Failed: successor(nodeIndex) != 50")
assert(tree:successor(nextIndex) == nil, "Failed: last successor(nodeIndex) != nil")
print("Passed walking using successor.")

-- Test getPrevNode
nodeIndex = tree:predecessor(nil)
assert(tree.keys[nodeIndex] == 50, "Failed: predecessor(nodeIndex) != 50")
local prevIndex = tree:predecessor(nodeIndex)
assert(tree.keys[prevIndex] == 40, "Failed: predecessor(nodeIndex) != 40")
prevIndex = tree:predecessor(prevIndex)
assert(tree.keys[prevIndex] == 30, "Failed: predecessor(nodeIndex) != 30")
prevIndex = tree:predecessor(prevIndex)
assert(tree.keys[prevIndex] == 25, "Failed: predecessor(nodeIndex) != 25")
prevIndex = tree:predecessor(prevIndex)
assert(tree.keys[prevIndex] == 20, "Failed: predecessor(nodeIndex) != 20")
prevIndex = tree:predecessor(prevIndex)
assert(tree.keys[prevIndex] == 10, "Failed: predecessor(nodeIndex) != 10")
assert(tree:predecessor(prevIndex) == nil, "Failed: last predecessor(nodeIndex) != nil")
print("Passed walking using predecessor.")

tree:delete(40)
tree:delete(30)
assert(isBalanced(tree, tree.root), "Tree is not balanced after multiple deletions")
print("Passed balance test after multiple deletions")

print("\nTesting floor, ceil, and range:")

-- Setup a tree with known values
tree:clear()
local values = {5, 7, 10, 15}
for _, value in ipairs(values) do
    tree:insert(value, tostring(value))
end

tree:clear()
local predIndex = tree:floor(10)
assert(predIndex == nil, "floor on empty tree should return nil")
print("Passed floor empty tree test")

-- Rebuild tree
for _, value in ipairs(values) do
    tree:insert(value, tostring(value))
end
-- Exact match
predIndex = tree:floor(7)
assert(predIndex ~= nil and tree.keys[predIndex] == 7, "floor(7) should return node with key 7")
-- Predecessor exists
predIndex = tree:floor(8)
assert(predIndex ~= nil and tree.keys[predIndex] == 7, "floor(8) should return node with key 7")
-- No predecessor (key < all keys)
predIndex = tree:floor(3)
assert(predIndex == nil, "floor(3) should return nil")
-- Largest key
predIndex = tree:floor(15)
assert(predIndex ~= nil and tree.keys[predIndex] == 15, "floor(15) should return node with key 15")
print("Passed floor tests")

tree:clear()
local succIndex = tree:ceil(10)
assert(succIndex == nil, "ceil on empty tree should return nil")
print("Passed findNodeOrSuccessor empty tree test")

-- Rebuild tree
for _, value in ipairs(values) do
    tree:insert(value, tostring(value))
end
-- Exact match
succIndex = tree:ceil(10)
assert(succIndex ~= nil and tree.keys[succIndex] == 10, "ceil(10) should return node with key 10")
-- Successor exists
succIndex = tree:ceil(8)
assert(succIndex ~= nil and tree.keys[succIndex] == 10, "ceil(8) should return node with key 10")
-- No successor (key > all keys)
succIndex = tree:ceil(20)
assert(succIndex == nil, "ceil(20) should return nil")
-- Smallest key
succIndex = tree:ceil(5)
assert(succIndex ~= nil and tree.keys[succIndex] == 5, "ceil(5) should return node with key 5")
print("Passed ceil tests")

-- Test range
-- Empty tree
tree:clear()
local keys = tree:range(5, 10)
assert(#keys == 0, "range on empty tree should return empty table")
print("Passed range empty tree test")

-- Rebuild tree
for _, value in ipairs(values) do
    tree:insert(value, tostring(value))
end
-- Full range
keys = tree:range(5, 15)
assert(#keys == 4 and keys[1] == 5 and keys[2] == 7 and keys[3] == 10 and keys[4] == 15, "range(5, 15) should return {5, 7, 10, 15}")
-- Partial range
keys = tree:range(6, 12)
assert(#keys == 2 and keys[1] == 7 and keys[2] == 10, "range(6, 12) should return {7, 10}")
-- Single key
keys = tree:range(7, 7)
assert(#keys == 1 and keys[1] == 7, "range(7, 7) should return {7}")
-- Empty range (minKey > maxKey)
keys = tree:range(10, 5)
assert(#keys == 0, "range(10, 5) should return empty table")
-- Out of bounds (below)
keys = tree:range(1, 3)
assert(#keys == 0, "range(1, 3) should return empty table")
-- Out of bounds (above)
keys = tree:range(20, 30)
assert(#keys == 0, "range(20, 30) should return empty table")
print("Passed range tests")

-- **Test Basic Operations and Iteration**
tree:clear()
tree:insert(3, "c")
tree:insert(1, "a")
tree:insert(2, "b")

for i, j in pairs(tree) do
    print(i, j)
end
local _, val = tree:get(1)
assert(val == "a", "Can't find inserted value a")
_, val = tree:get(2)
assert(val == "b", "Can't find inserted value b")
assert(tree:delete(2) == true, "Delete didn't work")
print("deleted 2")
assert(tree:delete(4) == false, "Delete returned true unexpectedly")
_, val = tree:get(3)
assert(val == "c", "Can't find inserted value c")
assert(tree:len() == 2, "length of tree nodes incorrect.")

tree:clear()

-- **Performance Test**
function test_performance(tree)
    print("\nTest performance, every round 1,000,000, then clear")
    local last = os.clock()
    local avg = 0
    for round = 1, 10 do
        local loop = 1000000
        while loop > 0 do
            loop = loop - 1
            tree:insert(loop, 0)
        end
        tree:clear()
        local now = os.clock()
        local elapsed = now - last
        avg = avg + elapsed
        print("round " .. round .. ": " .. elapsed .. "s, avg: " .. (avg / round) .. "s")
        last = now
    end
end

test_performance(tree)

-- Helper function to generate a table of unique random numbers
local function generate_random_keys(n, max_value)
    local keys = {}
    local used = {}
    while #keys < n do
        local key = math.random(1, max_value or 1000000)
        if not used[key] then
            used[key] = true
            table.insert(keys, key)
        end
    end
    return keys
end

-- Extended benchmark test suite
function test_extended_benchmarks(tree)
    print("\nExtended Benchmark Tests (1,000,000 operations each, random keys)")
    local n = 1000000
    local max_key = 10000000 -- Large range to reduce collisions
    local rounds = 5 -- Number of rounds for averaging

    -- Benchmark Insert with Random Keys
    print("\nBenchmark: Insert Random Keys")
    local insert_avg = 0
    for round = 1, rounds do
        tree:clear()
        local keys = generate_random_keys(n, max_key)
        local start_time = os.clock()
        for _, key in ipairs(keys) do
            tree:insert(key, key)
        end
        local elapsed = os.clock() - start_time
        insert_avg = insert_avg + elapsed
        print(string.format("Round %d: %.3fs", round, elapsed))
        tree:clear()
    end
    print(string.format("Insert Average: %.3fs", insert_avg / rounds))

    -- Prepare a tree with random keys for other benchmarks
    local keys = generate_random_keys(n, max_key)
    for _, key in ipairs(keys) do
        tree:insert(key, key)
    end
    -- Shuffle keys for random access in other benchmarks
    local shuffled_keys = {}
    for i, key in ipairs(keys) do
        shuffled_keys[i] = key
    end
    for i = #shuffled_keys, 2, -1 do
        local j = math.random(1, i)
        shuffled_keys[i], shuffled_keys[j] = shuffled_keys[j], shuffled_keys[i]
    end

    -- Benchmark Find (findNodeIndex)
    print("\nBenchmark: Find Random Keys")
    local find_avg = 0
    for round = 1, rounds do
        local start_time = os.clock()
        for _, key in ipairs(shuffled_keys) do
            tree:findNodeIndex(key)
        end
        local elapsed = os.clock() - start_time
        find_avg = find_avg + elapsed
        print(string.format("Round %d: %.3fs", round, elapsed))
    end
    print(string.format("Find Average: %.3fs", find_avg / rounds))

    -- Benchmark Get
    print("\nBenchmark: Get Random Keys")
    local get_avg = 0
    for round = 1, rounds do
        local start_time = os.clock()
        for _, key in ipairs(shuffled_keys) do
            tree:get(key)
        end
        local elapsed = os.clock() - start_time
        get_avg = get_avg + elapsed
        print(string.format("Round %d: %.3fs", round, elapsed))
    end
    print(string.format("Get Average: %.3fs", get_avg / rounds))

    -- Benchmark Delete
    print("\nBenchmark: Delete Random Keys")
    local delete_avg = 0
    for round = 1, rounds do
        -- Rebuild tree for each round
        tree:clear()
        for _, key in ipairs(keys) do
            tree:insert(key, key)
        end
        local start_time = os.clock()
        for _, key in ipairs(shuffled_keys) do
            tree:delete(key)
        end
        local elapsed = os.clock() - start_time
        delete_avg = delete_avg + elapsed
        print(string.format("Round %d: %.3fs", round, elapsed))
        tree:clear()
    end
    print(string.format("Delete Average: %.3fs", delete_avg / rounds))

    -- Rebuild tree for successor/predecessor benchmarks
    tree:clear()
    for _, key in ipairs(keys) do
        tree:insert(key, key)
    end

    -- Benchmark Successor
    print("\nBenchmark: Successor")
    local succ_avg = 0
    for round = 1, rounds do
        local start_time = os.clock()
        local index = tree:successor(nil) -- Start from smallest
        local count = 0
        while index and count < n do
            index = tree:successor(index)
            count = count + 1
        end
        local elapsed = os.clock() - start_time
        succ_avg = succ_avg + elapsed
        print(string.format("Round %d: %.3fs", round, elapsed))
    end
    print(string.format("Successor Average: %.3fs", succ_avg / rounds))

    -- Benchmark Predecessor
    print("\nBenchmark: Predecessor")
    local pred_avg = 0
    for round = 1, rounds do
        local start_time = os.clock()
        local index = tree:predecessor(nil) -- Start from largest
        local count = 0
        while index and count < n do
            index = tree:predecessor(index)
            count = count + 1
        end
        local elapsed = os.clock() - start_time
        pred_avg = pred_avg + elapsed
        print(string.format("Round %d: %.3fs", round, elapsed))
    end
    print(string.format("Predecessor Average: %.3fs", pred_avg / rounds))

    -- Benchmark Floor
    print("\nBenchmark: Floor Random Keys")
    local floor_avg = 0
    for round = 1, rounds do
        local start_time = os.clock()
        for _, key in ipairs(shuffled_keys) do
            tree:floor(key)
        end
        local elapsed = os.clock() - start_time
        floor_avg = floor_avg + elapsed
        print(string.format("Round %d: %.3fs", round, elapsed))
    end
    print(string.format("Floor Average: %.3fs", floor_avg / rounds))

    -- Benchmark Ceil
    print("\nBenchmark: Ceil Random Keys")
    local ceil_avg = 0
    for round = 1, rounds do
        local start_time = os.clock()
        for _, key in ipairs(shuffled_keys) do
            tree:ceil(key)
        end
        local elapsed = os.clock() - start_time
        ceil_avg = ceil_avg + elapsed
        print(string.format("Round %d: %.3fs", round, elapsed))
    end
    print(string.format("Ceil Average: %.3fs", ceil_avg / rounds))

    -- Benchmark Range
    print("\nBenchmark: Range Queries")
    local range_avg = 0
    -- Generate random min/max pairs
    local range_pairs = {}
    for i = 1, n / 100 do -- Fewer ranges for performance
        local min_key = math.random(1, max_key - 1000)
        local max_key = min_key + math.random(1, 1000)
        table.insert(range_pairs, { min_key, max_key })
    end
    for round = 1, rounds do
        local start_time = os.clock()
        for _, pair in ipairs(range_pairs) do
            tree:range(pair[1], pair[2])
        end
        local elapsed = os.clock() - start_time
        range_avg = range_avg + elapsed
        print(string.format("Round %d: %.3fs", round, elapsed))
    end
    print(string.format("Range Average: %.3fs (for %d ranges)", range_avg / rounds, #range_pairs))

    tree:clear()
end

-- Run the extended benchmarks
test_extended_benchmarks(tree)

print("\nAll tests passed!")
