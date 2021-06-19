ability_flaming_slash = class({});

LinkLuaModifier('modifier_flaming_slash_dummy', 'abilities/ability_flaming_slash.lua', LUA_MODIFIER_MOTION_NONE);

function ability_flaming_slash:OnAbilityPhaseStart()
    local caster = self:GetCaster();
    Particle:fireParticle('FIRE_CAST', caster, PATTACH_ABSORIGIN_FOLLOW);

    return true;
end

function ability_flaming_slash:OnSpellStart()
    local caster = self:GetCaster();

    Ability:onCast(self, caster);

    CreateModifierThinker(caster, self, 'modifier_flaming_slash_dummy', {}, caster:GetOrigin(), caster:GetTeamNumber(),
        false);
end

modifier_flaming_slash_dummy = class({});

function modifier_flaming_slash_dummy:OnCreated()
    local caster, dummy = self:GetCaster(), self:GetParent();

    local frontVector, startLocation, speed = caster:GetForwardVector(), caster:GetOrigin(), 1200;
    dummy:SetOrigin(startLocation);

    self.particleMain = Particle:createParticle('FIRE_BREATHE.WAVE', dummy, PATTACH_POINT, 'SOUND.CAST', nil, {
        key = 0,
        value = startLocation
    }, {
        key = 1,
        value = frontVector * speed
    });

    self.particleChar = Particle:createParticle('FIRE_BREATHE.CHAR', dummy, PATTACH_POINT, 'SOUND.CAST', nil, {
        key = 0,
        value = startLocation
    }, {
        key = 1,
        value = frontVector * speed
    });

    local offset = 0;

    self.dist, self.distMax, self.refSpeed = 0, 650, speed * 0.05;
    self.refLocation = Vector(startLocation.x + offset * frontVector.x, startLocation.y + offset * frontVector.y,
                           startLocation.z + offset * frontVector.z);
    self.refSpeedVec = frontVector * self.refSpeed;
    self.isCompleted, self.isSelected = false, false;

    Particle:fireParticleDelay('CRIT_SLASH_SWEEP', caster, PATTACH_POINT_FOLLOW, 1.2);
    Particle:fireParticleDelay('CRIT_SLASH_DOWN', caster, PATTACH_POINT_FOLLOW, 1.2);

    self:SetDuration(12.0, true);
    self:StartIntervalThink(0.05);
end

function modifier_flaming_slash_dummy:OnIntervalThink()
    if self.isCompleted then
        return;
    end

    local caster, dummy = self:GetCaster(), self:GetParent();
    self.dist = self.dist + self.refSpeed;
    self.refLocation.x = self.refLocation.x + self.refSpeedVec.x;
    self.refLocation.y = self.refLocation.y + self.refSpeedVec.y;
    self.refLocation.z = self.refLocation.z + self.refSpeedVec.z;

    local range = 200;

    if self.dist >= self.distMax then
        self.isCompleted = true;
        ParticleManager:DestroyParticle(self.particleMain, false);
        ParticleManager:DestroyParticle(self.particleChar, false);

        range = 200;
    end

    if not self.isSelected then
        local enumGroup = FindUnitsInRadius(caster:GetTeamNumber(), self.refLocation, self, range,
                              DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                              DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false);

        local target = nil;
        if #enumGroup > 0 then
            for _, enum in pairs(enumGroup) do
                if enum ~= nil and (not enum:IsMagicImmune()) and (not enum:IsInvulnerable()) then
                    target = enum;
                    break
                end
            end
        end

        if target ~= nil then
            Particle:missileHit('FIRE_BREATHE.WAVE', target);
            self.isSelected = true;
        end
    end
end

function modifier_flaming_slash_dummy:OnDestroy()
end

