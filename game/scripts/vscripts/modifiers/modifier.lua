local BUFF = 'BUFF';

local logEvents = {
    ADD = 'ADD', DESTROY = 'DESTROY',
    ERROR = 'ERROR', LOAD_DATA = 'LOAD_DATA',
};

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

    if isDebugEnabled(BUFF, logEvents.LOAD_DATA) then
        debugLog(BUFF, logEvents.LOAD_DATA, 'Loading Debuff data set: ');
        Utility:printObj(Modifier.Debuff, 'Debuff');
    end
end

function Modifier:_isValidBuff(buff)
    return buff and buff.buff == true and buff.name and true or false;
end

function Modifier:addBuffToUnit(buff, unit, duration)
    if Modifier:_isValidBuff(buff) ~= true then
        if isDebugEnabled(BUFF, logEvents.ERROR) then
            debugLog(BUFF, logEvents.ERROR, 'Error: Invalid buff object: ' .. tostring(buff) .. ' , try to add to unit: ' .. Utility:formatUnitLog(unit));
        end

        return;
    end

    duration = duration or buff.defaultDuration;

    if isDebugEnabled(BUFF, logEvents.ADD) then
        debugLog(BUFF, logEvents.ADD, 'Adding Buff: ' .. tostring(buff.name) .. ' , Unit: ' .. Utility:formatUnitLog(unit));
    end

    unit:AddNewModifier(unit, nil, buff.modifierName, { duration = duration });
end

function Modifier:addBuffStackToUnit(buff, unit, stack, duration)
    if Modifier:_isValidBuff(buff) ~= true then
        return;
    end
end

function Modifier:clearBuff(buff, unit)
    if Modifier:_isValidBuff(buff) ~= true then
        if isDebugEnabled(BUFF, logEvents.ERROR) then
            debugLog(BUFF, logEvents.ERROR, 'Error: Invalid buff object: ' .. tostring(buff) .. ' , try to clear from unit: ' .. Utility:formatUnitLog(unit));
        end
        
        return;
    end

    if isDebugEnabled(BUFF, logEvents.DESTROY) then
        debugLog(BUFF, logEvents.DESTROY, 'Clearing Buff: ' .. tostring(buff.name) .. ' , Unit: ' .. Utility:formatUnitLog(unit));
    end

    if unit:HasModifier(buff.modifierName) then
        unit:RemoveModifierByName(buff.modifierName);
    end
end
