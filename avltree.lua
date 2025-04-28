-- Very fast and efficient AVL Tree Implementation for lua and LuaJIT.
-- Specifically optimized for LuaJIT. An AVL Tree performs better than
-- a Red-black tree on LuaJIT due to less branches in the implementation
-- leading to better more predictable performance of the trace compiler.
--
-- Copyright 2025 Jeff Solinsky
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-- Default comparator function (supports non-numeric keys)
local function defaultKeyCompare(a, b)
    return (a < b and -1) or (a > b and 1) or 0
end

local LEFT = 1
local RIGHT = 2
local PARENT = 3
local HEIGHT = 4

-- Helper functions for node properties
local function getLeft(self, i)
    return self.nodes[4 * i + LEFT]
end

local function getRight(self, i)
    return self.nodes[4 * i + RIGHT]
end

local function getParent(self, i)
    return self.nodes[4 * i + PARENT]
end

local function getHeight(self, i)
    return self.nodes[4 * i + HEIGHT]
end

-- **AVLTree class definition**
local AVLTree = {
    getLeft = getLeft,
    getRight = getRight,
    getParent = getParent,
    getHeight = getHeight,
}

AVLTree.__index = AVLTree

function AVLTree:new(comparator)
    if comparator ~= nil and type(comparator) ~= "function" then
        error("comparator must be a function")
    end
    local tree = setmetatable({}, AVLTree)
    tree.root = nil
    tree.keysLen = 0
    tree.nodes = {}  -- Single table for left, right, parent, height
    tree.keys = {}
    tree.values = {}
    tree.comparator = comparator or defaultKeyCompare
    return tree
end

-- **Helper Functions**

-- Inserts a key-value pair at a given index
local function insertKey(self, base, index, key, value)
    local nodes = self.nodes
    self.keys[index] = key
    self.values[index] = value
    nodes[base + LEFT] = nil
    nodes[base + RIGHT] = nil
    nodes[base + PARENT] = nil
    nodes[base + HEIGHT] = 1
end

-- Removes a node by moving the last node to its position
local function removeKey(self, atIndex)
    local keysLen = self.keysLen
    if keysLen == 0 then return end
    local lastKeyIndex = keysLen - 1
    local nodes = self.nodes

    if atIndex == lastKeyIndex then
        -- Removing the last node
        self.keys[atIndex] = nil
        self.values[atIndex] = nil
        for i = 4 * atIndex + 1, 4 * (atIndex + 1) do
            nodes[i] = nil
        end
    else
        -- Move the last node to the deleted position
        local atBase = 4 * atIndex
        local lastBase = 4 * lastKeyIndex
        self.keys[atIndex] = self.keys[lastKeyIndex]
        self.values[atIndex] = self.values[lastKeyIndex]
        nodes[atBase + LEFT] = nodes[lastBase + LEFT]
        nodes[atBase + RIGHT] = nodes[lastBase + RIGHT]
        nodes[atBase + PARENT] = nodes[lastBase + PARENT]
        nodes[atBase + HEIGHT] = nodes[lastBase + HEIGHT]

        -- Update children's parent pointers
        local left = nodes[atBase + LEFT]
        if left then
            nodes[4 * left + PARENT] = atIndex
        end
        local right = nodes[atBase + RIGHT]
        if right then
            nodes[4 * right + PARENT] = atIndex
        end

        -- Update parent's child pointer
        local parent = nodes[atBase + PARENT]
        if parent then
            local parentBase = 4 * parent
            if nodes[parentBase + LEFT] == lastKeyIndex then
                nodes[parentBase + LEFT] = atIndex
            elseif nodes[parentBase + RIGHT] == lastKeyIndex then
                nodes[parentBase + RIGHT] = atIndex
            end
        elseif self.root == lastKeyIndex then
            self.root = atIndex
        end

        -- Clear the last index
        self.keys[lastKeyIndex] = nil
        self.values[lastKeyIndex] = nil
        for i = lastBase + 1, lastBase + 4 do
            nodes[i] = nil
        end
    end
    self.keysLen = lastKeyIndex
end

local function getLeftRightHeights(nodes, base)
    local left = nodes[base + LEFT]
    local leftHeight = left and nodes[4 * left + HEIGHT] or 0
    local right = nodes[base + RIGHT]
    local rightHeight = right and nodes[4 * right + HEIGHT] or 0
    return leftHeight, rightHeight
end

-- Updates a node's height
local function updateHeight(nodes, base)
    local leftHeight, rightHeight = getLeftRightHeights(nodes, base)
    local maxHeight = (leftHeight > rightHeight) and leftHeight or rightHeight
    nodes[base + HEIGHT] = maxHeight + 1
end

-- Calculates balance factor
local function getBalanceFactor(nodes, index)
    local leftHeight, rightHeight = getLeftRightHeights(nodes, 4 * index)
    return leftHeight - rightHeight
end

-- Updates a node's height and returns balance factor
local function updateHeightAndGetBalanceFactor(nodes, base)
    local leftHeight, rightHeight = getLeftRightHeights(nodes, base)
    local maxHeight = (leftHeight > rightHeight) and leftHeight or rightHeight
    nodes[base + HEIGHT] = maxHeight + 1
    return leftHeight - rightHeight
end

-- Right rotation
local function rotateRight(self, y)
    local nodes = self.nodes
    local yBase = 4 * y
    local x = nodes[yBase + LEFT]
    if not x then return y end
    local xBase = 4 * x
    local T2 = nodes[xBase + RIGHT]
    nodes[xBase + RIGHT] = y
    nodes[yBase + LEFT] = T2
    if T2 then nodes[4 * T2 + PARENT] = y end
    local parent = nodes[yBase + PARENT]
    nodes[xBase + PARENT] = parent
    if parent then
        local parentBase = 4 * parent
        if nodes[parentBase + LEFT] == y then
            nodes[parentBase + LEFT] = x
        else
            nodes[parentBase + RIGHT] = x
        end
    else
        self.root = x
    end
    nodes[yBase + PARENT] = x
    updateHeight(nodes, yBase)
    updateHeight(nodes, xBase)
    return x
end

-- Left rotation
local function rotateLeft(self, x)
    local nodes = self.nodes
    local xBase = 4 * x
    local y = nodes[xBase + RIGHT]
    if not y then return x end
    local yBase = 4 * y
    local T2 = nodes[yBase + LEFT]
    nodes[yBase + LEFT] = x
    nodes[xBase + RIGHT] = T2
    if T2 then nodes[4 * T2 + PARENT] = x end
    local parent = nodes[xBase + PARENT]
    nodes[yBase + PARENT] = parent
    if parent then
        local parentBase = 4 * parent
        if nodes[parentBase + LEFT] == x then
            nodes[parentBase + LEFT] = y
        else
            nodes[parentBase + RIGHT] = y
        end
    else
        self.root = y
    end
    nodes[xBase + PARENT] = y
    updateHeight(nodes, xBase)
    updateHeight(nodes, yBase)
    return y
end

-- Balances a subtree
local function balance(self, index)
    local nodes = self.nodes
    local base = 4 * index
    local bf = updateHeightAndGetBalanceFactor(nodes, base)
    if bf > 1 then
        local left = nodes[base + LEFT]
        if left and getBalanceFactor(nodes, left) < 0 then
            nodes[base + LEFT] = rotateLeft(self, left)
        end
        return rotateRight(self, index)
    elseif bf < -1 then
        local right = nodes[base + RIGHT]
        if right and getBalanceFactor(nodes, right) > 0 then
            nodes[base + RIGHT] = rotateRight(self, right)
        end
        return rotateLeft(self, index)
    end
    return index
end

-- **Public Methods**

function AVLTree:insert(key, value)
    local index = self.keysLen
    self.keysLen = index + 1
    local base = 4 * index
    insertKey(self, base, index, key, value)
    if not self.root then
        self.root = index
        return index
    end

    local nodes = self.nodes
    local current = self.root
    local parent
    while current do
        parent = current
        local cmp = self.comparator(key, self.keys[current])
        local currentBase = 4 * current
        if cmp < 0 then
            current = nodes[currentBase + LEFT]
        elseif cmp > 0 then
            current = nodes[currentBase + RIGHT]
        else
            self.values[current] = value  -- Update value if key exists
            self.keysLen = self.keysLen - 1
            return current
        end
    end

    nodes[base + PARENT] = parent
    if self.comparator(key, self.keys[parent]) < 0 then
        nodes[parent * 4 + LEFT] = index
    else
        nodes[parent * 4 + RIGHT] = index
    end

    -- Balance the tree
    local node = parent
    while node do
        local oldHeight = nodes[4 * node + HEIGHT]
        node = balance(self, node)
        local nodeBase = 4 * node
        if nodes[nodeBase + HEIGHT] == oldHeight then break end
        node = nodes[nodeBase + PARENT]
    end
    return index
end

function AVLTree:findNodeIndex(key)
    local current = self.root
    while current do
        local cmp = self.comparator(key, self.keys[current])
        local currentBase = 4 * current
        if cmp < 0 then
            current = self.nodes[currentBase + LEFT]
        elseif cmp > 0 then
            current = self.nodes[currentBase + RIGHT]
        else
            return current
        end
    end
    return nil
end

-- Finds minimum node index in a subtree
local function minValueNode(nodes, current)
    while true do
        local nextNode = nodes[4 * current + LEFT]
        if not nextNode then break end
        current = nextNode
    end
    return current
end

function AVLTree:deleteByNodeIndex(index)
    if not index or not self.keys[index] then return false end
    local nodes = self.nodes

    -- Two children case
    local base = 4 * index
    local left = nodes[base + LEFT]
    local right = nodes[base + RIGHT]
    if left and right then
        local successor = minValueNode(nodes, right)
        self.keys[index] = self.keys[successor]
        self.values[index] = self.values[successor]
        index = successor
        base = 4 * index  -- Update base for new index
    end

    -- Replace with child or remove
    local child = nodes[base + LEFT] or nodes[base + RIGHT]
    local parent = nodes[base + PARENT]
    if child then self.nodes[4 * child + PARENT] = parent end
    if not parent then
        self.root = child
    else
        local parentBase = 4 * parent
        if nodes[parentBase + LEFT] == index then
            nodes[parentBase + LEFT] = child
        else
            nodes[parentBase + RIGHT] = child
        end
    end

    removeKey(self, index)

    -- Balance upwards
    local node = parent
    while node do
        local oldHeight = nodes[4 * node + HEIGHT]
        node = balance(self, node)
        local nodeBase = 4 * node
        if nodes[nodeBase + HEIGHT] == oldHeight then break end
        node = nodes[nodeBase + PARENT]
    end
    return true
end

function AVLTree:delete(key)
    local index = self:findNodeIndex(key)
    if not index then return false end
    return self:deleteByNodeIndex(index)
end

function AVLTree:clear()
    self.root = nil
    self.keysLen = 0
    self.nodes = {}
    self.keys = {}
    self.values = {}
end

function AVLTree:get(key)
    local index = self:findNodeIndex(key)
    if not index then return nil end
    return self.keys[index], self.values[index]
end

function AVLTree:getKeyVal(index)
    return self.keys[index], self.values[index]
end

-- Note: If you want to ensure a node index obtained is still valid after other operations have been performed on the
--       tree, store the key along with the index returned and use getKeyVal(index) to ensure the key at the
--       index has not changed. This allows you to potentially walk the tree while allowing it to be modified in between
--       calls if desired, by yielding to other coroutines after insert or delete.
function AVLTree:nextNodeIndex(index)
    if not index then
        if not self.root then return nil end
        index = self.root
        local left = self.nodes[4 * index + LEFT]
        while left do
            index = left
            left = self.nodes[4 * index + LEFT]
        end
        return index
    end

    local base = 4 * index
    local right = self.nodes[base + RIGHT]
    if right then
        index = right
        local left = self.nodes[4 * index + LEFT]
        while left do
            index = left
            left = self.nodes[4 * index + LEFT]
        end
        return index
    end

    local parent = self.nodes[base + PARENT]
    while parent do
        local parentBase = 4 * parent
        if index == self.nodes[parentBase + RIGHT] then
            index = parent
            parent = self.nodes[parentBase + PARENT]
        else
            return parent
        end
    end
    return nil
end

function AVLTree:prevNodeIndex(index)
    if not index then
        if not self.root then return nil end
        index = self.root
        local right = self.nodes[4 * index + RIGHT]
        while right do
            index = right
            right = self.nodes[4 * index + RIGHT]
        end
        return index
    end

    local base = 4 * index
    local left = self.nodes[base + LEFT]
    if left then
        index = left
        local right = self.nodes[4 * index + RIGHT]
        while right do
            index = right
            right = self.nodes[4 * index + RIGHT]
        end
        return index
    end

    local parent = self.nodes[base + PARENT]
    while parent do
        local parentBase = 4 * parent
        if index == self.nodes[parentBase + LEFT] then
            index = parent
            parent = self.nodes[parentBase + PARENT]
        else
            return parent
        end
    end
    return nil
end

function AVLTree:findIndexOfNodeOrPredecessor(key)
    local current = self.root
    local predecessor = nil
    while current do
        local cmp = self.comparator(key, self.keys[current])
        if cmp == 0 then return current
        elseif cmp < 0 then
            current = self.nodes[4 * current + LEFT]
        else
            predecessor = current
            current = self.nodes[4 * current + RIGHT]
        end
    end
    return predecessor
end

function AVLTree:range(minKey, maxKey)
    local result = {}
    local current = self:ceil(minKey)
    while current do
        local nodeKey = self.keys[current]
        if self.comparator(nodeKey, maxKey) > 0 then break end
        table.insert(result, nodeKey)
        current = self:successor(current)
    end
    return result
end

function AVLTree:forEachInRange(minKey, maxKey, fn)
    local current = self:ceil(minKey)
    while current do
        local nodeKey = self.keys[current]
        if self.comparator(nodeKey, maxKey) > 0 then break end
        local ret = fn(nodeKey, self.values[current])
        if ret ~= nil then return ret end
        current = self:successor(current)
    end
end

function AVLTree:findIndexOfNodeOrSuccessor(key)
    local current = self.root
    local successor = nil
    while current do
        local cmp = self.comparator(key, self.keys[current])
        if cmp == 0 then return current
        elseif cmp < 0 then
            successor = current
            current = self.nodes[4 * current + LEFT]
        else
            current = self.nodes[4 * current + RIGHT]
        end
    end
    return successor
end

function AVLTree:__pairs()
    local index = self:successor(nil)
    return function()
        if not index then return nil end
        local key, value = self.keys[index], self.values[index]
        index = self:successor(index)
        return key, value
    end
end

-- **Aliases and Utility**
AVLTree.add = AVLTree.insert
AVLTree.remove = AVLTree.delete
AVLTree.successor = AVLTree.nextNodeIndex
AVLTree.predecessor = AVLTree.prevNodeIndex
AVLTree.floor = AVLTree.findIndexOfNodeOrPredecessor
AVLTree.ceil = AVLTree.findIndexOfNodeOrSuccessor


function AVLTree:len()
    return self.keysLen
end

return AVLTree
