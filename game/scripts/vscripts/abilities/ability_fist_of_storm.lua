local ABILITY = 'ABILITY';
local PRECAST = 'PRECAST';
local INTERRUPT = 'INTERRUPT';
local CAST = 'CAST';
local SUCCESS = 'SUCCESS';
local CHECK = 'CHECK';

ability_fist_of_storm = class({});

-- 可以作为关键的内容来定义, 例如 getCacheTable
ability_fist_of_storm.cacheTable = {};

LinkLuaModifier('modifier_fist_of_storm_dummy', 'abilities/ability_fist_of_storm.lua', LUA_MODIFIER_MOTION_NONE);

function ability_fist_of_storm:OnAbilityPhaseStart()
    local caster = self:GetCaster();
    Particle:fireParticle('STORM_CAST', caster, PATTACH_POINT_FOLLOW);

    return true;
end

function ability_fist_of_storm:OnSpellStart()
    local caster = self:GetCaster();
    local target = self:GetCursorTarget();
    self.speed = 1200;

    Ability:onCast(self, caster);

    Particle:createMissile('STORM_BOLT', {
        caster = caster, target = target, ability = self, speed = self.speed
    });

    Particle:fireParticle('STORM_BOLT_DUST', caster, PATTACH_POINT_FOLLOW);
end

function ability_fist_of_storm:doLightningStrike(caster, dummy, ability, location)
    Particle:fireParticle('THUNDER_STRIKE', dummy, PATTACH_POINT_FOLLOW);
    Particle:fireParticle('THUNDER_STRIKE_GROUND', dummy, PATTACH_POINT_FOLLOW);

    -- Particle:fireParticle('THUNDER_CLAPS', dummy, PATTACH_POINT_FOLLOW, 0);
    Particle:fireParticle('THUNDER_CLAPS', dummy, PATTACH_POINT_FOLLOW, 0);
end

function ability_fist_of_storm:OnProjectileHitHandle(hTarget, vLocation, iProjectileHandle)
    local caster, target = self:GetCaster(), hTarget;
    local targetLocation = target:GetOrigin();

    Particle:missileHit('STORM_BOLT', target);

    if isDebugEnabled(ABILITY, CHECK) then
        debugLog(ABILITY, CHECK, Utility:formatAbilityHitLog(self, { target } ));
    end

    local vectors = {};
    for _ = 1, 3 do
        local randomDegree = _ * 120 + RandomFloat(-45, 45) - 120;
        local randomRadius = RandomFloat(25, 250);
        local randomAngle = math.rad(randomDegree);
        local x = targetLocation.x + randomRadius * math.cos(randomAngle);
        local y = targetLocation.y + randomRadius * math.sin(randomAngle);

        vectors[tostring(_ - 1)] = Vector(x, y, targetLocation.z + 10);
    end

    local dummy = CreateModifierThinker(caster, self, 'modifier_fist_of_storm_dummy', {}, vectors["0"], caster:GetTeamNumber(), false);
    dummy.data = {
        caster = caster, target = target,
        index = 0, counter = 0, counterMax = 1, isEnd = false,
        vectors = vectors
    };
end

modifier_fist_of_storm_dummy = class({});

function modifier_fist_of_storm_dummy:OnCreated()
    self:SetDuration(12.0, true);
    self:StartIntervalThink(0.5);
end

function modifier_fist_of_storm_dummy:OnIntervalThink()
    local dummy = self:GetParent();
    local data = dummy.data or {};
    local ability = self:GetAbility();
    local caster = data.caster;

    if data.isEnd then
        return;
    end

    if data.counter == 0 then
        local location = data.vectors[tostring(data.index)];
        ability_fist_of_storm:doLightningStrike(caster, dummy, ability, location);

        if data.index ~= 2 then
            local nextDummy = CreateModifierThinker(caster, ability, 'modifier_fist_of_storm_dummy', {}, data.vectors[tostring(data.index + 1)], caster:GetTeamNumber(), false);
            nextDummy.data = {
                caster = data.caster, target = data.target,
                index = data.index + 1, counter = 0, counterMax = 1, isEnd = false,
                vectors = data.vectors
            };
        end
    end

    data.counter = data.counter + 1;
    data.isEnd = true;
end

function modifier_fist_of_storm_dummy:OnDestroy()
end
