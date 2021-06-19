ability_blizzard = class({});

LinkLuaModifier('modifier_ability_blizzard_dummy', 'abilities/ability_blizzard.lua', LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier('modifier_ability_blizzard_dummy_missile', 'abilities/ability_blizzard.lua', LUA_MODIFIER_MOTION_NONE);

local SERVICE = 'ability_blizzard';

local _getDistVector = function(location, dist, degree)
    local angle = math.rad(degree);
    local originX = location.x;
    local originY = location.y;

    return Vector(originX + dist * math.cos(angle), originY + dist * math.sin(angle), location.z);
end

local _generateRandomVectors = function (location, range, count)
    local vectors = {};
    local deltaDegree = 360 / count;
    local degreeOffset = 12;
    local degreeInit = RandomFloat(0, 360);

    for i = 1, count do
        local dist = RandomFloat(0, range);
        local degree = degreeInit + deltaDegree * i + RandomFloat(-degreeOffset, degreeOffset);
        vectors[i] = _getDistVector(location, dist, degree);
    end

    return vectors;
end

local _locationToVector = function (location)
    if not location then
        return nil;
    end

    return Vector(location.x, location.y, location.z);
end

function ability_blizzard:doBlizzardCast(ability, caster, posVector, level)

    CreateModifierThinker(caster, ability, 'modifier_ability_blizzard_dummy', {
        waveMax = 5,
        posX = posVector.x,
        posY = posVector.y,
        posZ = posVector.z,
    }, posVector, caster:GetTeamNumber(), false);
end

function ability_blizzard:doBlizzardExplosion(ability, caster, dummy, location)
    local missileNum = RandomInt(3, 4);
    local vectors = _generateRandomVectors(location, 450, missileNum);
    local cacheId = Cache:set(SERVICE, vectors, 'vectors', 60);

    CreateModifierThinker(caster, ability, 'modifier_ability_blizzard_dummy_missile', {
        cacheId = cacheId,
        missileNum = missileNum,
    }, _locationToVector(location), caster:GetTeamNumber(), false);
end


require('utils/queue');

function ability_blizzard:OnSpellStart()
    local caster = self:GetCaster();
    local posVector = self:GetCursorPosition();

    Ability:onCast(self, caster);

    ability_blizzard:doBlizzardCast(self, caster, posVector, 1);
end

modifier_ability_blizzard_dummy = class({});
modifier_ability_blizzard_dummy_missile = class({});

function modifier_ability_blizzard_dummy:OnCreated(params)
    local dummy = self:GetParent();
    local particleId = Particle:createParticle('BLIZZARD.FIELD', dummy, PATTACH_POINT_FOLLOW);
    local TTL = params.waveMax;
    local interval = 1.2;
    local duration = TTL * interval + 4;

    ParticleManager:SetParticleControl(particleId, 1, Vector(450, 450, 450));

    self:SetDuration(duration, true);

    self._dataObj = {
        wave = 0,       waveMax = params.waveMax,
        TTL = TTL,      TTLflag = false,
        particleId = particleId,
        location = {
            x = params.posX,
            y = params.posY,
            z = params.posZ,
        }
    };

    dummy:EmitSound('hero_Crystal.freezingField.wind');

    self:StartIntervalThink(interval);
end

function modifier_ability_blizzard_dummy:OnIntervalThink()
    local dummy = self:GetParent();
    local dataObj = self._dataObj;

    if dataObj.wave < dataObj.waveMax then
        ability_blizzard:doBlizzardExplosion(self:GetAbility(), self:GetCaster(), dummy, dataObj.location);
    end

    if dataObj.wave >= dataObj.TTL and not dataObj.TTLflag then
        Particle:destroyParticle(dataObj.particleId);
        dataObj.TTLflag = true;
        dataObj.particleId = nil;

        dummy:StopSound('hero_Crystal.freezingField.wind');
        -- Modifier:clearBuff(Modifier.Debuff.freezing, IceSorceress._entity);
    end

    dataObj.wave = dataObj.wave + 1;
end

function modifier_ability_blizzard_dummy:OnDestroy()
    local dataObj = self._dataObj;

    if dataObj and dataObj.particleId then
        Particle:destroyParticle(dataObj.particleId);
    end
end

function modifier_ability_blizzard_dummy_missile:OnCreated(params)
    local cacheId = params.cacheId;
    local max = params.missileNum;
    local interval = 0.1;
    local TTL = 10;
    local duration = TTL * interval + 1;

    self:SetDuration(duration, true);

    self._dataObj = {
        cacheId = cacheId,
        count = 0,
        max = max,
        TTL = TTL,          TTLflag = false,
    };

    self:StartIntervalThink(interval);
end

function modifier_ability_blizzard_dummy_missile:OnIntervalThink()
    local dummy = self:GetParent();
    local dataObj = self._dataObj;
    local cacheId = dataObj.cacheId;

    if dataObj.count < dataObj.max then
        local vectors = Cache:get(SERVICE, cacheId);
        local vector = vectors[dataObj.count + 1];
        local particleId = Particle:createParticle('BLIZZARD.EXPLOSION', dummy, PATTACH_ABSORIGIN);
        ParticleManager:SetParticleControl(particleId, 0, vector);

        dummy:EmitSound('hero_Crystal.freezingField.explosion');
    end

    if dataObj.count >= dataObj.TTL and not dataObj.TTLflag then
        dataObj.TTLflag = true;
    end

    dataObj.count = dataObj.count + 1;
end

function modifier_ability_blizzard_dummy_missile:OnDestroy()
    local cacheId = self._dataObj.cacheId;
    local dummy = self:GetParent();

    self._dataObj = nil;
    Cache:remove(SERVICE, cacheId);
end
