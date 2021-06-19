Booster = class({});

local BOOSTER = 'BOOSTER';
local CHANGE = 'CHANGE';
local LOAD_DATA = 'LOAD_DATA';

require('boosters/generic');

function Booster:_formatChangeLog(booster, unit, level)
    return Utility:formatUnitLog(unit) .. ' ' .. booster.name .. ' level is: ' .. tostring(level);
end

function Booster:_isValidBooster(booster)
    return booster and booster ~= nil and booster.name and true or false;
end

function Booster:_getBoosterUpdateInfo(booster, prevLev, nextLev)
    prevLev = math.min(prevLev, booster.maxLevel);
    nextLev = math.min(nextLev, booster.maxLevel);

    return {
        isNoUpdate = prevLev == nextLev,
        isIncrement = nextLev > prevLev,
        isMax = prevLev == booster.maxLevel or nextLev == booster.maxLevel,
        min = math.min(prevLev, nextLev),
        max = math.max(prevLev, nextLev)
    };
end

function Booster:_initSingleBoosterTable(boosterName, boosterTable)
    local result = {};

    result.name = boosterName;
    result.maxLevel = tonumber(boosterTable.maxLevel);

    result.values = {};
    for index, val in pairs(boosterTable.values) do
        result.values[tonumber(index)] = tonumber(val) or 0;
    end

    result.callback = Booster[boosterTable.callback];

    Booster.ENUM[boosterName] = result;
end

function Booster:_initialize()
    Booster.ENUM = {};
    local dataTable = Data:getDataTable('BOOSTER', 'ENUM');

    if dataTable then
        for boosterName, val in pairs(dataTable) do
            Booster:_initSingleBoosterTable(boosterName, Data:getDataTable('BOOSTER', boosterName));
        end
    end

    -- initilize recursion
    for _, child in pairs(self) do
        if child and child ~= self and type(child) == 'table' and child._initialize and type(child._initialize) ==
            'function' then
            child:_initialize();
        end
    end

    if isDebugEnabled(BOOSTER, LOAD_DATA) then
        debugLog(BOOSTER, LOAD_DATA,
            'Booster ENUM table is loaded:');
        Utility:printObj(Booster.ENUM, 'Booster.ENUM')
    end
end

function Booster:getBoosterLevel(booster, unit)
    if not Booster:_isValidBooster(booster) then
        return 0;
    end

    return unit._Boosters and unit._Boosters[booster.name] and unit._Boosters[booster.name].level or 0;
end

function Booster:incrementBooster(booster, unit, level, isIncrement)
    if not Booster:_isValidBooster(booster) then
        return;
    end

    if unit._Boosters == nil then
        unit._Boosters = {};
    end

    local boosterInfo = unit._Boosters[booster.name] or {};
    local prevLev = boosterInfo.level or 0;
    local nextLev = prevLev;

    if isIncrement == true then
        nextLev = nextLev + level;
    else
        nextLev = nextLev - level;
    end

    booster.callback(Booster, unit, prevLev, nextLev);

    boosterInfo.level = nextLev;
    unit._Boosters[booster.name] = boosterInfo;

    if isDebugEnabled(BOOSTER, CHANGE) then
        debugLog(BOOSTER, CHANGE, Booster:_formatChangeLog(booster, unit, nextLev));
    end
end
