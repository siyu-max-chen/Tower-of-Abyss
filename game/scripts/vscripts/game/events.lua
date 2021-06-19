local UI = 'UI';
local SERVER = 'SERVER';
local CLIENT = 'CLIENT';

function ToAGame:initUnitWithAbility(unit)
    if not unit or not unit:IsRealHero() then
        return;
    end

    for i = 1, 10 do
        local ability = unit:GetAbilityByIndex(i - 1);
        if ability ~= nil then
            ability:SetLevel(1);
        end
    end
end

local _isValidUnit = function(unit)
    return unit and unit:GetUnitName() ~= 'npc_dota_thinker';
end

function ToAGame:OnNPCSpawned(event)
    local unit = EntIndexToHScript(event.entindex);

    if _isValidUnit(unit) and not unit._ToACreepInit then
        ToAGame:initUnitWithAbility(unit);
        Creep:init(unit);

        unit._ToACreepInit = true;
    end
end

function ToAGame:attackEvent(attacker, target, dmgObj)
end

function ToAGame:evadeEvent(attacker, target)
end

local _handleTestAbilitySelectEvent = function(id, data)
    local abilityId = data.abilityId;
    local pos = data.pos;
    local unit = getTestUnit();

    Ability:addAbilityToHero(abilityId, unit);

    if isDebugEnabled(UI, CLIENT) then
        debugLog(UI, CLIENT, 'Client: Click the Test Ability Panel: ' .. abilityId);
    end
end

CustomGameEventManager:RegisterListener('event_test_ability_select', _handleTestAbilitySelectEvent);
