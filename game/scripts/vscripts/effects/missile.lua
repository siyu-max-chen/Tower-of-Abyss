require('effects/effect');

function ToAEffect:onThrowDaggerHit(caster, target, level)
    Particle:missileHit('THROW_DAGGER', target);
end

function ToAEffect:doThrowDagger(caster, target, level, location)
    local speed, missileId = 625, nil;

    if location == nil then
        missileId = Particle:createMissile('THROW_DAGGER', {
            ability = ABILITY_EFFECT_DUMMY, speed = speed, caster = caster, target = target
        });
    else
        missileId = Particle:createMissileLocation('THROW_DAGGER', {
            ability = ABILITY_EFFECT_DUMMY, speed = speed, location = location, target = target
        });
    end

    ToAEffect:registerMissileEvent(missileId, caster, target, level, ToAEffect.onThrowDaggerHit);
end
