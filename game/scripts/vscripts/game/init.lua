_G.GAME = class({});
require('game/constants');

require('data/main');
require('utils/main');

require('cache/simple_cache');

require('battle/main');
require('boosters/main');

require('modifiers/modifier');

require('effects/particle');
require('effects/ability_effect_dummy');
require('effects/effect');
require('effects/missile');
require('effects/range');

require('abilities/main');

require('creeps/main');

function initAbilityDummy()
    if (isAbilityDummyInit) then
        return;
    end

    _G.isAbilityDummyInit = true;

    local dummyPlayerIndex = -1;
    _G.UNIT_DUMMY = CreateUnitByName('npc_dummy_unit', Vector(0, 0, 0), false, nil, nil, dummyPlayerIndex);

    local ability = UNIT_DUMMY:FindAbilityByName('ability_effect_dummy');
    UNIT_DUMMY:CastAbilityImmediately(ability, UNIT_DUMMY:GetPlayerOwnerID());
end

function _initialize()
    _G.Data = Data;                     Data:_initialize();
    _G.Utility = Utility;               Utility:_initialize();

    _G.Cache = Cache;                   Cache:_initialize();

    _G.Battle = Battle;                 Battle:_initialize();
    _G.Booster = Booster;               Booster:_initialize();
    _G.Particle = Particle;
    _G.ToAEffect = ToAEffect;

    Modifier:_initialize();

    _G.Ability = Ability;               Ability:_initialize();
    _G.Creep = Creep;                   Creep:_initialize();
    _G.Hero = Hero;                     Hero:_initialize();

    _G.isDebugEnabled = isDebugEnabled;
    _G.debugLog = debugLog;
    _G.getExpirationTime = getExpirationTime;

    initAbilityDummy();

    ToAGame.debugLevel = GAME.DEBUG.LEV0;

    _G.getTestUnit = function ()
        return Hero.IceSorceress._entity;
    end
end

--- Check whether debug mode is enabled for this [module, event]
---@param module string
---@param event string
---@return boolean
function isDebugEnabled(module, event)
    return Utility:isDebugEnable(module, event);
end

--- debug log with module and event
---@param module string required
---@param event string required
---@param message string required
function debugLog(module, event, message)
    if not isDebugEnabled(module, event) then
        return;
    end

    local log = '[DEBUG][' .. module .. ']' .. '[' .. event .. ']: ' .. tostring(message);

    print(log);
end

--- get expiration time in unified format
---@param ttl number
---@return number expirationTime
function getExpirationTime (ttl)
    if not ttl then
        ttl = GAME.CACHE.DEFAULT_TTL;
    end

    return math.floor(ttl + Time());
end

_initialize();
