if _G.Utility == nil then
    _G.Utility = class({});
end

require('utils/logger');
require('utils/helper');

local _getDebugLevel = function (moduleName, eventName, eventObj, dataTable)
    local name = moduleName .. '.' .. eventName;

    if dataTable.applicable[name] ~= nil then
        return GAME.DEBUG.MAX;
    end

    if dataTable.whiteEvents[eventName] ~= nil then
        return GAME.DEBUG.MAX;
    end

    return tonumber(eventObj.debugLevel);
end

function Utility:_preloadData()
    if Utility.debugSettings ~= nil then
        return;
    end

    local dataTable = Data:getDataTable('DEBUG_DATA');
    local debugSettings = {};

    for moduleName, module in pairs(dataTable.debug) do
        debugSettings[moduleName] = {};

        for eventName, event in pairs(module) do
            debugSettings[moduleName][eventName] = {
                debugLevel = _getDebugLevel(moduleName, eventName, event, dataTable);
            };
        end
    end

    Utility.debugSettings = debugSettings;
end

function Utility:gameDebugLevel()
    return GAME.DEBUG.LEV2;
end

--- Determine whether (module, event) supports debug logging
--- will based on debug level and whilelist
--- only on the server sides
---@param moduleName string
---@param eventName string
---@return boolean
function Utility:isDebugEnable(moduleName, eventName)
    if not IsServer() then
        return false;
    end

    if not Utility.debugSettings then
        Utility:_preloadData();
    end

    local debugLevel = Utility.debugSettings[moduleName][eventName] and Utility.debugSettings[moduleName][eventName].debugLevel;
    return type(debugLevel) == 'number' and debugLevel >= Utility:gameDebugLevel();
end

function Utility:_initialize()
    -- initilize recursively
    for _, child in pairs(self) do
        if child and child ~= self and type(child) == 'table' and child._initialize and type(child._initialize) == 'function' then
            child:_initialize();
        end
    end

    Utility:_preloadData();
end
