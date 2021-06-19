ability_frost_blast = class({});

-- 可以作为关键的内容来定义, 例如 getCacheTable
ability_frost_blast.cacheTable = {};

function ability_frost_blast:getAbilitySpecLev(unit)
    if unit == nil or unit.ability_frost_blast == nil or unit.ability_frost_blast.specLev == nil then
        return 0;
    end

    return unit.ability_frost_blast.specLev;
end

function ability_frost_blast:saveMissileInfo(missileId, missileLevel)
    ability_frost_blast.cacheTable[missileId] = {};
    ability_frost_blast.cacheTable[missileId].level = missileLevel;
end

function ability_frost_blast:getMissileLevel(missileId)
    return ability_frost_blast.cacheTable[missileId].level or 0;
end

function ability_frost_blast:OnAbilityPhaseStart()
    local caster = self:GetCaster();
    Particle:fireParticle('FROST_CAST', caster, PATTACH_ABSORIGIN_FOLLOW);

    return true;
end

function ability_frost_blast:OnSpellStart()
    local caster = self:GetCaster();
    local target = self:GetCursorTarget();
    self.speed = 625;

    Ability:onCast(self, caster);

    local missileId = Particle:createMissile('CHAIN_FROST', {
        ability = self, speed = self.speed, caster = caster, target = target
    });

    ability_frost_blast:saveMissileInfo(missileId, 0);
end

function ability_frost_blast:OnProjectileHitHandle(hTarget, vLocation, iProjectileHandle)
    local caster = self:GetCaster();
    local target = hTarget;
    local targetLocation = target:GetOrigin();
    local missileLevel = self:getMissileLevel(iProjectileHandle);

    local missileInfo = { ability = self, speed = 550 };

    if missileLevel == 0 then
        Particle:missileHit('CHAIN_FROST', target);
        Particle:fireParticle('FROST_BLAST_HIT', target, PATTACH_ABSORIGIN_FOLLOW);
        
        local counter, maxCount = 0, 4;
        local enumGroup = FindUnitsInRadius(caster:GetTeamNumber(), targetLocation, self, 475, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false);

        if #enumGroup > 0 and counter < maxCount then    
            for _, enum in pairs(enumGroup) do
                if enum ~= nil and (not enum:IsMagicImmune()) and (not enum:IsInvulnerable()) and enum ~= target then                    
                    missileInfo.caster = target;
                    missileInfo.target = enum;
                    local missileId = Particle:createMissile('FROST_BLAST', missileInfo);

                    ability_frost_blast:saveMissileInfo(missileId, 1);
                    counter = counter + 1;
                end

                if counter >= maxCount then
                    break;
                end
            end
        end
    end

    if missileLevel == 1 then
        Particle:missileHit('FROST_BLAST', target);
        
        local counter = 0;
        local maxCount = 4;
        local enumGroup = FindUnitsInRadius(caster:GetTeamNumber(), targetLocation, self, 475, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false);
        missileInfo.speed = 375;

        if #enumGroup > 0 and counter < maxCount then
            for _, enum in pairs(enumGroup) do
                if enum ~= nil and (not enum:IsMagicImmune()) and (not enum:IsInvulnerable()) and enum ~= target then
                    missileInfo.caster = target;
                    missileInfo.target = enum;
                    local missileId = Particle:createMissile('FROST_MISSILE', missileInfo);
                    
                    ability_frost_blast:saveMissileInfo(missileId, 2);
                    counter = counter + 1;
                end

                if counter >= maxCount then
                    break;
                end
            end
        end
    end

    if missileLevel == 2 then
        Particle:missileHit('FROST_MISSILE', target);
    end
end
