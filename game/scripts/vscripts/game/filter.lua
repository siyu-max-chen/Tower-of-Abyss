local FILTER = 'FILTER';
local ORDER = 'ORDER';
local orderMap = nil;

function ToAGame:_transIntToOrder(orderId)
    if orderMap == nil then
        orderMap = {'DOTA_UNIT_ORDER_MOVE_TO_POSITION', 'DOTA_UNIT_ORDER_MOVE_TO_TARGET', 'DOTA_UNIT_ORDER_ATTACK_MOVE',
                    'DOTA_UNIT_ORDER_ATTACK_TARGET', 'DOTA_UNIT_ORDER_CAST_POSITION', 'DOTA_UNIT_ORDER_CAST_TARGET',
                    'DOTA_UNIT_ORDER_CAST_TARGET_TREE', 'DOTA_UNIT_ORDER_CAST_NO_TARGET', 'DOTA_UNIT_ORDER_CAST_TOGGLE',
                    'DOTA_UNIT_ORDER_HOLD_POSITION', 'DOTA_UNIT_ORDER_TRAIN_ABILITY', 'DOTA_UNIT_ORDER_DROP_ITEM',
                    'DOTA_UNIT_ORDER_GIVE_ITEM', 'DOTA_UNIT_ORDER_PICKUP_ITEM', 'DOTA_UNIT_ORDER_PICKUP_RUNE',
                    'DOTA_UNIT_ORDER_PURCHASE_ITEM', 'DOTA_UNIT_ORDER_SELL_ITEM', 'DOTA_UNIT_ORDER_DISASSEMBLE_ITEM',
                    'DOTA_UNIT_ORDER_MOVE_ITEM', 'DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO', 'DOTA_UNIT_ORDER_STOP',
                    'DOTA_UNIT_ORDER_TAUNT', 'DOTA_UNIT_ORDER_BUYBACK', 'DOTA_UNIT_ORDER_GLYPH',
                    'DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH', 'DOTA_UNIT_ORDER_CAST_RUNE'};
    end

    return orderMap[orderId] or 'DOTA_UNIT_ORDER_NONE';
end

function ToAGame:getOrderUnit(event)
    local unitIds = event.units;

    if unitIds['0'] ~= nil then
        return EntIndexToHScript(unitIds['0']);
    end

    local eventType = event.order_type;

    if (eventType == DOTA_UNIT_ORDER_CAST_POSITION or eventType == DOTA_UNIT_ORDER_CAST_TARGET or eventType ==
        DOTA_UNIT_ORDER_CAST_TARGET_TREE or eventType == DOTA_UNIT_ORDER_CAST_NO_TARGET) then
        local ability = EntIndexToHScript(event.entindex_ability);
        return ability:GetCaster();
    end

    return nil;
end

function ToAGame:OrderFilter(event)
    local unit = ToAGame:getOrderUnit(event);

    if not unit then
        return true;
    end

    local unitState = Battle.State:getUnitState(unit);
    if unitState == Battle.State.STATE_TYPES.PAUSED then
        return false;
    end

    if isDebugEnabled(FILTER, ORDER) then
        debugLog(FILTER, ORDER, 'Executed order: ' .. ToAGame:_transIntToOrder(event.order_type) ..
            ' , trigger unit: ' .. Utility:formatUnitLog(unit));
    end

    return true;
end

function ToAGame:AbilityFilter(event)
    for _, value in pairs(event) do
        print(tostring(_) .. ' ' .. tostring(value));
    end

    return true;
end

function ToAGame:DamageFilter(event)
    return false;
end
