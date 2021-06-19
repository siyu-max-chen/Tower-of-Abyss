ability_effect_dummy = class({});

function ability_effect_dummy:OnAbilityPhaseStart()
end

function ability_effect_dummy:OnSpellStart()
    if ABILITY_EFFECT_DUMMY == nil then
        _G.ABILITY_EFFECT_DUMMY = self;
        print('ABILITY_EFFECT_DUMMY ' .. 'has been initialized!');
    end
end

function ability_effect_dummy:OnProjectileHitHandle(hTarget, vLocation, iProjectileHandle)
    local missileId = iProjectileHandle;

    if missileId == nil or ToAEffect.missileEventTable[missileId] == nil or ToAEffect.missileEventTable[missileId].init ~= true then
        return;
    end

    local table = ToAEffect.missileEventTable[missileId];
    local caster, target, level, callbackFunc = table.caster, table.target, table.level, table.callback;

    callbackFunc(ToAEffect, caster, target, level);
    ToAEffect:unregisterMissileEvent(missileId);
end
