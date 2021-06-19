local BUFF_INTERVAL = 0.05;
require('utils/queue');

local _getUnitBuffTable = function (unit)
    if not unit then
        return nil;
    end

    if not unit._buff then
        unit._buff = {};
    end
    return unit._buff;
end

------------------------ Burning ---------------------------
------------------------------------------------------------

modifier_buff_burning = class({});

function modifier_buff_burning:OnCreated()
    local unit = self:GetParent();
    local unitBuffTable = _getUnitBuffTable(unit);
    local BUFFNAME = 'burning';

    -- error
    if not unitBuffTable then
        return;
    end

    if not unitBuffTable[BUFFNAME] or not unitBuffTable[BUFFNAME].particleId then
        unitBuffTable[BUFFNAME] = {
            particleId = Particle:createParticle('BuffBuring', unit);
        };

        unit:EmitSound('Hero_Jakiro.DualBreath.Burn');
    end
end

function modifier_buff_burning:OnDestroy()
    local unit = self:GetParent();
    local unitBuffTable = _getUnitBuffTable(unit);
    local BUFFNAME = 'burning';

    if unit and unitBuffTable and unitBuffTable[BUFFNAME] and unitBuffTable[BUFFNAME].particleId ~= nil then
        Particle:destroyParticle(unitBuffTable[BUFFNAME].particleId);
        unitBuffTable[BUFFNAME] = nil;

        unit:StopSound('Hero_Jakiro.DualBreath.Burn');
    end
end

function modifier_buff_burning:GetTexture()
    return 'phoenix_sun_ray'
end

function modifier_buff_burning:IsDebuff()
    return true;
end


------------------------ Freezing ---------------------------
------------------------------------------------------------

modifier_buff_freezing = class({});

local _compareFreezingBuff = function(obj1, obj2)
    return obj1.expireAt - obj2.expireAt;
end

function modifier_buff_freezing:transDuration(counter, duration)
    local expiration = counter + math.floor(duration / BUFF_INTERVAL);
    expiration = math.max(expiration, counter + 1);

    return expiration;
end

function modifier_buff_freezing:OnCreated(params)
    local unit = self:GetParent();
    local unitBuffTable = _getUnitBuffTable(unit);
    local BUFFNAME = 'freezing';

    if not unitBuffTable then
        return;
    end

    if not unitBuffTable[BUFFNAME] or not unitBuffTable[BUFFNAME].particleId then
        unitBuffTable[BUFFNAME] = {
            particleId = Particle:createParticle('BuffFreezing', unit, PATTACH_OVERHEAD_FOLLOW);
        };
    end

    if IsServer() then
        local stackMax = tonumber(Modifier.Debuff.freezing.property.stack);
        
        if not unit._buffFreezingData or not #unit._buffFreezingData then
            unit._buffFreezingData = {
                timeFrame = 0,
                stack = 0,
                attackSpeed = 0, moveSpeed = 0,
                queue = PriorityQueue:new(stackMax, _compareFreezingBuff);
            };
        end

        -- 更新层数的独立计算时间
        local duration = params.duration or Modifier.Debuff.freezing.defaultDuration or 0;
        local expireAt = modifier_buff_freezing:transDuration(unit._buffFreezingData.timeFrame, duration);
        unit._buffFreezingData.queue:add({ expireAt = expireAt });

        if unit._buffFreezingData.stack + 1 <= stackMax then
            local attackSpeedInc = tonumber(Modifier.Debuff.freezing.property.attackSpeedDec);
            local moveSpeedInc = tonumber(Modifier.Debuff.freezing.property.moveSpeedDec);

            Battle.Attribute:incrementUnitAttribute(Battle.Attribute.ENUM.ATTACK_SPEED,         unit, attackSpeedInc,   false);
            Battle.Attribute:incrementUnitAttribute(Battle.Attribute.ENUM.MOVE_SPEED.ENHANCE,   unit, moveSpeedInc,     false);

            unit._buffFreezingData.stack = unit._buffFreezingData.stack + 1;
            unit._buffFreezingData.attackSpeed = unit._buffFreezingData.attackSpeed + attackSpeedInc;
            unit._buffFreezingData.moveSpeed = unit._buffFreezingData.moveSpeed + moveSpeedInc;
        else
        end

        unit:SetModifierStackCount('modifier_buff_freezing', nil, unit._buffFreezingData.stack);

        -- 更新 stack 的 buff 显示
        if unitBuffTable[BUFFNAME].particleId ~= nil then
            ParticleManager:SetParticleControl(unitBuffTable[BUFFNAME].particleId, 1, Vector(0, unit._buffFreezingData.stack, 0));
        end
    end

    self:StartIntervalThink(BUFF_INTERVAL);
end

function modifier_buff_freezing:OnRefresh(params)
    local unit = self:GetParent();
    local unitBuffTable = _getUnitBuffTable(unit);
    local BUFFNAME = 'freezing';

    if IsServer() then
        local stackMax = tonumber(Modifier.Debuff.freezing.property.stack);

        -- 更新层数的独立计算时间
        local duration = params.duration or Modifier.Debuff.freezing.defaultDuration or 0;
        local expireAt = modifier_buff_freezing:transDuration(unit._buffFreezingData.timeFrame, duration);
        unit._buffFreezingData.queue:add({ expireAt = expireAt });

        if unit._buffFreezingData.stack + 1 <= stackMax then
            local attackSpeedInc =  tonumber(Modifier.Debuff.freezing.property.attackSpeedDec);
            local moveSpeedInc   =  tonumber(Modifier.Debuff.freezing.property.moveSpeedDec);

            Battle.Attribute:incrementUnitAttribute(Battle.Attribute.ENUM.ATTACK_SPEED,         unit, attackSpeedInc,   false);
            Battle.Attribute:incrementUnitAttribute(Battle.Attribute.ENUM.MOVE_SPEED.ENHANCE,   unit, moveSpeedInc,     false);

            unit._buffFreezingData.stack = unit._buffFreezingData.stack + 1;
            unit._buffFreezingData.attackSpeed = unit._buffFreezingData.attackSpeed + attackSpeedInc;
            unit._buffFreezingData.moveSpeed = unit._buffFreezingData.moveSpeed + moveSpeedInc;
        else
        end

        unit:SetModifierStackCount('modifier_buff_freezing', nil, unit._buffFreezingData.stack);

        -- 更新 stack 的 buff 显示
        if unitBuffTable[BUFFNAME].particleId ~= nil then
            ParticleManager:SetParticleControl(unitBuffTable[BUFFNAME].particleId, 1, Vector(0, unit._buffFreezingData.stack, 0));
        end
    end
end

function modifier_buff_freezing:OnIntervalThink(params)
    local unit = self:GetParent();
    local unitBuffTable = _getUnitBuffTable(unit);
    local BUFFNAME = 'freezing';

    if IsServer() then
        if not unit or not unit._buffFreezingData then
            return;
        end

        local stackDec = 0;
        unit._buffFreezingData.timeFrame = unit._buffFreezingData.timeFrame + 1;

        while unit._buffFreezingData.queue ~= nil do
            local peekData = unit._buffFreezingData.queue:peek();

            -- 如果 queue 为空, 或者最小值比当前时间要大
            if peekData == nil or peekData.expireAt > unit._buffFreezingData.timeFrame then
                break;
            end

            stackDec = stackDec + 1;
            unit._buffFreezingData.queue:poll();
        end

        if stackDec == unit._buffFreezingData.stack then
            self:Destroy();
            return;
        end

        if stackDec > 0 then
            local attackSpeedInc =  tonumber(Modifier.Debuff.freezing.property.attackSpeedDec)  * stackDec;
            local moveSpeedInc   =  tonumber(Modifier.Debuff.freezing.property.moveSpeedDec)    * stackDec;

            Battle.Attribute:incrementUnitAttribute(Battle.Attribute.ENUM.ATTACK_SPEED,         unit,   attackSpeedInc,   true);
            Battle.Attribute:incrementUnitAttribute(Battle.Attribute.ENUM.MOVE_SPEED.ENHANCE,   unit,   moveSpeedInc,     true);

            unit._buffFreezingData.stack = unit._buffFreezingData.stack - stackDec;
            unit._buffFreezingData.attackSpeed = unit._buffFreezingData.attackSpeed - attackSpeedInc;
            unit._buffFreezingData.moveSpeed = unit._buffFreezingData.moveSpeed - moveSpeedInc;

            unit:SetModifierStackCount('modifier_buff_freezing', nil, unit._buffFreezingData.stack);

            -- 更新 stack 的 buff 显示
            if unitBuffTable[BUFFNAME].particleId ~= nil then
                ParticleManager:SetParticleControl(unitBuffTable[BUFFNAME].particleId, 1, Vector(0, unit._buffFreezingData.stack, 0));
            end
        end
    end
end

function modifier_buff_freezing:OnDestroy()
    local unit = self:GetParent();
    local unitBuffTable = _getUnitBuffTable(unit);
    local BUFFNAME = 'freezing';

    if unit and unitBuffTable and unitBuffTable[BUFFNAME] and unitBuffTable[BUFFNAME].particleId ~= nil then
        Particle:destroyParticle(unitBuffTable[BUFFNAME].particleId);
        unitBuffTable[BUFFNAME] = nil;
    end

    if IsServer() and unit and unit._buffFreezingData then
        Battle.Attribute:incrementUnitAttribute(Battle.Attribute.ENUM.ATTACK_SPEED,         unit, unit._buffFreezingData.attackSpeed,   true);
        Battle.Attribute:incrementUnitAttribute(Battle.Attribute.ENUM.MOVE_SPEED.ENHANCE,   unit, unit._buffFreezingData.moveSpeed,     true);

        unit._buffFreezingData = nil;
    end
end

function modifier_buff_freezing:GetTexture()
    return 'ancient_apparition_chilling_touch';
end

function modifier_buff_freezing:IsDebuff()
    return true;
end


------------------------ Overcharge ---------------------------
------------------------------------------------------------

modifier_buff_overcharge = class({});

function modifier_buff_overcharge:OnCreated()
    local unit = self:GetParent();
    local unitBuffTable = _getUnitBuffTable(unit);
    local BUFFNAME = 'overcharge';

    -- error
    if not unitBuffTable then
        return;
    end

    if not unitBuffTable[BUFFNAME] or not unitBuffTable[BUFFNAME].particleId then
        local particleId = Particle:createParticle('BuffOvercharge', unit);
        unitBuffTable[BUFFNAME] = { particleId = particleId };

        unit:EmitSound('Hero_Disruptor.ThunderStrike.Thunderator');
    end
end

function modifier_buff_overcharge:OnDestroy()
    local unit = self:GetParent();
    local unitBuffTable = _getUnitBuffTable(unit);
    local BUFFNAME = 'overcharge';

    if unit and unitBuffTable and unitBuffTable[BUFFNAME] and unitBuffTable[BUFFNAME].particleId ~= nil then
        Particle:destroyParticle(unitBuffTable[BUFFNAME].particleId);
        unitBuffTable[BUFFNAME] = nil;

        unit:EmitSound('Hero_Disruptor.ThunderStrike.Target');
    end
end

function modifier_buff_overcharge:GetTexture()
    return 'storm_spirit_electric_vortex';
end

function modifier_buff_overcharge:IsDebuff()
    return true;
end
