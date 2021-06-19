local ATTRIBUTE = 'ATTRIBUTE';
local CHECK = 'CHECK';

LinkLuaModifier('modifier_attribute_move_speed_bonus', 'effects/ability_effect_dummy.lua', LUA_MODIFIER_MOTION_NONE);

modifier_attribute_move_speed_bonus = class({});

function modifier_attribute_move_speed_bonus:OnCreated(keys)
    self._ToABonusValue = keys._ToABonusValue;
end

function modifier_attribute_move_speed_bonus:OnRefresh(keys)
    self._ToABonusValue = keys._ToABonusValue;
end

function modifier_attribute_move_speed_bonus:IsHidden()
    return false;
end

function modifier_attribute_move_speed_bonus:IsPermanent()
    return true;
end

function modifier_attribute_move_speed_bonus:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT};
end

function modifier_attribute_move_speed_bonus:GetModifierMoveSpeedBonus_Constant()
    return self._ToABonusValue;
end

function Battle.Attribute:_getUnitMoveSpeed(unit)
    if not unit then
        return 0;
    end

    local moveSpeed = Battle.Attribute:_getUnitMoveSpeedBase(unit) *
                          (1 + 0.01 * Battle.Attribute:getUnitAttribute(Battle.Attribute.ENUM.MOVE_SPEED.ENHANCE, unit)) +
                          Battle.Attribute:getUnitAttribute(Battle.Attribute.ENUM.MOVE_SPEED.BONUS, unit);
    return moveSpeed;
end

function Battle.Attribute:_updateUnitMoveSpeed(unit)
    local offset = Battle.Attribute:_getUnitMoveSpeed(unit) - unit:GetBaseMoveSpeed();

    if IsServer() then
        unit:AddNewModifier(nil, ABILITY_EFFECT_DUMMY, 'modifier_attribute_move_speed_bonus', {
            _ToABonusValue = offset
        });
    end

    if isDebugEnabled(ATTRIBUTE, CHECK) then
        debugLog(ATTRIBUTE, CHECK,
            Battle.Attribute:formatAttributeCheckLog(Attribute.ENUM.MOVE_SPEED, unit,
                Battle.Attribute:_getUnitMoveSpeed(unit), unit:GetIdealSpeed()));
    end
end

function Battle.Attribute:_getUnitMoveSpeedBase(unit)
    if not unit then
        return 0;
    end

    return unit:GetBaseMoveSpeed() +
               Battle.Attribute:_getUnitAttributeHelper(Battle.Attribute.ENUM.MOVE_SPEED.BASE, unit);
end

function Battle.Attribute:_setUnitMoveSpeedBase(unit, value)
    -- 仅仅是对于 base 的特殊处理
    Battle.Attribute:_setUnitAttributeHelper(Battle.Attribute.ENUM.MOVE_SPEED.BASE, unit,
        value - unit:GetBaseMoveSpeed());
    Battle.Attribute:_updateUnitMoveSpeed(unit);
end

function Battle.Attribute:_setUnitMoveSpeedEnhance(unit, value)
    Battle.Attribute:_setUnitAttributeHelper(Attribute.ENUM.MOVE_SPEED.ENHANCE, unit, value);
    Battle.Attribute:_updateUnitMoveSpeed(unit);
end

function Battle.Attribute:_setUnitMoveSpeedBonus(unit, value)
    Battle.Attribute:_setUnitAttributeHelper(Attribute.ENUM.MOVE_SPEED.BONUS, unit, value);
    Battle.Attribute:_updateUnitMoveSpeed(unit);
end
