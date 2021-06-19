ability_freezing_field = class({});

LinkLuaModifier('modifier_ability_freezing_field', 'abilities/ability_freezing_field.lua', LUA_MODIFIER_MOTION_NONE);

function ability_freezing_field:OnSpellStart()
    local caster = self:GetCaster();

    caster:AddNewModifier(caster, self, 'modifier_ability_freezing_field', {});
end

modifier_ability_freezing_field = class({});

local BUFF_INTERVAL = 4;

function ability_freezing_field:OnFrostBurst(ability, caster, locationVec)
    local counter = 0;
    local limit = 4;
    local range = 750;

    local enumGroup = FindUnitsInRadius(caster:GetTeamNumber(), locationVec, nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY,
                          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER,
                          false) or {};
    local target = nil;
    for _, enum in pairs(enumGroup) do
        if enum ~= nil and (not enum:IsMagicImmune()) and (not enum:IsInvulnerable()) then
            target = enum;
            Particle:fireParticleLocation('ICE_SORCERESS.ICE_NOVA', target:GetOrigin(), PATTACH_POINT_FOLLOW, 5);

            counter = counter + 1;
        end

        if counter >= limit then
            break;
        end
    end

    if counter < limit then
        local vectorCount = limit - counter;
        local vectors = Utility:generateRandomVectors(locationVec, vectorCount, range, range * 0.3);

        for i = 1, vectorCount do
            Particle:fireParticleLocation('ICE_SORCERESS.ICE_NOVA', vectors[i], PATTACH_POINT_FOLLOW, 5);
        end
    end
end

function modifier_ability_freezing_field:OnCreated()
    local caster = self:GetCaster();

    self._dataObj = {
        buffParticle = Particle:createParticle('ICE_SORCERESS.FREEZING_FIELD.BUFF', caster),
        counter = 0,
    }

    self:SetDuration(20, true);
    Particle:playSound('hero_Crystal.freezingField.wind', caster);

    self:StartIntervalThink(BUFF_INTERVAL);
end

function modifier_ability_freezing_field:OnIntervalThink()
    local caster = self:GetCaster();
    local originVec = caster:GetOrigin();
    local ability = self:GetAbility();

    if self._dataObj and #self._dataObj then
        local thinkerData = self._dataObj;

        if thinkerData.counter % 2 == 0 then
            ability_freezing_field:OnFrostBurst(ability, caster, caster:GetOrigin());
        else
            local particleId = Particle:fireParticleDelay('ICE_SORCERESS.FREEZING_FIELD.FLASH', caster, PATTACH_POINT_FOLLOW, 6);

            ParticleManager:SetParticleControl(particleId, 0, Vector(originVec.x, originVec.y, originVec.z + 400));
            ParticleManager:SetParticleControl(particleId, 1, Vector(originVec.x, originVec.y, originVec.z + 400));
            ParticleManager:SetParticleControl(particleId, 5, Vector(1, 1, 5));

            particleId = Particle:createParticle('ICE_SORCERESS.FREEZING_FIELD.BLAST_NOVA', caster, PATTACH_POINT_FOLLOW);

            ParticleManager:SetParticleControl(particleId, 1, originVec);
            ParticleManager:SetParticleControl(particleId, 2, Vector(900, 900, 900));
            Particle:destroyParticle(particleId);

            caster:EmitSound('Hero_Crystal.CrystalNova.Yulsaria');
        end

        if thinkerData.counter % 2 == 1 then
            Particle:playSound('hero_Crystal.freezingField.wind', caster);
        end

        thinkerData.counter = thinkerData.counter + 1;
    end
end

function modifier_ability_freezing_field:GetTexture()
    return 'crystal_maiden_freezing_field_alt1'
end

function modifier_ability_freezing_field:OnDestroy()
    local caster = self:GetCaster();

    Particle:stopSound('hero_Crystal.freezingField.wind', caster);

    if self._dataObj and #self._dataObj then
        Particle:destroyParticle(self._dataObj.buffParticle);
    end
end
