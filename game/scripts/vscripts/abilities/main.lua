Ability = class({});

local ABILITY = 'ABILITY';
local LOAD_DATA = 'LOAD_DATA';
local PRECAST = 'PRECAST';
local INTERRUPT = 'INTERRUPT';
local CAST = 'CAST';
local SUCCESS = 'SUCCESS';
local CHECK = 'CHECK';
local EVENT = 'EVENT';

Ability.Amplifier = {
    RED = 'red',
    GREEN = 'green',
    BLUE = 'blue',
};

function Ability:_initialize()
    local dataTable = Data:getDataTable('ABILITY_DATA');
    local table = {};

    for abilityName, abilityData in pairs(dataTable) do
        table[abilityName] = {
            id = abilityName,
            text = abilityData.text,
            type = abilityData.type
        };
    end

    Ability._ToAAbilityMap = table;

    if isDebugEnabled(ABILITY, LOAD_DATA) then
        debugLog(ABILITY, LOAD_DATA, 'Ability Data Map is loaded: ');
        Utility:printObj(Ability._ToAAbilityMap, '_ToAAbilityMap');
    end
end

local _findAbilityDataById = function(abilityId)
    if not abilityId or not type(abilityId) == 'string' then
        return nil;
    end

    return Ability._ToAAbilityMap[abilityId];
end

local _getAbilityPos = function(abilityData)
    local type = abilityData and abilityData.type or '';

    if type == 'Q' then
        return 0;
    elseif type == 'W' then
        return 1;
    elseif type == 'E' then
        return 2;
    end

    return -1;
end

local _getEmptyAbilityBySlot = function(pos)
    if pos == 0 then
        return 'ability_inactive_q';
    elseif pos == 1 then
        return 'ability_inactive_w';
    elseif pos == 2 then
        return 'ability_inactive_e';
    end

    return '';
end

function Ability:onPrecast(ability, caster, target)
    local caster = caster or ability:GetCaster();

    if isDebugEnabled(ABILITY, PRECAST) then
        debugLog(ABILITY, PRECAST, 'Precasting ' .. ability:GetAbilityName() .. ' , caster '  .. Utility:formatUnitLog(caster));
    end
end

function Ability:onCast(ability, caster, target)
    local caster = caster or ability:GetCaster();

    if isDebugEnabled(ABILITY, CAST) then
        debugLog(ABILITY, CAST, 'Casting ' .. ability:GetAbilityName() .. ' , caster '  .. Utility:formatUnitLog(caster));
    end

    if Hero.TitanGuardian:isInstance(caster) then
        Hero.TitanGuardian:doStrengthOfTitan();
    end

    if Hero.IceSorceress:isInstance(caster) then
        Hero.IceSorceress:doFrostBlossom();
    end
end

function Ability:onSuccess(ability, caster, target)
    local caster = caster or ability:GetCaster();

    if isDebugEnabled(ABILITY, SUCCESS) then
        debugLog(ABILITY, SUCCESS, 'SUCCESS cast ' .. ability:GetAbilityName() .. ' , caster '  .. Utility:formatUnitLog(caster));
    end
end

function Ability:onInterrupt(ability, caster, target)
    local caster = caster or ability:GetCaster();

    if isDebugEnabled(ABILITY, INTERRUPT) then
        debugLog(ABILITY, INTERRUPT, 'INTERRUPT cast ' .. ability:GetAbilityName() .. ' , caster '  .. Utility:formatUnitLog(caster));
    end
end

function Ability:addAbilityToHero(abilityId, unit)
    local abilityData = _findAbilityDataById(abilityId);
    local pos = _getAbilityPos(abilityData);

    if not abilityData or pos < 0 then
        return;
    end

    local prevAbilityId = unit._ToAAbilitySlot[tostring(pos + 1)] or _getEmptyAbilityBySlot(pos);

    if not unit:HasAbility(abilityData.id) then
        local ability = unit:AddAbility(abilityData.id);
        ability:SetHidden(true);
        ability:SetLevel(1);
    else
    end

    -- 实际进行技能交换, 将后者隐藏起来
    unit:UnHideAbilityToSlot(abilityData.id, prevAbilityId);
    unit._ToAAbilitySlot[tostring(pos + 1)] = abilityData.id;

    if isDebugEnabled(ABILITY, EVENT) then
        debugLog(ABILITY, EVENT, 'Ability add to Creep: ' .. tostring(abilityData.id) .. ' -> ' .. Utility:formatUnitLog(unit));
    end
end

function Ability:hasAmplifier(unit, abilityId, amplifier)
    if not (amplifier == Ability.Amplifier.RED or amplifier == Ability.Amplifier.GREEN or amplifier == Ability.Amplifier.BLUE) then
        -- error condition
        return false;
    end

    return true;
end
