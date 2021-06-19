if _G.Modifier == nil then
    _G.Modifier = class({});
end

require('modifiers/generic_debuff');

function Modifier:_initialize()
    Modifier.Buff = {};
    Modifier.Debuff = {};

    print('Initialing....');

    local dataTable = Data:getDataTable('MODIFIER_DATA');

    if dataTable and dataTable.BUFF then
    end

    if dataTable and dataTable.DEBUFF then
        for buffName, buffData in pairs(dataTable.DEBUFF) do

            Modifier.Debuff[buffName] = {
                buff = true,
                name = buffData.name,
                type = tonumber(buffData.type),
                isDebuff = true,
                defaultDuration = tonumber(buffData.defaultDuration),
                modifierName = buffData.modifierName,
            };

            if buffData.property and #buffData.property then
                Modifier.Debuff[buffName].property = buffData.property;
            end

            LinkLuaModifier(buffData.modifierName, buffData.modifierPath, LUA_MODIFIER_MOTION_NONE);
        end
    end

    -- Utility:printObj(Modifier.Debuff);
end

function Modifier:_isValidBuff(buff)
    return buff and buff.buff == true and buff.name and true or false;
end

function Modifier:addBuffToUnit(buff, unit, duration)
    if Modifier:_isValidBuff(buff) ~= true then
        return;
    end

    duration = duration or buff.defaultDuration;

    unit:AddNewModifier(unit, nil, buff.modifierName, { duration = duration });
end

function Modifier:addBuffStackToUnit(buff, unit, stack, duration)
    if Modifier:_isValidBuff(buff) ~= true then
        return;
    end
end

function Modifier:clearBuff(buff, unit)
    if Modifier:_isValidBuff(buff) ~= true then
        return;
    end

    if unit:HasModifier(buff.modifierName) then
        unit:RemoveModifierByName(buff.modifierName);
    end
end
