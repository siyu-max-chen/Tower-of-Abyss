ability_ignite = class({});

-- 可以作为关键的内容来定义, 例如 getCacheTable
ability_ignite.cacheTable = {};

LinkLuaModifier('modifier_ignite_dummy', 'abilities/ability_ignite.lua', LUA_MODIFIER_MOTION_NONE);

function ability_ignite:doIgnite(caster, target, handleId)
    Particle:fireMissile('IGNITE', target);
end

function ability_ignite:OnAbilityPhaseStart()
    local caster = self:GetCaster();
    Particle:fireParticle('FIRE_CAST', caster, PATTACH_ABSORIGIN_FOLLOW);

    return true;
end

function ability_ignite:OnSpellStart()
    local caster = self:GetCaster();
    local target = self:GetCursorTarget();

    Ability:onCast(self, caster);

    ability_ignite:doIgnite(caster, target, nil);

    local dummy = CreateModifierThinker(caster, self, 'modifier_ignite_dummy', {}, target:GetAbsOrigin(), caster:GetTeamNumber(), false);
    dummy.data = {
        caster = caster, target = target, counter = 1, maxCount = 8
    };
end

modifier_ignite_dummy = class({});

function modifier_ignite_dummy:OnCreated()
    self:SetDuration(1000, true);
    self:StartIntervalThink(0.4);
end

function modifier_ignite_dummy:OnIntervalThink()
    local dummy = self:GetParent();
    local data = dummy.data;

    if data == nil then
        return;
    end

    local caster, target = data.caster, data.target;
    local counter, maxCount = data.counter, data.maxCount;
    local location = data.target:GetAbsOrigin();
    local enumGroup = FindUnitsInRadius(dummy:GetTeamNumber(), location, self, 325, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false);

    local nextTarget = nil;
    if #enumGroup > 0 and counter < maxCount then
        for _, enum in pairs(enumGroup) do
            if enum ~= nil and (not enum:IsMagicImmune()) and (not enum:IsInvulnerable()) and enum ~= target then
                nextTarget = enum;
            end
        end
    end

    if nextTarget ~= nil then
        target = nextTarget;
    end
    counter = counter + 1;

    ability_ignite:doIgnite(caster, target, nil);

    if counter == maxCount then
        self:Destroy();
    end

    dummy.data.target = target;
    dummy.data.counter = counter;
end
