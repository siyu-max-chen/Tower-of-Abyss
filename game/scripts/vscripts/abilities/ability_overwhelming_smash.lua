ability_overwhelming_smash = class({});

LinkLuaModifier('modifier_ability_overwhelming_smash_dummy', 'abilities/ability_overwhelming_smash.lua',
    LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier('modifier_ability_overwhelming_smash_wave_dummy', 'abilities/ability_overwhelming_smash.lua',
    LUA_MODIFIER_MOTION_NONE);

-- 可以作为关键的内容来定义, 例如 getCacheTable
ability_overwhelming_smash.cacheTable = {};

function ability_overwhelming_smash:OnAbilityPhaseStart()
    local caster = self:GetCaster();
    Particle:fireParticle('TITAN_GUARDIAN.OVERWHELMING_SMASH.WARCRY', caster, PATTACH_ABSORIGIN_FOLLOW);
    Particle:fireSound('Hero_Sven.SignetLayer', caster);

    if IsServer() then
        print('is server..........');
    end

    if IsClient() then
        print('is client..........');
    end


    caster:SetBaseMaxHealth(math.random(500, 2500));

    ShowMessage('!!!!!!!!!!!!!!!!!!!!');

    return true;
end

function ability_overwhelming_smash:doTitanShockWave(caster, ability, location)
    CreateModifierThinker(caster, self, 'modifier_ability_overwhelming_smash_wave_dummy', {}, location,
        caster:GetTeamNumber(), false);
end

function ability_overwhelming_smash:doTitanSmash(caster, ability, location)
    Particle:fireParticleLocation('TITAN_GUARDIAN.OVERWHELMING_SMASH.STOMP1', location, PATTACH_POINT_FOLLOW, 10, nil, {
        key = 0,
        value = caster:GetOrigin()
    }, {
        key = 1,
        value = Vector(650, 0, 0)
    });

    Particle:fireParticleLocation('TITAN_GUARDIAN.OVERWHELMING_SMASH.STOMP2', location, PATTACH_POINT_FOLLOW, 10, nil, {
        key = 0,
        value = caster:GetOrigin()
    }, {
        key = 1,
        value = Vector(550, 550, 550)
    });
end

function ability_overwhelming_smash:OnSpellStart()
    local caster = self:GetCaster();
    local targetLocation = self:GetCursorPosition();

    Ability:onCast(self, caster, targetLocation);

    local randomAttackSpeed = math.random() * 300;
    Attribute:_setUnitAttackSpeed(caster, randomAttackSpeed);

    if Booster:getBoosterLevel(Booster.ENUM.SCOUT, caster) == 0 then
        Booster:incrementBooster(Booster.ENUM.SCOUT, caster, 5, true);
    else
        Booster:incrementBooster(Booster.ENUM.SCOUT, caster, 1, false);
    end

    CreateModifierThinker(caster, self, 'modifier_ability_overwhelming_smash_dummy', {}, targetLocation,
        caster:GetTeamNumber(), false);
end

modifier_ability_overwhelming_smash_dummy = class({});

function modifier_ability_overwhelming_smash_dummy:OnCreated()
    local caster, dummy = self:GetCaster(), self:GetParent();
    local duration, preStartDuration, mainDuration = 1.2, 0.4, 0.8;
    local intervalInverse = 50;

    local countPreStart = preStartDuration * intervalInverse;
    local countHalf = countPreStart + mainDuration * intervalInverse / 2;
    local countMax = countPreStart + mainDuration * intervalInverse;

    Battle.State:turnToPaused(caster);

    caster:ClearActivityModifiers();
    caster:AddActivityModifier('sven_shield')
    caster:AddActivityModifier('sven_warcry');
    caster:AddActivityModifier('fear');
    caster:StartGesture(ACT_DOTA_ATTACK);

    self.data = {
        isPreStartPhase = true,
        isHalfPhased = false,
        count = 0,
        countPreStart = countPreStart,
        countHalf = countHalf,
        countMax = countMax,
        sourceLocation = caster:GetOrigin(),
        targetLocation = dummy:GetOrigin(),
        flyHeight = GetGroundHeight(caster:GetOrigin(), caster),
        flySpeed = 5,
        flySpeedAcc = 10,
        particleSet = Particle:createParticleSet('TITAN_GUARDIAN.AMBIENTS.RAGE', caster, PATTACH_POINT_FOLLOW),
    };

    self:SetDuration(duration, true);
    self:StartIntervalThink(GAME.INTERVAL);
end

function modifier_ability_overwhelming_smash_dummy:OnIntervalThink()
    local caster = self:GetCaster();
    local data = self.data or {};

    if data.isPreStartPhase then
        data.count = data.count + 1;
        if data.count >= data.countPreStart then
            data.isPreStartPhase = false;

            Particle:fireParticleLocation('STOMP_SMASH', caster:GetOrigin(), PATTACH_POINT_FOLLOW, 2);
            Particle:fireParticleLocation('TITAN_OVERWHELMING_SMASH_BLINK', caster:GetOrigin(), PATTACH_POINT_FOLLOW, 2);
        end

        return;
    end

    if data.count <= data.countHalf then
        data.flySpeed = data.flySpeed + data.flySpeedAcc;
        data.flyHeight = data.flyHeight + data.flySpeed;
        caster:SetOrigin(Vector(data.sourceLocation.x, data.sourceLocation.y, data.flyHeight));
    else
        if data.isHalfPhased == false then
            data.flySpeed = 5;
            data.isHalfPhased = true;

            caster:ClearActivityModifiers();
            caster:AddActivityModifier('loadout');
            caster:AddActivityModifier('sven_shield');
            caster:StartGesture(ACT_DOTA_SPAWN);
        end

        data.flySpeed = data.flySpeed + data.flySpeedAcc;
        data.flyHeight = data.flyHeight - data.flySpeed;
        caster:SetOrigin(Vector(data.targetLocation.x, data.targetLocation.y, data.flyHeight));
    end

    data.count = data.count + 1;
end

function modifier_ability_overwhelming_smash_dummy:OnDestroy()
    local caster = self:GetCaster();
    local data = self.data or {};

    _G.Battle.State:turnToIdle(caster);

    caster:SetOrigin(data.targetLocation);
    FindClearSpaceForUnit(caster, data.targetLocation, true);

    ability_overwhelming_smash:doTitanSmash(caster, self, data.targetLocation);
    ability_overwhelming_smash:doTitanShockWave(caster, self, data.targetLocation);

    Particle:fireParticle('TITAN_OVERWHELMING_SMASH_LOADOUT', caster, PATTACH_POINT_FOLLOW);
    Particle:destroyParticleSet(data.particleSet, false);
end

modifier_ability_overwhelming_smash_wave_dummy = class({});

function modifier_ability_overwhelming_smash_wave_dummy:OnCreated()
    local caster, dummy = self:GetCaster(), self:GetParent();
    local frontVector, startLocation, speed = caster:GetForwardVector() or nil, dummy:GetOrigin(), 675;
    local waves = {};

    local maxCount = 8;
    local deg, degDelta = math.deg(math.atan2(frontVector.x, frontVector.y)), 360.0 / maxCount;

    local offset = 0;
    self.dist, self.distMax, self.refSpeed = 0, 1000, speed * 0.05;
    self.refLocation = Vector(startLocation.x + offset * frontVector.x, startLocation.y + offset * frontVector.y,
                           startLocation.z + offset * frontVector.z);
    self.refSpeedVec = frontVector * self.refSpeed;
    self.isCompleted, self.isSelected = false, false;
    self.waves = waves;
    self.maxCount = maxCount;

    for i = 1, maxCount do
        local rad = math.rad(deg);
        local frontVectorWave = Vector(math.cos(rad), math.sin(rad), 0);

        local particleId = Particle:createParticle('TITAN_OVERWHELMING_SMASH_WAVE', caster, PATTACH_POINT,
                               'SOUND.CAST', nil, {
                key = 0,
                value = startLocation
            }, {
                key = 1,
                value = frontVectorWave * speed
            });

        waves[i] = particleId;
        deg = deg + degDelta
    end

    self:SetDuration(8, true);
    self:StartIntervalThink(0.05);
end

function modifier_ability_overwhelming_smash_wave_dummy:OnIntervalThink()
    if self.isCompleted then
        return;
    end

    local caster, dummy = self:GetCaster(), self:GetParent();
    self.dist = self.dist + self.refSpeed;
    self.refLocation.x = self.refLocation.x + self.refSpeedVec.x;
    self.refLocation.y = self.refLocation.y + self.refSpeedVec.y;
    self.refLocation.z = self.refLocation.z + self.refSpeedVec.z;

    if self.dist >= self.distMax then
        self.isCompleted = true;

        for i = 1, self.maxCount do
            local particleId = self.waves[i];
            Particle:destroyParticle(particleId, false);
        end
    end
end
