if _G.Cache == nil then
    _G.Cache = class({});
end

local CACHE = 'CACHE';

local logEvents = {
    SET = 'SET', REMOVE = 'REMOVE', CACHEDATA = 'CACHEDATA',
    TIMER = 'TIMER', ERROR = 'ERROR',
};

LinkLuaModifier('modifier_simple_cache', 'cache/simple_cache.lua', LUA_MODIFIER_MOTION_NONE);

function Cache:_initialize()
    Cache._cache = {};
    Cache._expireTable = {};

    if IsServer() then
        Cache._cacheSysTime = 0;
    end

    CreateModifierThinker(nil, ABILITY_EFFECT_DUMMY, 'modifier_simple_cache', {}, Vector(0, 0, 0), 0, false);
end

function Cache:_getCurrentTime()
    return Cache._cacheSysTime;
end

--- get expiration time in unified format
---@param ttl number
---@return number expirationTime
function Cache:_getExpirationTime (ttl)
    if not ttl then
        ttl = GAME.CACHE.DEFAULT_TTL;
    end

    local currentTime = Cache:_getCurrentTime();
    local time = currentTime + math.min( 1, math.floor(  (ttl + 0.5 * GAME.CACHE.REFRESH_INTERVAL) / GAME.CACHE.REFRESH_INTERVAL  ) );

    return math.floor(time);
end

function Cache:_registerEntry(entry)
    -- if existed, return the one
    if Cache._cache[entry] ~= nil then
        return;
    end

    local entryTable = {
        size = 0,
        mark = 0,                  -- will be used for create ids
        keyMap = {},               -- ids [cacheId, cacheKey]  ['ability_blizzard_1', ]
        dataMap = {},              -- [index, obj]  [0, { ttl, eg..., data } ]
    };

    Cache._cache[entry] = entryTable;
end

--- Generate cache id based on the type as entry
---@param entry string
---@return string cacheId
function Cache:_generateCacheId(entry)
    Cache:_registerEntry(entry);

    local entryTable = Cache._cache[entry];
    local cacheId = tostring(entry) .. tostring(entryTable.mark + 1);

    local key = entryTable.size + 1;

    entryTable.keyMap[cacheId] = key;

    entryTable.mark = entryTable.mark + 1;
    entryTable.size = entryTable.size + 1;

    return cacheId;
end

function Cache:_registerExpireEvent(entry, cacheId, expireAt)
    if (expireAt <= Cache:_getCurrentTime()) then

        if isDebugEnabled(CACHE, logEvents.ERROR) then
            debugLog(CACHE, logEvents.ERROR,  'Failed to register Cache-Expire event, cache id is: ' .. tostring(cacheId) .. ' , expected expiration is: ' .. tostring(expireAt));
        end

        return;
    end

    local cacheInfo = {
        cacheId = cacheId,
        entry = entry,
    };

    if Cache._expireTable[expireAt] == nil then
        Cache._expireTable[expireAt] = {};
    end

    local index = #Cache._expireTable[expireAt] + 1;
    Cache._expireTable[expireAt][index] = cacheInfo;
end

--- Save Obj into cache, return the cache id
---@param entry string
---@param obj object
---@return string cacheId
function Cache:set(entry, obj, type, ttl)
    if not type then
        type = GAME.CACHE.NONE_TYPE;
    end

    if not ttl then
        ttl = GAME.CACHE.DEFAULT_TTL;
    end

    local cacheId = Cache:_generateCacheId(entry);

    local entryTable = Cache._cache[entry];

    local key = entryTable.keyMap[cacheId];
    local expireAt = Cache:_getExpirationTime(ttl);

    entryTable.dataMap[key] = {
        cacheId = cacheId,
        expireAt = expireAt,
        type = type,
        obj = obj,
    };

    Cache:_registerExpireEvent(entry, cacheId, expireAt);

    if isDebugEnabled(CACHE, logEvents.SET) then
        debugLog(CACHE, logEvents.SET, (Utility:formatObjLog(obj) .. ' is registered: ' .. ' entry: ' .. tostring(entry) .. ', cache id: ' .. tostring(cacheId) .. ' expiration: ' .. tostring(expireAt)));
    end

    return cacheId;
end

--- Get object from cache, return the cached object
---@param entry string
---@param cacheId string
---@return object|nil cachedObject
function Cache:get(entry, cacheId)
    if not IsServer() then
        return nil;
    end
    
    if not entry or not cacheId or not Cache._cache[entry] then
        return nil;
    end

    local entryTable = Cache._cache[entry];

    local key = entryTable.keyMap[cacheId];
    local data = entryTable.dataMap[key];

    return data and data.obj or nil;
end

--- Remove cached obj from cache, return the cached object
---@param entry string
---@param cacheId string
---@return object|nil cachedObject
function Cache:remove(entry, cacheId)
    if not IsServer() then
        return;
    end
    
    if not entry or not cacheId or not Cache._cache[entry] or not Cache._cache[entry].keyMap[cacheId] then
        if isDebugEnabled(CACHE, REMOVE) then
            debugLog(CACHE, REMOVE, ('Remove cache NOT EXISTED: ' .. ' cache id: ' .. tostring(cacheId)));
        end

        return nil;
    end

    local entryTable = Cache._cache[entry];

    local key = entryTable.keyMap[cacheId];
    local lastKey = entryTable.size;

    local data = entryTable.dataMap[key];
    local cachedObj = data.obj;

    -- 如果删除的不是最后一个位置
    if key ~= entryTable.size then
        local exchangeData = entryTable.dataMap[lastKey];
        local exchangeId = exchangeData.cacheId;

        -- swap key
        entryTable.keyMap[exchangeId] = key;
        entryTable.dataMap[key] = exchangeData;

        entryTable.keyMap[cacheId] = lastKey;
        entryTable.dataMap[lastKey] = data;
    end

    entryTable.size = entryTable.size - 1;

    -- 清理 id table
    entryTable.keyMap[cacheId] = nil;
    -- 清理 data table
    entryTable.dataMap[lastKey] = nil;
    data.obj = nil;

    if isDebugEnabled(CACHE, logEvents.REMOVE) then
        debugLog(CACHE, logEvents.REMOVE, ('Remove cache Succeefully: ' .. ' cache id: ' .. tostring(cacheId) .. ' obj is: ' .. Utility:formatObjLog(cachedObj)));
    end

    return cachedObj;
end

modifier_simple_cache = class({});

function modifier_simple_cache:OnCreated(params)
    Cache._cacheSysTime = 0;
    self._dataObj = {};

    if isDebugEnabled(CACHE, logEvents.TIMER) then
        debugLog(CACHE, logEvents.TIMER, ('Cache Refresh is starting the task **********'));
    end

    self:SetDuration(1000000, true);
    self:StartIntervalThink(GAME.CACHE.REFRESH_INTERVAL);
end

function modifier_simple_cache:OnIntervalThink()
    local dataObj = self._dataObj;
    local expireTable = Cache._expireTable;
    local currentTime = Cache:_getCurrentTime();

    if isDebugEnabled(CACHE, logEvents.TIMER) then
        debugLog(CACHE, logEvents.TIMER, ('Cache System time ********** ' .. tostring(Cache._cacheSysTime)));
    end

    if expireTable and expireTable[currentTime] and #expireTable[currentTime] then

        for _, cacheInfo in pairs(expireTable[currentTime]) do
            local cacheId = cacheInfo.cacheId;
            local entry = cacheInfo.entry;

            local cachedObj = Cache:remove(entry, cacheId);

            expireTable[currentTime][_] = nil;
        end

        expireTable[currentTime] = nil;
    end

    if isDebugEnabled(CACHE, logEvents.CACHEDATA) then
        debugLog(CACHE, logEvents.CACHEDATA, ('Current Cached data: '));
        Utility:printObj(Cache._cache, 'Current Cache Table');
    end

    if IsServer() then
        Cache._cacheSysTime = Cache._cacheSysTime + 1;
    end
end
