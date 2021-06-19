ToAEffect = class({});
ToAEffect.missileEventTable = {};

function ToAEffect:registerMissileEvent(missileId, caster, target, level, callback)
    if ToAEffect.missileEventTable[missileId] and ToAEffect.missileEventTable[missileId].init == true then
        return false;
    end

    ToAEffect.missileEventTable[missileId] = {
        caster = caster, target = target, level = level, callback = callback,
        init = true
    };

    print(tostring(missileId) .. ' is registered!');
end

function ToAEffect:unregisterMissileEvent(missileId)
    if ToAEffect.missileEventTable[missileId] == nil or ToAEffect.missileEventTable[missileId].init ~= true then
        return;
    end

    ToAEffect.missileEventTable[missileId]= { init = false };
    ParticleManager:DestroyParticle(missileId, false);
    ParticleManager:ReleaseParticleIndex(missileId);

    print(tostring(missileId) .. ' has been unregistered!');
end

-- 标准的 OnProjectileHitHandle