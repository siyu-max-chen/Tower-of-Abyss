local ATTRIBUTE = 'ATTRIBUTE';
local CHECK = 'CHECK';

LinkLuaModifier('modifier_attribute_attack_speed', 'effects/ability_effect_dummy.lua',
    LUA_MODIFIER_MOTION_NONE);

modifier_attribute_attack_speed = class({});

function modifier_attribute_attack_speed:OnCreated(keys)    
    self._ToABonusValue = keys._ToABonusValue;
end

function modifier_attribute_attack_speed:OnRefresh(keys)    
    self._ToABonusValue = keys._ToABonusValue;
end

function modifier_attribute_attack_speed:IsHidden()
    return false;
end

function modifier_attribute_attack_speed:IsPermanent()
    return true;
end

function modifier_attribute_attack_speed:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    };
end

function modifier_attribute_attack_speed:GetModifierAttackSpeedBonus_Constant()
    return self._ToABonusValue;
end

function Battle.Attribute:_getUnitAttackSpeed(unit)
    return unit:GetAttackSpeed() * 100;
end

function Battle.Attribute:_setUnitAttackSpeed(unit, value)
    if IsServer() then
        if unit._ToAUnitAttributeVal == nil then
            unit._ToAUnitAttributeVal = {};
        end

        local attackSpeed = unit._ToAUnitAttributeVal and unit._ToAUnitAttributeVal['ATTACK_SPEED'];

        if type(attackSpeed) ~= 'number' then
            attackSpeed = 0;
        end

        attackSpeed = attackSpeed + value;
        unit._ToAUnitAttributeVal['ATTACK_SPEED'] = attackSpeed;

        unit:AddNewModifier(nil, ABILITY_EFFECT_DUMMY, 'modifier_attribute_attack_speed', { _ToABonusValue = attackSpeed });
    end

    if isDebugEnabled(ATTRIBUTE, CHECK) then
        debugLog(ATTRIBUTE, CHECK, Battle.Attribute:formatAttributeCheckLog(Attribute.ENUM.ATTACK_SPEED, unit, Battle.Attribute:_getUnitAttackSpeed(unit)));
    end
end
