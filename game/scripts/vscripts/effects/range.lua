require('effects/effect');
require('effects/missile');

LinkLuaModifier('modifier_effects_dummy', 'effects/range.lua', LUA_MODIFIER_MOTION_NONE);

function ToAEffect:doScreamingDaggers(caster, location, level)
    local range = 550;
    local enumGroup = FindUnitsInRadius(caster:GetTeamNumber(), location, nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false);
    local count, countMax = 0, 3;

    Particle:fireParticleLocation('SCREAMING', location, PATTACH_POINT_FOLLOW);

    if #enumGroup > 0 then
        for _, enum in pairs(enumGroup) do
            if enum ~= nil and (not enum:IsMagicImmune()) and (not enum:IsInvulnerable()) then

                ToAEffect:doThrowDagger(caster, enum, level, location);
                count = count + 1;
            end

            if count >= countMax then
                break;
            end
        end
    end
end

modifier_effects_dummy = class({});

