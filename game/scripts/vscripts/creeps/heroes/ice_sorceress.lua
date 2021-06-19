local HERO = 'HERO';
local INIT = 'INIT';

if IceSorceress == nil then
    _G.IceSorceress = class({});
end

Hero['IceSorceress'] = IceSorceress;

function IceSorceress:_initialize(entity)
    if IceSorceress._entity ~= nil then
        return;
    end

    IceSorceress._entity = entity;

    IceSorceress._entity._particles = {
        set = {
            DEFAULT = Particle:createParticleSet('ICE_SORCERESS.AMBIENTS', IceSorceress._entity, PATTACH_POINT_FOLLOW)
        },
        staff1 = Particle:createParticle('ICE_SORCERESS.AMBIENTS.STAFF1', IceSorceress._entity, PATTACH_POINT_FOLLOW),
        staff2 = Particle:createParticle('ICE_SORCERESS.AMBIENTS.STAFF2', IceSorceress._entity, PATTACH_POINT_FOLLOW),
        arm = Particle:createParticle('ICE_SORCERESS.AMBIENTS.ARM', IceSorceress._entity, PATTACH_POINT_FOLLOW),
    };

    ParticleManager:SetParticleControlEnt(IceSorceress._entity._particles['staff1'], 0, IceSorceress._entity,
        PATTACH_POINT_FOLLOW, 'attach_attack2', IceSorceress._entity:GetAbsOrigin(), true);

    ParticleManager:SetParticleControlEnt(IceSorceress._entity._particles['staff2'], 0, IceSorceress._entity, PATTACH_POINT_FOLLOW, 'attach_staff_tip',
        IceSorceress._entity:GetAbsOrigin(), true);

    ParticleManager:SetParticleControlEnt(IceSorceress._entity._particles['arm'], 0, IceSorceress._entity, PATTACH_POINT_FOLLOW, 'attach_hitloc',
        IceSorceress._entity:GetAbsOrigin(), true);

    for controlPoint = 1, 3 do
        ParticleManager:SetParticleControlEnt(IceSorceress._entity._particles['arm'], controlPoint, IceSorceress._entity, PATTACH_POINT_FOLLOW,
            'attach_attack1', IceSorceress._entity:GetAbsOrigin(), true);
    end

    for controlPoint = 4, 6 do
        ParticleManager:SetParticleControlEnt(IceSorceress._entity._particles['arm'], controlPoint, IceSorceress._entity, PATTACH_POINT_FOLLOW,
            'attach_attack2', IceSorceress._entity:GetAbsOrigin(), true);
    end

    if isDebugEnabled(HERO, INIT) then
        debugLog(HERO, INIT, 'Hero Ice Sorceress init: ' .. Utility:formatUnitLog(entity));
    end
end

function IceSorceress:isInstance(entity)
    print(tostring(entity) .. '   ,   ' .. tostring(IceSorceress._entity));
    return entity and IceSorceress._entity == entity;
end

function IceSorceress:doFrostBlossom()
    local unit = IceSorceress._entity;
    local location = unit:GetOrigin();

    local enumGroup = FindUnitsInRadius(unit:GetTeamNumber(), location, nil, 1200, DOTA_UNIT_TARGET_TEAM_ENEMY,
                          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER,
                          false);

    local target = nil;
    if #enumGroup > 0 then
        for _, enum in pairs(enumGroup) do
            if enum ~= nil and (not enum:IsMagicImmune()) and (not enum:IsInvulnerable()) then
                target = enum;
                break
            end
        end
    end

    if target ~= nil then
        Particle:fireParticle('ICE_SORCERESS.ICE_NOVA', target, PATTACH_POINT_FOLLOW);
        Particle:fireParticle('ICE_SORCERESS.ICE_FROST_WIND', target, PATTACH_POINT);
    end

    Modifier:addBuffToUnit(Modifier.Debuff.freezing, IceSorceress._entity, 10);
end
