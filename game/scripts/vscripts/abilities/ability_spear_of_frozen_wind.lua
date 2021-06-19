local ABILITY = 'ABILITY';
local PRECAST = 'PRECAST';
local INTERRUPT = 'INTERRUPT';
local CAST = 'CAST';
local SUCCESS = 'SUCCESS';
local CHECK = 'CHECK';

ability_spear_of_frozen_wind = class({});
LinkLuaModifier('modifier_ability_spear_of_frozen_wind_dummy', 'abilities/ability_spear_of_frozen_wind.lua', LUA_MODIFIER_MOTION_NONE);

function ability_spear_of_frozen_wind:OnAbilityPhaseStart()
    local caster = self:GetCaster();
    Particle:fireParticle('FROST_CAST', caster, PATTACH_ABSORIGIN_FOLLOW);

    return true;
end

function ability_spear_of_frozen_wind:OnSpellStart()
    local caster = self:GetCaster();

    Ability:onCast(self, caster);

    Particle:fireParticle('FROST_NOVA_SPARK', caster, PATTACH_POINT_FOLLOW);
    Particle:fireParticle('SNOW_EXPLODE', caster, PATTACH_POINT_FOLLOW);
    CreateModifierThinker(caster, self, 'modifier_ability_spear_of_frozen_wind_dummy', {}, Vector(0, 0, 0), caster:GetTeamNumber(), false);
end

modifier_ability_spear_of_frozen_wind_dummy = class({});

function modifier_ability_spear_of_frozen_wind_dummy:OnCreated()
    local caster, dummy = self:GetCaster(), self:GetParent();

    local frontVector, startLocation = caster:GetForwardVector(), caster:GetOrigin();
    local speed = 1050;

    self.particleMain = Particle:createParticle('FROZEN_SPEAR.PROJ', dummy, PATTACH_POINT, 'SOUND.CAST', nil,
        { key = 0, value = startLocation },
        { key = 1, value = frontVector * speed }
    );

    self.dist, self.distMax, self.refSpeed = 0, 1000, speed * 0.05;
    self.refLocation = Vector(startLocation.x, startLocation.y, startLocation.z);
    self.refSpeedVec = frontVector * self.refSpeed;
    self.isCompleted, self.isSelected = false, false;

    self:SetDuration(12.0, true);
    self:StartIntervalThink(0.05);
end

function modifier_ability_spear_of_frozen_wind_dummy:OnIntervalThink()
    if self.isCompleted then return; end

    local caster, dummy = self:GetCaster(), self:GetParent();
    self.dist = self.dist + self.refSpeed;
    self.refLocation.x = self.refLocation.x + self.refSpeedVec.x;
    self.refLocation.y = self.refLocation.y + self.refSpeedVec.y;
    self.refLocation.z = self.refLocation.z + self.refSpeedVec.z;

    local range = 100;

    if self.dist >= self.distMax then
        self.isCompleted = true;
        ParticleManager:DestroyParticle(self.particleMain, false);
        range = 175;
    end

    if not self.isSelected then
        local enumGroup = FindUnitsInRadius(caster:GetTeamNumber(), self.refLocation, self, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false);

        local target = nil;
        if #enumGroup > 0 then
            for _, enum in pairs(enumGroup) do
                if enum ~= nil and (not enum:IsMagicImmune()) and (not enum:IsInvulnerable()) then
                    target = enum;
                    break;
                end
            end
        end

        if target ~= nil then
            if isDebugEnabled(ABILITY, CHECK) then
                debugLog(ABILITY, CHECK, Utility:formatAbilityHitLog(self:GetAbility(), { target } ));
            end

            Particle:fireParticle('FROZEN_SPEAR.IMPACT', target, PATTACH_POINT_FOLLOW);
            Particle:fireParticle('SNOW_EXPLODE', target, PATTACH_POINT_FOLLOW);
            Particle:missileHit('FROZEN_SPEAR.PROJ', target);
            self.isSelected = true;
        end
    end

end
