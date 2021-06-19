local ATTRIBUTE = 'ATTRIBUTE';
local LOAD_DATA = 'LOAD_DATA';
local CHANGE = 'CHANGE';

Attribute = class({});
Battle.Attribute = Attribute;

local attributeDataMap = class({});

_G.getAttributeByName = function(attributeName)
    if not attributeName or (type(attributeName) ~= 'string') or not attributeDataMap[attributeName] then
        return nil;
    end

    return attributeDataMap[attributeName];
end

function Attribute:_isValidAttribute(attribute)
    return attribute and attribute.name and true or false;
end

function Attribute:_getUnitAttributeHelper(attribute, unit)
    if not unit or not Attribute:_isValidAttribute(attribute) then
        return 0;
    end

    return unit._ToAUnitAttributeVal and unit._ToAUnitAttributeVal[attribute.name] or 0;
end

function Attribute:_generateDefaultGetter(attribute)
    return function(self, unit)
        return Attribute:_getUnitAttributeHelper(attribute, unit);
    end
end

function Attribute:_setUnitAttributeHelper(attribute, unit, value)
    if not unit or not Attribute:_isValidAttribute(attribute) then
        return;
    end

    if unit._ToAUnitAttributeVal == nil then
        unit._ToAUnitAttributeVal = {};
    end

    unit._ToAUnitAttributeVal[attribute.name] = value;
end

function Attribute:_generateDefaultSetter(attribute)
    return function(self, unit, value)
        return Attribute:_setUnitAttributeHelper(attribute, unit, value);
    end
end

function Attribute:formatAttributeChangeLog(attribute, unit, prevVal, newVale)
    if attribute.isPercent then
        prevVal = tostring(prevVal) .. '%';
        newVale = tostring(newVale) .. '%';
    end

    return Utility:formatUnitLog(unit) .. ' ' .. attribute.name .. ' changed: ' .. tostring(prevVal) .. ' -> ' ..
               tostring(newVale);
end

function Attribute:formatAttributeCheckLog(attribute, unit, actualVal, expectVal)
    if attribute.isPercent then
        actualVal = tostring(actualVal) .. '%';
        expectVal = expectVal ~= nil and (tostring(expectVal) .. '%') or nil;
    end

    if expectVal == nil then
        return Utility:formatUnitLog(unit) .. ' ' .. attribute.name .. ' current is: ' .. tostring(actualVal);
    end

    return Utility:formatUnitLog(unit) .. ' ' .. attribute.name .. ' current is: ' .. tostring(actualVal) ..
               ' , actual is: ' .. tostring(expectVal);
end

require('battle/attribute_modifiers/attack_speed');
require('battle/attribute_modifiers/move_speed');

function Attribute:_initialize()
    Attribute.ENUM = {};
    local dataTable = Data:getDataTable('ATTRIBUTE', 'ENUM');

    if not dataTable then
        return;
    end

    for attributeName, val in pairs(dataTable) do
        Attribute:_initAttributeSingleTable(attributeName, Data:getDataTable('ATTRIBUTE', attributeName), true);
    end

    if isDebugEnabled(ATTRIBUTE, LOAD_DATA) then
        debugLog(ATTRIBUTE, LOAD_DATA, 'Attribute ENUM table is loaded: ');
        Utility:printObj(Attribute.ENUM, 'Attribute.ENUM');
    end

    if isDebugEnabled(ATTRIBUTE, LOAD_DATA) then
        debugLog(ATTRIBUTE, LOAD_DATA, 'Attribute Data table is loaded: ');
        Utility:printObjKeys(attributeDataMap, 'Attribute Name-Data Map');
    end
end

function Attribute:_initAttributeSingleTable(attributeName, attributePropertyTable, isRootNode, parentName)
    local result = {};

    -- 仅对初级节点, 加入 ENUM 中
    if isRootNode then
        Attribute.ENUM[attributeName] = result;
    end

    -- set attribute name with parent prefix
    if not isRootNode then
        attributeName = parentName .. '.' .. attributeName;
    end

    result.name = attributeName;

    -- load attr prop table
    if attributePropertyTable ~= nil and #attributePropertyTable then
        local hasGetterOrSetter = attributePropertyTable.getter or attributePropertyTable.setter;
        local isSet = attributePropertyTable.set and attributePropertyTable.set == 'true' and
                          attributePropertyTable.PROPS;

        if not isSet or hasGetterOrSetter then
            result.format = attributePropertyTable.format or '';
        end

        -- load getter
        if attributePropertyTable.getter == 'default' then
            result.getter = Attribute:_generateDefaultGetter(result);
        elseif attributePropertyTable.getter then
            local getterName = attributePropertyTable.getter;
            result.getter = Attribute[getterName];
        end

        -- load setter
        if attributePropertyTable.setter == 'default' then
            result.setter = Attribute:_generateDefaultSetter(result);
        elseif attributePropertyTable.setter then
            local setterName = attributePropertyTable.setter;
            result.setter = Attribute[setterName];
        end

        -- recursively load children subnodes
        if isSet then
            for subAttrName, subAttrTable in pairs(attributePropertyTable.PROPS) do
                result[subAttrName] = Attribute:_initAttributeSingleTable(subAttrName, subAttrTable, false,
                                          attributeName);
            end
        end
    end

    attributeDataMap[result.name] = result;

    return result;
end

function Attribute:getUnitAttribute(attribute, unit)
    if not unit or not Attribute:_isValidAttribute(attribute) then
        return 0;
    end

    return attribute.getter(Attribute, unit);
end

function Attribute:setUnitAttribute(attribute, unit, value)
    if not unit or not Attribute:_isValidAttribute(attribute) then
        return;
    end

    attribute.setter(Attribute, unit, value);
end

function Attribute:incrementUnitAttribute(attribute, unit, value, isIncrement)
    if not attribute or not unit or not value then
        return;
    end

    if isIncrement == false then
        value = -value;
    end

    local prevVal = Attribute:getUnitAttribute(attribute, unit);

    if prevVal ~= nil and attribute ~= Attribute.ENUM.ATTACK_SPEED then
        Attribute:setUnitAttribute(attribute, unit, prevVal + value);
    end

    if attribute == Attribute.ENUM.ATTACK_SPEED then
        Attribute:setUnitAttribute(attribute, unit, value);
    end

    if isDebugEnabled(ATTRIBUTE, CHANGE) then
        debugLog(ATTRIBUTE, CHANGE, Attribute:formatAttributeChangeLog(attribute, unit, prevVal,
            Attribute:getUnitAttribute(attribute, unit)));
    end
end
