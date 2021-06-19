Battle._attackRecordMap = {};

function Battle:registerAttackEvent(unit)
    print('reggggggggggsiter');
    print(Utility:formatUnitLog(unit));

    if not unit:HasModifier('modifier_normal_attack') then
        unit:AddNewModifier(nil, ABILITY_EFFECT_DUMMY, 'modifier_normal_attack', {});
    end
end

--- Determine whether attack is landed or dodged
---@param attacker unit
---@param target unit
---@param flag boolean
---@return boolean
function Battle:isAttackLanded(attacker, target, flag, ...)
    if flag then
        return true;
    end

    local hitThrehold = Battle.Attribute:getUnitAttribute(Battle.Attribute.ENUM.ATTACK.HIT, attacker) *
                            GAME.RANDOM.RATIO;

    if RandomFloat(0, GAME.RANDOM.MAX) <= hitThrehold then
        return true;
    end

    local evadeThrehold = Battle.Attribute:getUnitAttribute(Battle.Attribute.ENUM.ATTACK.EVADE, target) *
                              GAME.RANDOM.RATIO;

    if RandomFloat(0, GAME.RANDOM.MAX) <= evadeThrehold then
        Battle:evadeEvent(attacker, target);

        return false;
    end

    return true;
end

--- Determine whether attack is critical strike
---@param attacker unit
---@return boolean
function Battle:isCriticalAttack(attacker, ...)
    local threhold = Battle.Attribute:getUnitAttribute(Battle.Attribute.ENUM.CRIT.RATE, attacker) * GAME.RANDOM.RATIO;

    if RandomFloat(0, GAME.RANDOM.MAX) <= threhold then
        return true;
    end

    return false;
end

--- Determine whether damage is elemental damage
---@param elem any
---@param elemLev number
---@return boolean
local _isElementalDamage = function (elem, elemLev)
    local threhold = (GAME.ELEM.RATE.BASE + GAME.ELEM.RATE.GROWTH * elemLev) * GAME.RANDOM.RATIO;
    return RandomFloat(0, GAME.RANDOM.MAX) <= threhold;
end

local _doElementEffect = function (attacker, target, dmgObj)
    if not dmgObj.element then
        return;
    end

    local elem = dmgObj.element;
    Particle:fireParticle('ICE_IMPACT', target, PATTACH_POINT_FOLLOW);
end

local _addFireDamage = function (attacker, target, dmgObj)
    if not dmgObj.element or not dmgObj.element == GAME.ELEM.ENUM.FIRE then
        return;
    end

    local elem = GAME.ELEM.ENUM.FIRE;

    local elemLev = Battle.Attribute:getUnitAttribute(Battle.Attribute.ENUM.ELEM[elem], attacker);
    local elemRes = Battle.Attribute:getUnitAttribute(Battle.Attribute.ENUM.RES[elem], target);
    local enhance = 0;
    local diff = elemLev - elemRes;

    if diff >= 0 then
        enhance = math.min(diff, GAME.ELEM.MAX_LEV) * GAME.ELEM.DMG_BONUS;
    else
        enhance = GAME.ELEM.DMG_RES;
    end

    dmgObj.enhance = (dmgObj.enhance or 0) + enhance;
end

local _addIceDamage = function (attacker, target, dmgObj)
    if not dmgObj.element or not dmgObj.element == GAME.ELEM.ENUM.ICE then
        return;
    end

    local elem = GAME.ELEM.ENUM.ICE;

    local elemLev = Battle.Attribute:getUnitAttribute(Battle.Attribute.ENUM.ELEM[elem], attacker);
    local elemRes = Battle.Attribute:getUnitAttribute(Battle.Attribute.ENUM.RES[elem], target);
    local enhance = 0;
    local diff = elemLev - elemRes;

    if diff >= 0 then
        enhance = math.min(diff, GAME.ELEM.MAX_LEV) * GAME.ELEM.DMG_BONUS;
    else
        enhance = GAME.ELEM.DMG_RES;
    end

    dmgObj.enhance = (dmgObj.enhance or 0) + enhance;
end

local _addThunderDamage = function (attacker, target, dmgObj)
    if not dmgObj.element or not dmgObj.element == GAME.ELEM.ENUM.THUNDER then
        return;
    end

    local elem = GAME.ELEM.ENUM.THUNDER;

    local elemLev = Battle.Attribute:getUnitAttribute(Battle.Attribute.ENUM.ELEM[elem], attacker);
    local elemRes = Battle.Attribute:getUnitAttribute(Battle.Attribute.ENUM.RES[elem], target);
    local enhance = 0;
    local diff = elemLev - elemRes;

    if diff >= 0 then
        enhance = math.min(diff, GAME.ELEM.MAX_LEV) * GAME.ELEM.DMG_BONUS;
    else
        enhance = GAME.ELEM.DMG_RES;
    end

    dmgObj.enhance = (dmgObj.enhance or 0) + enhance;
end

local _addElementalDamage = function (attacker, target, dmgObj)
    if not dmgObj.element then
        return;
    end

    if dmgObj.element == GAME.ELEM.ENUM.FIRE then
        _addFireDamage(attacker, target, dmgObj);
    elseif dmgObj.element == GAME.ELEM.ENUM.ICE then
        _addIceDamage(attacker, target, dmgObj);
    elseif dmgObj.element == GAME.ELEM.ENUM.THUNDER then
        _addThunderDamage(attacker, target, dmgObj);
    end
end

function Battle:elementalize(attacker, target, dmgObj)
    local element, elemDiff = dmgObj.element, nil;

    if element == false then
        return;
    end

    -- 如果存在默认的元素状态
    if element == nil then
        local isAttack = dmgObj.isAttack or false;

        for _, elem in pairs(GAME.ELEM.ENUM) do
            local lev = Battle.Attribute:getUnitAttribute(Battle.Attribute.ENUM.ELEM[elem], attacker);

            if lev > 0 and _isElementalDamage(elem, lev) then
                local res = Battle.Attribute:getUnitAttribute(Battle.Attribute.ENUM.RES[elem], target);

                if element == nil or elemDiff < lev - res then
                    element = elem;
                    elemDiff = lev - res;
                end
            end
        end
    end

    print('Element of this damage is: ' .. tostring(element));

    dmgObj.element = element;
    _addElementalDamage(attacker, target, dmgObj);
end

function Battle:enhanceDmgObj(attacker, target, dmgObj)
    if not attacker or not target or not dmgObj then
        return dmgObj or {};
    end

    dmgObj.enhance = dmgObj.enhance or 0;
    local damage = dmgObj.damage or 0;

    -- 如果是普通攻击
    if dmgObj.isAttack then
        if dmgObj.isCrit then
            damage = damage * Battle.Attribute:getUnitAttribute(Battle.Attribute.ENUM.CRIT.DAMAGE, attacker) * 0.01;
        end

        damage = damage + damage * Battle.Attribute:getUnitAttribute(Battle.Attribute.ENUM.ATTACK.ENHANCE, attacker) *
                     0.01;
    end

    -- 伤害补正, 例如只造成 0.5 倍的普攻伤害
    if dmgObj.dmgRatio ~= nil and type(dmgObj.dmgRatio) == 'number' then
        damage = damage * dmgObj.dmgRatio;
    end

    dmgObj.damage = damage;
    Battle:elementalize(attacker, target, dmgObj);

    -- final step to enhance damage
    if dmgObj.enhance ~= 0 then
        damage = damage + damage * dmgObj.enhance * 0.01;
    end

    dmgObj.damage = damage;
end

function Battle:performAttack(attacker, target, dmgObj)
    if not attacker or not target then
        return;
    end

    -- 命中/闪避事件
    if not Battle:isAttackLanded(attacker, target) then
        ToAGame:evadeEvent(attacker, target);
        return;
    end

    -- 暴击事件
    local isCrit = Battle:isCriticalAttack(attacker);
    local damage = attacker:GetAttackDamage();

    dmgObj = dmgObj or {};
    dmgObj.isAttack = true;
    dmgObj.isCrit = isCrit;
    dmgObj.damage = damage;

    -- 伤害增强的部分
    Battle:enhanceDmgObj(attacker, target, dmgObj);
end

modifier_normal_attack = class({});

LinkLuaModifier('modifier_normal_attack', 'battle/damage.lua', LUA_MODIFIER_MOTION_NONE);

function modifier_normal_attack:OnCreated()
end

function modifier_normal_attack:IsHidden()
    return true;
end

function modifier_normal_attack:IsPermanent()
    return true;
end

function modifier_normal_attack:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE_POST_CRIT,
            MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE};
end

function modifier_normal_attack:OnAttackLanded(events)
    if self:GetParent() ~= events.attacker then
        return;
    end

    local record = Battle._attackRecordMap[events.record];
    print('.................... ' .. Utility:formatUnitLog(self:GetParent()));

    if not record or not record.dmgObj then
        return;
    end

    local dmgObj = record.dmgObj;
    local attacker = record.attacker;
    local target = record.target;

    if record.isCrit then
        print(events.record);
        Particle:fireParticle('CRIT_IMPACT', target, PATTACH_POINT_FOLLOW);
    end

    if dmgObj.element then
        _doElementEffect(attacker, target, dmgObj);
    end
end

function modifier_normal_attack:GetModifierPreAttack_CriticalStrike(events)
    if self:GetParent() ~= events.attacker then
        return;
    end

    print('Pre attack critical ' .. tostring(events.record));

    local record = Battle._attackRecordMap[events.record];

    if not record.isAttackLanded then
        return 0;
    end

    if record.isAttackLanded and record.isCrit then
        return GAME.CRIT_CORR.DAMAGE;
    end

    return 100;
end

function modifier_normal_attack:GetModifierPreAttack_BonusDamagePostCrit(events)
    if self:GetParent() ~= events.attacker then
        return;
    end

    print('Attack bonus damage ' .. tostring(events.record));

    local attacker, target = events.attacker, events.target;
    local damage = attacker:GetAttackDamage();

    local isAttackLanded = Battle:isAttackLanded(attacker, target);
    local isCrit = isAttackLanded and Battle:isCriticalAttack(attacker) or false;

    Battle._attackRecordMap[events.record] = {
        isAttackLanded = isAttackLanded,
        isCrit = isCrit,
        attacker = attacker,
        target = target
    };

    if not isAttackLanded then
        ToAGame:evadeEvent(attacker, target);
        return -damage;
    end

    local dmgObj = {};
    dmgObj.isAttack = true;
    dmgObj.isCrit = isCrit;
    dmgObj.damage = damage;

    -- 伤害增强的部分
    Battle:enhanceDmgObj(attacker, target, dmgObj);

    Battle._attackRecordMap[events.record].dmgObj = dmgObj;

    -- 补正因为暴击伤害增加的部分
    if isCrit then
        return dmgObj.damage - damage * GAME.CRIT_CORR.RATIO;
    end

    return dmgObj.damage - damage;
end
