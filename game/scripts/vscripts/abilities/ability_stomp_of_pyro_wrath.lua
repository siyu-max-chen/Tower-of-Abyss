ability_stomp_of_pyro_wrath = class({});

LinkLuaModifier('modifier_stomp_of_pyro_wrath', 'abilities/ability_stomp_of_pyro_wrath.lua', LUA_MODIFIER_MOTION_NONE);

-- 可以作为关键的内容来定义, 例如 getCacheTable
ability_stomp_of_pyro_wrath.cacheTable = {};

function ability_stomp_of_pyro_wrath:OnAbilityPhaseStart()
    local caster = self:GetCaster();
    Particle:fireParticle('FIRE_CAST', caster, PATTACH_ABSORIGIN_FOLLOW);

    return true;
end

function ability_stomp_of_pyro_wrath:doPyroStomp(caster, ability)
    local currentStackCount = caster:GetModifierStackCount('modifier_stomp_of_pyro_wrath', nil);
    local stackCount = math.min(currentStackCount + 1, 2);

    local index, controlScale = 0, 0;
    if currentStackCount == 0 then
        index = 0; controlScale = 325;
    elseif currentStackCount == 1 then
        index = 1; controlScale = 375;
    else
        index = 2; controlScale = 425;
    end

    Particle:fireParticle('INNER_FIRES', caster, PATTACH_POINT_FOLLOW, index,
        { key = 0, value = caster:GetAbsOrigin() },
        { key = 1, value = Vector(controlScale, 0, 0) }
    );

    caster:AddNewModifier(caster, ability, 'modifier_stomp_of_pyro_wrath', { duration = 8 });
    caster:SetModifierStackCount('modifier_stomp_of_pyro_wrath', nil, stackCount);
end

function ability_stomp_of_pyro_wrath:OnSpellStart()
    local caster = self:GetCaster();

    Ability:onCast(self, caster);

    Particle:fireParticleDelay('CRIT_SLAM', caster, PATTACH_POINT_FOLLOW, 2.0);
    ability_stomp_of_pyro_wrath:doPyroStomp(caster, self);
end

modifier_stomp_of_pyro_wrath = class({});

function modifier_stomp_of_pyro_wrath:OnCreated()
end

function modifier_stomp_of_pyro_wrath:RefCountsModifiers()
    return true;
end

function modifier_stomp_of_pyro_wrath:GetTexture()
    return 'huskar_inner_fire';
end

function modifier_stomp_of_pyro_wrath:IsDebuff()
    return false;
end

function modifier_stomp_of_pyro_wrath:OnDestroy()
end
