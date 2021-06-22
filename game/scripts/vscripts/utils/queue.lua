local HELPER = 'HELPER';

local logEvents = {
    EVENTS = 'EVENTS',
    CREATE = 'CREATE', ADD = 'ADD', POLL = 'POLL',
};

TreeNode = class({});

function TreeNode:new(data, left, right, parent)
    local obj = {
        data = data or nil,
        left = left or nil,
        right = right or nil,
        parent = parent or nil,
    };

    setmetatable(obj, self);
    self.__index = self;
    return obj;
end

function TreeNode:traverse(treeNode)
    if treeNode == nil then
        return print('TreeNode: ' .. 'nil');
    end

    TreeNode:traverse(treeNode.left);

    print('TreeNode: ' .. tostring(treeNode.data.val));

    TreeNode:traverse(treeNode.right);
end

function TreeNode:add(obj, compareFunc)
    -- 存在问题的情况
    if self.data == nil then
        return;
    end

    local isLargerThanNode = compareFunc(obj, self.data) >= 0;

    if isLargerThanNode then
        if self.right == nil then
            self.right = TreeNode:new(obj, nil, nil, self);
            return;
        end

        self.right:add(obj, compareFunc);
        return;
    else
        if self.left == nil then
            self.left = TreeNode:new(obj, nil, nil, self);
            return;
        end

        self.left:add(obj, compareFunc);
        return;
    end
end

function TreeNode:findFirst()
    if self.data == nil then
        return nil;
    end

    if self.left ~= nil then
        return self.left:findFirst();
    end

    return self;
end

function TreeNode:clearNode()
    self.left = nil; self.right = nil; self.parent = nil;
end

PriorityQueue = class({});

function PriorityQueue:new(capacity, compareFunc)
    local obj = {
        size = 0,
        capacity = capacity,
        root = nil,
        compareFunc = compareFunc,
    };

    setmetatable(obj, self);
    self.__index = self;

    if isDebugEnabled(HELPER, logEvents.CREATE) then
        debugLog(HELPER, logEvents.CREATE, '{ New Priority Queue }: ' .. tostring(obj) .. ' , Capacity is: ' .. tostring(capacity));
    end

    return obj;
end

function PriorityQueue:peekNode()
    if self.size == 0 or self.root == nil then
        return nil;
    end

    local node = self.root:findFirst();
    return node;
end

function PriorityQueue:peek()
    local peekNode = self:peekNode();

    if peekNode == nil then
        return nil;
    end

    return peekNode.data;
end

function PriorityQueue:poll()
    local treeNode = self:peekNode();
    local result = nil;

    if treeNode == nil then
        return result;
    end

    self.size = self.size - 1;
    result = treeNode.data;

    if self.size == 0 then
        self.root = nil;

        if isDebugEnabled(HELPER, logEvents.POLL) then
            debugLog(HELPER, logEvents.POLL, '{ Priority Queue }: ' .. tostring(self) .. ' , Polled data is: ' .. tostring(result));
        end

        return result;
    end

    -- 删除该节点, 该节点必然没有 left 节点, 且如果存在 parent,  他必然是 parent 的 left 节点
    -- 1. 如果该节点存在 parent 和 right
    if treeNode.parent ~= nil and treeNode.right ~= nil then
        treeNode.parent.left = treeNode.right;
        treeNode.right.parent = treeNode.parent;
        treeNode:clearNode();

        if isDebugEnabled(HELPER, logEvents.POLL) then
            debugLog(HELPER, logEvents.POLL, '{ Priority Queue }: ' .. tostring(self) .. ' , Polled data is: ' .. tostring(result));
        end
        
        return result;
    end

    -- 2. 如果该节点存在 parent, 但不存在 right: 他必然是 parent 的 left 节点
    if treeNode.parent ~= nil and treeNode.right == nil then
        treeNode.parent.left = nil;
        treeNode:clearNode();

        if isDebugEnabled(HELPER, logEvents.POLL) then
            debugLog(HELPER, logEvents.POLL, '{ Priority Queue }: ' .. tostring(self) .. ' , Polled data is: ' .. tostring(result));
        end

        return result;
    end

    -- 3. 如果不存在 parent 但是存在 right: 他必然是 root, 则移位 root
    if treeNode.parent == nil and treeNode.right ~= nil then
        self.root = treeNode.right;
        self.root.parent = nil;
        treeNode:clearNode();

        if isDebugEnabled(HELPER, logEvents.POLL) then
            debugLog(HELPER, logEvents.POLL, '{ Priority Queue }: ' .. tostring(self) .. ' , Polled data is: ' .. tostring(result));
        end

        return result;
    end

    if isDebugEnabled(HELPER, logEvents.POLL) then
        debugLog(HELPER, logEvents.POLL, '{ Priority Queue }: ' .. tostring(self) .. ' , Polled data is: ' .. tostring(result));
    end

    return result;
end

function PriorityQueue:add(obj)
    -- no error/exception in this case
    if isDebugEnabled(HELPER, logEvents.ADD) then
        debugLog(HELPER, logEvents.ADD, '{ Priority Queue }: ' .. tostring(self) .. ' , adding data: ' .. tostring(obj));
    end

    if self.size == 0 or self.root == nil then
        self.root = TreeNode:new(obj, nil, nil, nil);
        self.size = 1;
        return;
    end

    self.size = self.size + 1;
    self.root:add(obj, self.compareFunc);

    if self.size > self.capacity then
        if isDebugEnabled(HELPER, logEvents.ADD) then
            debugLog(HELPER, logEvents.ADD, '{ Priority Queue }: ' .. tostring(self) .. ' , Size is larger than Capacity, polling from PQ.');
        end
        
        self:poll();
    end
end
