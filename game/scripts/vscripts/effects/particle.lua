require('data/main');

local PARTICLE = 'PARTICLE';
local CREATE = 'CREATE';
local DESTROY = 'DESTROY';
local DUMMY = 'DUMMY';

Particle = class({});

Particle.controlPointTable = {
    -- type = 0 - 就是 caster 的位置
    -- type = 1 - 存在 zOffset, 用来修正 z 的位置
    -- type = 2 - 存在 size, 修正 x, y, z 的数值
    FIRE_IMPACT = {
        { key = 0, type = 1, offset = 150 },
    },

    ICE_IMPACT = {
        { key = 0, type = 1, offset = 150 },
        { key = 1, type = 1, offset = 75 },
    },

    THUNDER_IMPACT = {
        { key = 0, type = 1, offset = 25 },
        { key = 1, type = 1, offset = 100 },
    },

    DARKNESS_IMPACT = {
        { key = 1, type = 1, offset = 100 },
        { key = 3, type = 1, offset = 100 },
    },

    LIGHT_IMPACT = {
        { key = 1, type = 1, offset = 75 },
        { key = 3, type = 1, offset = 75 },
    },

    CRIT_IMPACT = {
        { key = 0, type = 0 },
        { key = 3, type = 1, offset = 125 },
    },

    FIRE_CAST = {
        { key = 0, type = 0 },
        { key = 1, type = 0 },
    },

    STORM_CAST = {
        { key = 0, type = 1, offset = -150 },
        { key = 1, type = 1, offset = 150 },
    },

    THUNDER_STRIKE = {
        { key = 0, type = 1, offset = 150 },
        { key = 1, type = 1, offset = 1000 },
    },

    THUNDER_STRIKE_GROUND = {
        { key = 0, type = 0 },
        { key = 1, type = 0 },
    },

    LIGHTNING_IMPACT = {
        { key = 0, type = 1, offset = 150 },
        { key = 1, type = 1, offset = 150 },
    },

    SNOW_EXPLODE = {
        { key = 3, type = 0 },
    },

    FROZEN_SPEAR_IMPACT = {
        { key = 0, type = 0 },
        { key = 1, type = 0 },
    },

    FROST_NOVA_SPARK = {
        { key = 0, type = 0 },
    },

    STOMP_SMASH = {
        { key = 0, type = 0 },
        { key = 1, type = 2, size = 300 },
    },

    TITAN_OVERWHELMING_SMASH_BLINK = {
        { key = 0, type = 0 },
    },

    TITAN_OVERWHELMING_SMASH_LOADOUT = {
        { key = 0, type = 0 },
        { key = 1, type = 0 },
        { key = 2, type = 0 },
    },

    TITAN_OVERWHELMING_SMASH_CAST = {
        { key = 0, type = 0 },
    }

};

Particle.controlPointTable['ICE_SORCERESS.AMBIENTS.STAFF'] = {
    { key = 0, type = 0 },
};

Particle.controlPointTable['ICE_SORCERESS.ICE_NOVA'] = {
    { key = 0, type = 0 },
};

Particle.controlPointTable['ICE_SORCERESS.ICE_FROST_WIND'] = {
    { key = 0, type = 0 }, { key = 1, type = 2, size = 150 }
};



--- Determine whether particleName is a particle array
---@param particleName string
---@return boolean
function Particle:isParticleArray(particleName)
    local infoTable = Data._ToADataMap.PARTICLE;

    return particleName and infoTable[particleName] and infoTable[particleName].PATHS ~=
               nil or false;
end

--- Determine whether particleName is missile type
---@param particleName string
---@param index integer, optional
---@return boolean
function Particle:isParticleMissile(particleName, index)
    local infoTable = Data._ToADataMap.PARTICLE;

    if not Particle:isParticleArray(particleName) or index == nil then
        return particleName and infoTable[particleName] and
        infoTable[particleName].MISSILE and
                   tostring(infoTable[particleName].MISSILE) == 'true' and true or false;
    end

    return
        particleName and infoTable[particleName] and infoTable[particleName].PATHS and
        infoTable[particleName].PATHS[index] and
        infoTable[particleName].PATHS[index].MISSILE and
            tostring(infoTable[particleName].PATHS[index].MISSILE) == 'true' and true or false;
end

--- Get the actual particle path
---@param particleName string
---@param index integer, optional
---@return string or nil
function Particle:getParticlePath(particleName, index)
    local infoTable = Data._ToADataMap.PARTICLE;

    if not Particle:isParticleArray(particleName) or index == nil then
        return infoTable[particleName].PATH or nil;
    end

    return infoTable[particleName].PATHS[tostring(index)].PATH or nil;
end

--- Get the actual particle set paths
---@param particleName string
---@return array
function Particle:getParticleSetPaths(particleName)
    if not Particle:isParticleArray(particleName) then
        return {};
    end

    local result = {};
    local infoTable = Data._ToADataMap.PARTICLE;

    for _, val in pairs(infoTable[particleName].PATHS) do
        result[#result + 1] = val.PATH;
    end

    return result;
end

--- Get the actual particle sound file based on soundType
---@param particleName string
---@param soundType string - SOUND.HIT or SOUND.CAST
---@param index integer
---@return array or nil
function Particle:getParticleSound(particleName, soundType, index)
    local infoTable = Data._ToADataMap.PARTICLE;

    if not Particle:isParticleArray(particleName) or index == nil then
        return infoTable[particleName][soundType] or nil;
    end

    return infoTable[particleName].PATHS[tostring(index)][soundType] or nil;
end

function Particle:_getParticleArgs(particleName, target)
    if Particle.controlPointTable[particleName] == nil then
        return nil;
    end

    local result = {};
    local position = target:GetAbsOrigin();

    for _, table in pairs(Particle.controlPointTable[particleName]) do
        if table.type == 0 then
            result[#result + 1] = { key = table.key, value = position };
        elseif table.type == 1 then
            result[#result + 1] = { key = table.key, value = Vector(position.x, position.y, position.z + table.offset) };
        elseif table.type == 2 then
            result[#result + 1] = { key = table.key, value = Vector(table.size, table.size, table.size) };
        end
    end

    return result;
end

function Particle:createMissile(particleName, missileInfo)
    local info = {
        EffectName =  Particle:getParticlePath(particleName),
        Ability = missileInfo.ability, 
        iMoveSpeed = missileInfo.speed,
        Source = missileInfo.caster,
        Target = missileInfo.target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
    };

    local missileId = ProjectileManager:CreateTrackingProjectile(info);
    local soundData = Particle:getParticleSound(particleName, 'SOUND.CAST');

    if soundData ~= nil then
        missileInfo.caster:EmitSound(soundData);
    end

    return missileId;
end

function Particle:createMissileLocation(particleName, missileInfo)
    local delay = 10;
    local dummy = CreateModifierThinker(DUMMY_UNIT, nil, 'modifier_particle_helper_dummy', { duration = delay }, missileInfo.location, 0, false);

    local info = {
        EffectName =  Particle:getParticlePath(particleName),
        Ability = missileInfo.ability,
        iMoveSpeed = missileInfo.speed,
        Source = dummy,
        Target = missileInfo.target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
    };

    local missileId = ProjectileManager:CreateTrackingProjectile(info);
    local soundData = Particle:getParticleSound(particleName, 'SOUND.CAST');

    if soundData ~= nil then
        dummy:EmitSound(soundData);
    end

    return missileId;
end

function Particle:fireMissile(particleName, target)
    local particleId = Particle:createMissile(particleName, {
        speed = 10000,
        ability = nil,
        caster = target,
        target = target
    });

    if particleId ~= nil then
        ParticleManager:DestroyParticle(particleId, false);
        ParticleManager:ReleaseParticleIndex(particleId);
    end
end

function Particle:destroyParticle(particleId, immediateDelete)
    if not particleId then
        return;
    end

    if immediateDelete == nil then
        immediateDelete = false;
    end

    ParticleManager:DestroyParticle(particleId, immediateDelete);
    ParticleManager:ReleaseParticleIndex(particleId);

    if isDebugEnabled(PARTICLE, DESTROY) then
        debugLog(PARTICLE, DESTROY, 'particle is DESTROYED: ' .. tostring(particleId));
    end
end

function Particle:createParticle(particleName, target, attachPoint, soundType, index, ...)
    local particleId = nil;

    if not (Particle:isParticleMissile(particleName)) then
        local particlePath = Particle:getParticlePath(particleName, index);
        if attachPoint == nil then
            attachPoint = PATTACH_POINT_FOLLOW;
        end

        particleId = ParticleManager:CreateParticle(particlePath, attachPoint, target);

        local args = { ... };
        if args and #args > 0 then
            for i = 1, #args do
                ParticleManager:SetParticleControl(particleId, args[i].key, args[i].value);
            end
        else
            local anotherArgs = Particle:_getParticleArgs(particleName, target);
            if anotherArgs and #anotherArgs > 0 then
                for i = 1, #anotherArgs do
                    ParticleManager:SetParticleControl(particleId, anotherArgs[i].key, anotherArgs[i].value);
                end
            end
        end
    end

    local soundData = Particle:getParticleSound(particleName, soundType, index);
    if soundData ~= nil then
        target:EmitSound(soundData);
    end

    if isDebugEnabled(PARTICLE, CREATE) then
        debugLog(PARTICLE, CREATE, 'particle is CREATED: ' .. tostring(particleId));
    end

    return particleId;
end

function Particle:createParticleSet(particleName, target, attachPoint)
    local particleIds = {};
    if attachPoint == nil then
        attachPoint = PATTACH_POINT_FOLLOW;
    end

    local particlePaths = Particle:getParticleSetPaths(particleName);
    for _, path in pairs(particlePaths) do
        local particleId = ParticleManager:CreateParticle(path, attachPoint, target);
        particleIds[#particleIds + 1] = particleId;
    end

    return particleIds;
end

function Particle:destroyParticleSet(particleIds, immediateDelete)
    if immediateDelete == nil then
        immediateDelete = false;
    end

    for _, particleId in pairs(particleIds) do
        Particle:destroyParticle(particleId, immediateDelete);
    end
end

function Particle:fireSound(soundName, target)
    if soundName ~= nil and target ~= nil then
        target:EmitSound(soundName);
    end
end

function Particle:fireParticle(particleName, target, attachPoint, index, ...)
    if attachPoint == nil then
        attachPoint = PATTACH_POINT_FOLLOW;
    end

    local particleId = Particle:createParticle(particleName, target, attachPoint, 'SOUND.HIT', index, ...);

    if particleId ~= nil then
        Particle:destroyParticle(particleId, false);
    end

    return particleId;
end

function Particle:fireParticleDelay(particleName, target, attachPoint, delay, index, ...)
    if delay == nil or delay == 0 then
        Particle:fireParticle(particleName, target, attachPoint, index, ...);
        return nil;
    end

    if attachPoint == nil then
        attachPoint = PATTACH_POINT_FOLLOW;
    end

    local particleId = Particle:createParticle(particleName, target, attachPoint, 'SOUND.HIT', index, ...);

    if particleId == nil then
        return nil;
    end

    local dummy = CreateModifierThinker(DUMMY_UNIT, nil, 'modifier_particle_helper_dummy', { duration = delay, particleId = particleId }, Vector(0, 0, 0), target:GetTeamNumber(), false);

    return particleId;
end

function Particle:fireParticleLocation(particleName, location, attachPoint, delay, index, ...)
    local duration = math.min(10, (delay or 0)) + 5;

    local dummy = CreateModifierThinker(DUMMY_UNIT, nil, 'modifier_particle_helper_dummy', { duration = duration }, location, 0, false);
    local particleId = Particle:fireParticleDelay(particleName, dummy, attachPoint, delay, index, ...);

    return particleId;
end

function Particle:missileHit(particleName, target)
    local soundData = Particle:getParticleSound(particleName, 'SOUND.HIT');
    if soundData ~= nil then
        target:EmitSound(soundData);
    end
end

function Particle:playSound(soundName, target, isLoop)
    if not isLoop then
        target:EmitSound(soundName);
        return;
    end

    print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

    if target._sounds == nil then
        target._sounds = {};
    end

    if target._sounds[soundName] == nil then
        target._sounds[soundName] = {
            stack = 0;
        };
    end

    if target._sounds[soundName].stack == 0 then
        target:EmitSound(soundName);
    end

    target._sounds[soundName].stack = target._sounds[soundName].stack + 1;
end

function Particle:stopSound(soundName, target)
    if not soundName or not target then
        return;
    end

    if not target._sounds or not target._sounds[soundName] or not target._sounds[soundName].stack then
        target:StopSound(soundName);
        return;
    end

    target._sounds[soundName].stack = target._sounds[soundName].stack - 1;

    if target._sounds[soundName].stack == 0 then
        target:StopSound(soundName);
    end
end

LinkLuaModifier('modifier_particle_helper_dummy', 'effects/particle.lua', LUA_MODIFIER_MOTION_NONE);

modifier_particle_helper_dummy = class({});

function modifier_particle_helper_dummy:OnCreated(keys)
    self._ToAParticleId = keys.particleId or nil;

    if isDebugEnabled(PARTICLE, DUMMY) then
        debugLog(PARTICLE, DUMMY, 'dummy is CREATED: ' .. tostring(self:GetParent()));
    end
end

function modifier_particle_helper_dummy:OnDestroy()
    local dummy = self:GetParent();
    local particleId = self._ToAParticleId or nil;

    if particleId ~= nil then
        Particle:destroyParticle(particleId, false);
    end

    if isDebugEnabled(PARTICLE, DUMMY) then
        debugLog(PARTICLE, DUMMY, 'dummy is DESTROYED: ' .. tostring(dummy));
    end
end
