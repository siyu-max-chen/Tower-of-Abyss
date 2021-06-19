State = class({});

State.STATE_TYPES = {
    NONE =  'NONE',
    IDLE = 'IDLE',
    CASTING = 'CASTING',
    PAUSED = 'PAUSED',       -- 单位无法被玩家操作, 用于释放特殊技能后的表演状态
    INVALID = 'INVALID'      -- 无效的错误输入
};

function State:_initialize()
    State.ENUM = {};
    local stateTable = Data:getDataTable('GAME', 'STATE', 'ENUM');

    if not stateTable then
        return;
    end

    for key, val in pairs(stateTable) do
        State.ENUM[key] = key;
    end
end

function State:_setUnitState(unit, state)
    state = State.ENUM[state] or State.ENUM.NONE;
    unit._ToAUnitState = state;
end

function State:getUnitState(unit)
    if not unit then
        return State.ENUM.INVALID;
    end

    if unit and unit._ToAUnitState and State.ENUM[unit._ToAUnitState] then
        return unit._ToAUnitState;
    end

    State:_setUnitState(unit, State.ENUM.NONE);
    return unit._ToAUnitState;
end

function State:turnToPaused(unit)
    State:_setUnitState(unit, State.ENUM.PAUSED);
end

function State:turnToIdle(unit)
    State:_setUnitState(unit, State.ENUM.IDLE);
end

Battle.State = State;
