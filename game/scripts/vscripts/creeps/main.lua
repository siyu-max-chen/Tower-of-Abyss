local CREEP = 'CREEP';
local LOAD_DATA = 'LOAD_DATA';
local CHANGE = 'CHANGE';
local INIT = 'INIT';

Creep = class({});

require('creeps/heroes/main');

local _ToACreepDataMap = {};

local _initHero = function(entity)
    if not entity:IsRealHero() then
        return;
    end

    local name = entity:GetUnitName();
    local hero = Hero:findHeroByName(name);

    if hero and hero._initialize then
        hero:_initialize(entity);
    end
end

function Creep:init(unit)
    if not unit or not unit:GetUnitName() or unit._ToAInit then
        return;
    end

    local name = unit:GetUnitName();
    unit._ToAInit = true;
    unit._ToAAbilitySlot = {};

    Battle:registerAttackEvent(unit);

    _initHero(unit);

    if _ToACreepDataMap[name] and #_ToACreepDataMap[name] then

        for attrName, value in pairs(_ToACreepDataMap[name]) do
            if attrName and value ~= 0 then
                local attribute = getAttributeByName(attrName);
                Battle.Attribute:incrementUnitAttribute(attribute, unit, value, true);
            end
        end
    end

    if isDebugEnabled(CREEP, INIT) then
        debugLog(CREEP, INIT, 'Creep init: ' .. Utility:formatUnitLog(unit));
    end
end

function Creep:_initialize()
    local dataTable = Data:getDataTable('CREEP_DATA');

    for creepName, table in pairs(dataTable) do
        _ToACreepDataMap[creepName] = {};

        for attrName, val in pairs(table) do
            _ToACreepDataMap[creepName][attrName] = tonumber(val);
        end
    end

    if isDebugEnabled(CREEP, LOAD_DATA) then
        debugLog(CREEP, LOAD_DATA, 'Creep Data Map is loaded: ');
        Utility:printObj(_ToACreepDataMap, '_ToACreepDataMap');
    end
end
