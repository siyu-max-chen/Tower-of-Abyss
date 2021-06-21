local CREEP = 'CREEP';
local NEW = 'NEW';
local ERROR = 'ERROR';
local LOAD_DATA = 'LOAD_DATA';
local CHANGE = 'CHANGE';
local INIT = 'INIT';

Creep = class({});

require('creeps/heroes/main');

function Creep:new(type, playerId, originVec, initializer, skipCreationInstance)    
    local obj = {};
    setmetatable(obj, self);
    self.__index = self;

    if not originVec then
        originVec = Vector(0, 0, 0);
    end

    -- create unit, make association between instance and creep obj
    obj._instance = skipCreationInstance or CreateUnitByName(type, originVec, true, nil, nil, playerId);
    obj._instance._entity = obj;

    -- init creep events and load other initializer
    self:init(obj, initializer);

    if isDebugEnabled(CREEP, NEW) then
        debugLog(CREEP, NEW, 'Create a new creep (unit instance): ' .. Utility:formatUnitLog(obj._instance));
    end

    return obj;
end

local _initHero = function(instance)
    if not instance:IsRealHero() then
        return;
    end

    local name = instance:GetUnitName();
    local hero = Hero:findHeroByName(name);

    if hero and hero._initialize then
        hero:_initialize(instance);
    end

    if isDebugEnabled(CREEP, INIT) then
        debugLog(CREEP, INIT, 'Hero init: ' .. Utility:formatUnitLog(instance));
    end
end

function Creep:init(entity, initializer)
    if not entity or not entity._instance or entity._isInit or not entity._instance:GetUnitName() then
        if isDebugEnabled(CREEP, ERROR) then
            debugLog(CREEP, INIT, 'Error: failed to initialize the creep entity: ' .. tostring(entity));
        end

        return;
    end

    entity._isInit = true;
    local instance = entity._instance;

    local name = instance:GetUnitName();
    instance._ToAAbilitySlot = {};

    Battle:registerAttackEvent(entity);

    _initHero(instance);

    -- modify instance's attribute based on the preloaded data
    local creepData = Data:getData('CREEPDATA');
    if creepData[name] and #creepData[name] then
        for attrName, value in pairs(creepData[name]) do
            if attrName and value ~= 0 then
                local attribute = getAttributeByName(attrName);
                Battle.Attribute:incrementUnitAttribute(attribute, instance, value, true);
            end
        end
    end

    if isDebugEnabled(CREEP, INIT) then
        debugLog(CREEP, INIT, 'Creep init: ' .. Utility:formatUnitLog(instance));
    end
end
