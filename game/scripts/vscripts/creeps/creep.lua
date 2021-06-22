local CREEP = 'CREEP';
local logEvents = {
    EVENTS = 'EVENTS', ERROR = 'ERROR', LOAD_DATA = 'LOAD_DATA',
    INIT = 'INIT',
};

Creep = class({});

require('creeps/heroes/main');

--- constructor of new Creep
---@param type string - unit type, ususally is the name
---@param playerId number - player id
---@param originVec Vector - creation position
---@param initializer function - optional
---@param skipCreationInstance unit - if provide this, will not create a new instance
---@return table
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

    if isDebugEnabled(CREEP, logEvents.EVENTS) then
        debugLog(CREEP, logEvents.EVENTS, '{ Creating new creep instance }: ' .. Utility:formatUnitLog(obj._instance));
    end

    return obj;
end

function Creep:_initHero(instance)
    if not instance:IsRealHero() then
        return;
    end

    local name = instance:GetUnitName();
    local hero = Hero:findHeroByName(name);

    if hero and hero._initialize then
        hero:_initialize(instance);
    end
end

--- handler that will be used to initilize creep (attr modify, event register...)
---@param entity creep
---@param initializer function
function Creep:init(entity, initializer)
    if not entity or not entity._instance or entity._isInit or not entity._instance:GetUnitName() then
        if isDebugEnabled(CREEP, logEvents.ERROR) then
            debugLog(CREEP, logEvents.ERROR, 'Error: failed to initialize the creep entity: ' .. tostring(entity));
        end

        return;
    end

    entity._isInit = true;
    local instance = entity._instance;

    local name = instance:GetUnitName();
    instance._ToAAbilitySlot = {};

    Battle:registerAttackEvent(entity);

    Creep:_initHero(instance);

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

    if isDebugEnabled(CREEP, logEvents.INIT) then
        debugLog(CREEP, logEvents.INIT, '{ Creep init }: ' .. Utility:formatUnitLog(instance));
    end
end
