local ABILITY = 'ABILITY';
local PRECAST = 'PRECAST';
local INTERRUPT = 'INTERRUPT';
local CAST = 'CAST';
local SUCCESS = 'SUCCESS';
local CHECK = 'CHECK';

ability_curse_pulse = class({});

-- 可以作为关键的内容来定义, 例如 getCacheTable
ability_curse_pulse.cacheTable = {};

function ability_curse_pulse:OnAbilityPhaseStart()
    local caster = self:GetCaster();
    Particle:fireParticle('STORM_CAST', caster, PATTACH_POINT_FOLLOW);

    return true;
end

function ability_curse_pulse:OnSpellStart()
    local caster = self:GetCaster();
    local target = self:GetCursorTarget();
    self.speed = 475;

    Ability:onCast(self, caster);

    Particle:createMissile('CURSE_PULSE.PROJ', {
        caster = caster, target = target, ability = self, speed = self.speed
    });

    Particle:fireParticle('STORM_BOLT_DUST', caster, PATTACH_POINT_FOLLOW);

    ToAEffect:doScreamingDaggers(caster, target:GetOrigin(), 0);
end

function ability_curse_pulse:OnProjectileHitHandle(hTarget, vLocation, iProjectileHandle)
    local caster, target = self:GetCaster(), hTarget;
    local targetLocation = target:GetOrigin();

    if isDebugEnabled(ABILITY, CHECK) then
        debugLog(ABILITY, CHECK, Utility:formatAbilityHitLog(self, { target } ));
    end

    Particle:missileHit('CURSE_PULSE.PROJ', target);
    Particle:fireParticle('CURSE_PULSE.IMPACT', target, PATTACH_POINT_FOLLOW);
end
