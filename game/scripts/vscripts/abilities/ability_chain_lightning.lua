local ABILITY = 'ABILITY';
local PRECAST = 'PRECAST';
local INTERRUPT = 'INTERRUPT';
local CAST = 'CAST';
local SUCCESS = 'SUCCESS';
local CHECK = 'CHECK';

local ABILITY_ID = 'ability_chain_lightning';
local DEFAULT_MAX_COUNT = 5;

ability_chain_lightning = class({});

LinkLuaModifier('modifier_chain_lightning_dummy', 'abilities/ability_chain_lightning.lua', LUA_MODIFIER_MOTION_NONE);

-- 可以作为关键的内容来定义, 例如 getCacheTable
ability_chain_lightning.cacheTable = {};

function ability_chain_lightning:OnAbilityPhaseStart()
    local caster = self:GetCaster();

    Ability:onPrecast(self);
    Particle:fireParticle('STORM_CAST', caster, PATTACH_POINT_FOLLOW);
    return true;
end

function ability_chain_lightning:doArcLightning(caster, unit1, unit2, ability)
    local speed = 10000;
    local lightingType = 'CHAIN_LIGHTNING';
    Particle:fireParticle('LIGHTNING_IMPACT', unit2, PATTACH_POINT_FOLLOW);

    -- Red Amplifier: 转化为金色闪电并加深伤害, 拥有额外的特效
    if Ability:hasAmplifier(caster, ABILITY_ID, Ability.Amplifier.BLUE) then
        local location = unit2:GetOrigin();
        -- 特殊粒子效果
        Particle:fireParticleLocation('STORM_BOLT.EFFECT1.GOLD', location, PATTACH_POINT_FOLLOW, 3, nil,
            { key = 0, value = location }
        );

        lightingType = 'CHAIN_LIGHTNING.GOLD';
    end

    Particle:createMissile(lightingType, {
        caster = unit1,
        target = unit2,
        ability = ability,
        speed = speed
    });

    if isDebugEnabled(ABILITY, CHECK) then
        debugLog(ABILITY, CHECK,
            ability:GetAbilityName() .. ' , lightning chain: ' .. Utility:formatUnitLog(unit1) ..
                ' ---> ' .. Utility:formatUnitLog(unit2));
    end
end

function ability_chain_lightning:OnSpellStart()
    local caster, target = self:GetCaster(), self:GetCursorTarget();
    local dummy = CreateModifierThinker(caster, self, 'modifier_chain_lightning_dummy', {}, Vector(0, 0, 0),
                      caster:GetTeamNumber(), false);
    local location = caster:GetOrigin();
    local maxCount = DEFAULT_MAX_COUNT;

    Ability:onCast(self, caster);

    -- Blue Amplifier: 增加弹射上限, 减少弹射伤害衰减, 具有额外的例子特效
    if Ability:hasAmplifier(caster, ABILITY_ID, Ability.Amplifier.BLUE) then
        Particle:fireParticleLocation('LIGHTNING_SPARKS', location, PATTACH_POINT_FOLLOW, 4, nil,
            { key = 0, value = location },
            { key = 1, value = Vector(300, 300, 300) }
        );
        Particle:fireParticleLocation('LIGHTNING_SPARKS_MINOR', location, PATTACH_POINT_FOLLOW, 4, nil,
            { key = 0, value = location }
        );

        maxCount = maxCount + 3;
    end

    self:doArcLightning(caster, caster, target, self);
    caster:EmitSound('Hero_Zuus.ArcLightning.Cast');

    dummy.cacheTable = {
        caster = caster,
        target = target,
        counter = 1,
        maxCount = maxCount,
        visitedList = { [tostring(target)] = true }
    };

    if isDebugEnabled(ABILITY, CHECK) then
        debugLog(ABILITY, CHECK,
            self:GetAbilityName() .. ' , lightning chain count: ' .. tostring(dummy.cacheTable.counter));
    end

    if caster.isDone == nil then
        -- ParticleManager:CreateParticle('particles/basic_ambient/titan_guardian_buff_runes.vpcf', PATTACH_POINT_FOLLOW, caster);
        -- ParticleManager:CreateParticle('particles/basic_ambient/titan_guardian_buff_main.vpcf', PATTACH_POINT_FOLLOW, caster);
        caster.isDone = true;
        -- Particle:createParticleSet('TITAN_GUARDIAN.AMBIENTS.ACTIVE', caster, PATTACH_POINT_FOLLOW);
        -- Particle:createParticleSet('TITAN_GUARDIAN.AMBIENTS.RAGE', caster, PATTACH_POINT_FOLLOW);
    end

    -- Particle:fireParticle('TITAN_GUARDIAN.GREAT_CLEAVE', caster, PATTACH_POINT_FOLLOW);
    -- ParticleManager:CreateParticle('particles/units/heroes/hero_mars/mars_debut_ground_impact.vpcf',
    --     PATTACH_POINT_FOLLOW, caster);
end

function ability_chain_lightning:doStormPulse(caster, target, ability)
    local speed = 1000;

    local missileId = Particle:createMissile('STORM_PULSE', {
        caster = target,
        target = caster,
        ability = ability,
        speed = speed
    });
    ability.cacheTable[tostring(missileId)] = true;

    Particle:fireParticle('STORM_PULSE_IMPACT', target, PATTACH_ABSORIGIN_FOLLOW);
end

modifier_chain_lightning_dummy = class({});

function modifier_chain_lightning_dummy:OnCreated()
    self:SetDuration(1000, true);
    self:StartIntervalThink(0.2);
end

function modifier_chain_lightning_dummy:OnIntervalThink()
    local dummy = self:GetParent();
    local cacheTable = dummy.cacheTable;

    local caster, target = cacheTable.caster, cacheTable.target;
    local counter, maxCount = cacheTable.counter, cacheTable.maxCount;
    local visitedList = cacheTable.visitedList;

    local location = cacheTable.target:GetAbsOrigin();
    local enumGroup = FindUnitsInRadius(dummy:GetTeamNumber(), location, self, 450, DOTA_UNIT_TARGET_TEAM_ENEMY,
                          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER,
                          false);

    local nextTarget = nil;
    if #enumGroup > 0 then
        for _, enum in pairs(enumGroup) do
            if enum ~= nil and (not enum:IsMagicImmune()) and (not enum:IsInvulnerable()) and
                (visitedList[tostring(enum)] ~= true) then
                nextTarget = enum;
                break
            end
        end
    end

    if nextTarget ~= nil then
        counter = counter + 1;

        ability_chain_lightning:doArcLightning(caster, target, nextTarget, self:GetAbility());

        if isDebugEnabled(ABILITY, CHECK) then
            debugLog(ABILITY, CHECK,
                self:GetAbility():GetAbilityName() .. ' , lightning chain count: ' .. tostring(counter));
        end

        -- update the cache Table: 更新表格的数据
        cacheTable.counter = counter;
        cacheTable.target = nextTarget;
        cacheTable.visitedList[tostring(cacheTable.target)] = true;

        if counter == maxCount then
            self:Destroy();
        end
    else
        self:Destroy();
    end
end

function ability_chain_lightning:OnProjectileHitHandle(hTarget, vLocation, iProjectileHandle)
    local target = hTarget;

    if ability_chain_lightning.cacheTable and ability_chain_lightning.cacheTable[tostring(iProjectileHandle)] then
        Particle:missileHit('STORM_PULSE', target);
        Particle:fireParticle('STORM_PULSE_IMPACT', target, PATTACH_ABSORIGIN_FOLLOW);
    end
end

function modifier_chain_lightning_dummy:OnDestroy()
    local dummy = self:GetParent();
    local cacheTable = dummy.cacheTable;

    if cacheTable ~= nil and cacheTable.target ~= nil then
        local caster = cacheTable.caster;
        
        -- Green Amplifier: 释放一道激流风暴, 回到施法者身边
        if Ability:hasAmplifier(caster, ABILITY_ID, Ability.Amplifier.GREEN) then
            ability_chain_lightning:doStormPulse(cacheTable.caster, cacheTable.target, self:GetAbility());
        end
    end
end
