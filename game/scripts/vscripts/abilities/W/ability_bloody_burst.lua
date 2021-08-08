ability_bloody_burst = class({});

local ABILITY_ID = 'ability_bloody_burst';
local DELAY_DEFAULT = 4;

function _playBloodBurst(dataObj)
    local caster = dataObj and dataObj.caster or nil;
    local location = caster:GetOrigin();

    Particle:fireParticleLocation('BLOOD_BURST', location, PATTACH_POINT_FOLLOW, 10, nil,
        { key = 0, value = location }, 
        { key = 1, value = Vector(675, 675, 675) });

    Particle:fireParticleLocation('BLOOD_BURST', location, PATTACH_POINT_FOLLOW, 10, nil,
        { key = 0, value = location},
        { key = 1, value = Vector(525, 525, 525) });
end

function doBloodBurst(dataObj)
    local caster = dataObj and dataObj.caster or nil;
    local particleId = dataObj.particleId;
    local location = caster:GetOrigin();

    -- particles animation
    Particle:destroyParticle(particleId, false);
    Particle:fireParticleLocation('BLOOD_BURST.SPLASH', location, PATTACH_POINT_FOLLOW, 10, nil, {
        key = 0, value = location
    });
    Particle:playSound('hero_bloodseeker.bloodRite.silence', caster, false);

    -- used for play particle effects
    timerEvent(0.1, { caster = caster }, _playBloodBurst);

    -- Red Amplifier: 一定时间延迟后造成第二次血爆效果
    if Ability:hasAmplifier(caster, ABILITY_ID, Ability.Amplifier.RED) then
        local delay = DELAY_DEFAULT;

        local particleId1 = Particle:createParticle('BLOOD_BURST.BUFF2', caster, PATTACH_OVERHEAD_FOLLOW);
        local particleId2 = Particle:createParticle('BLOOD_BURST.BUFF3', caster);

        local dataObj = { caster = caster, particleId1 = particleId1, particleId2 = particleId2 };
        timerEvent(delay, dataObj, doBloodBurstTwice);
    end

    -- Blue Amplifier: 增加出血积蓄值
    if Ability:hasAmplifier(caster, ABILITY_ID, Ability.Amplifier.BLUE) then
        Particle:fireParticleLocation('BLOOD_BURST.GROUND', location, PATTACH_POINT_FOLLOW, 10, nil, {
            key = 0,
            value = location
        });
    end
end

function doBloodBurstTwice(dataObj)
    local caster = dataObj and dataObj.caster or nil;
    local particleId1 = dataObj.particleId1;
    local particleId2 = dataObj.particleId2;
    local location = caster:GetOrigin();

    Particle:destroyParticle(particleId1, false);
    Particle:destroyParticle(particleId2, false);
    Particle:fireParticleLocation('BLOOD_BURST.SPLASH', location, PATTACH_POINT_FOLLOW, 10, nil, {
        key = 0,
        value = location
    });
    Particle:playSound('hero_bloodseeker.bloodRite.silence', caster, false);

    -- Blue Amplifier: 增加出血积蓄值
    if Ability:hasAmplifier(caster, ABILITY_ID, Ability.Amplifier.BLUE) then
        Particle:fireParticleLocation('BLOOD_BURST.GROUND', location, PATTACH_POINT_FOLLOW, 10, nil, {
            key = 0,
            value = location
        });
    end

    -- used for play particle effects
    timerEvent(0.1, { caster = caster }, _playBloodBurst);
end

function ability_bloody_burst:OnAbilityPhaseStart()
    local caster = self:GetCaster();
    Particle:fireParticle('BLOOD_CAST', caster, PATTACH_ABSORIGIN_FOLLOW);

    return true;
end

function ability_bloody_burst:OnSpellStart()
    local caster = self:GetCaster();
    local location = caster:GetOrigin();
    local dataObj = nil;
    local delay = DELAY_DEFAULT;

    -- Green Amplifier: 缩短生效延迟, 同时重置普攻
    if Ability:hasAmplifier(caster, ABILITY_ID, Ability.Amplifier.GREEN) then
        delay = 0;
        caster:AttackNoEarlierThan(0);

        Particle:fireParticleLocation('BLOOD_BURST.EFFECT', location, PATTACH_POINT_FOLLOW, 5, nil, {
            key = 0,
            value = location
        });
    end

    local particleId = Particle:createParticle('BLOOD_BURST.BUFF1', caster);
    dataObj = {
        caster = caster,
        particleId = particleId,
    };

    timerEvent(delay, dataObj, doBloodBurst);
end
