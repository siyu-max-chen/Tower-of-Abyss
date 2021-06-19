local HERO = 'HERO';
local INIT = 'INIT';

local SOT_MAX_STACK = 4;
local SOT_ATTACK_SPEED = 10;
local SOT_ATTACK_ENHANCE = 5;
local SOT_DURATION = 18;

TitanGuardian = class({});

function TitanGuardian:_initialize(entity)
    if TitanGuardian._entity ~= nil then
        return;
    end

    TitanGuardian._entity = entity;
    TitanGuardian._entity._particles = {
        SET = {
            DEFAULT = Particle:createParticleSet('TITAN_GUARDIAN.AMBIENTS', TitanGuardian._entity, PATTACH_POINT_FOLLOW);
        }
    };

    if isDebugEnabled(HERO, INIT) then
        debugLog(HERO, INIT, 'Hero Titan Guardian init: ' .. Utility:formatUnitLog(entity));
    end
end

function TitanGuardian:isInstance(entity)
    print(tostring(entity) .. '   ,   ' .. tostring(TitanGuardian._entity));
    return entity and TitanGuardian._entity == entity;
end

function TitanGuardian:doStrengthOfTitan()
    local unit = TitanGuardian._entity;
    local stack = unit:GetModifierStackCount('modifier_titan_guardian_sot', nil);

    print(unit:GetUnitName());

    if stack < SOT_MAX_STACK then
        stack = stack + 1;

        Battle.Attribute:incrementUnitAttribute(Battle.Attribute.ENUM.ATTACK_SPEED, unit, SOT_ATTACK_SPEED, true);
        Battle.Attribute:incrementUnitAttribute(Battle.Attribute.ENUM.ATTACK.ENHANCE, unit, SOT_ATTACK_ENHANCE, true);
    end

    unit:AddNewModifier(unit, ABILITY_EFFECT_DUMMY, 'modifier_titan_guardian_sot', { duration = SOT_DURATION });
    unit:SetModifierStackCount('modifier_titan_guardian_sot', nil, stack);
end

LinkLuaModifier('modifier_titan_guardian_sot', 'creeps/heroes/titan_guardian', LUA_MODIFIER_MOTION_NONE);

modifier_titan_guardian_sot = class({});

function modifier_titan_guardian_sot:OnCreated()
    local unit = self:GetParent();
    self._particleSet = _G.Particle:createParticleSet('TITAN_GUARDIAN.AMBIENTS.ACTIVE', unit);
end

function modifier_titan_guardian_sot:OnRefresh()
end

function modifier_titan_guardian_sot:IsDebuff()
    return false;
end

function modifier_titan_guardian_sot:IsHidden()
    return false;
end

function modifier_titan_guardian_sot:GetTexture()
    return 'sven/cyclopean_marauder_ability_icons/sven_warcry';
end

function modifier_titan_guardian_sot:OnDestroy()
    local unit = self:GetParent();
    local stack = self:GetStackCount();

    Particle:destroyParticleSet(self._particleSet);

    Battle.Attribute:incrementUnitAttribute(Battle.Attribute.ENUM.ATTACK_SPEED, unit, SOT_ATTACK_SPEED * stack, false);
    Battle.Attribute:incrementUnitAttribute(Battle.Attribute.ENUM.ATTACK.ENHANCE, unit, SOT_ATTACK_ENHANCE * stack, false);
end
