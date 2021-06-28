local _isValidEvent = function (event)
    if not event or not event.name then
        return false;
    end

    local data = Data:getData('EVENTDATA');
    return data and data[event.name] and data[event.name] == event;
end

local _isValidEffect = function (effect)
    if not effect or not effect.name then
        return false;
    end

    local data = Data:getData('EFFECTDATA');
    return data and data[effect.name] and data[effect.name] == effect;
end

local _getEntityEventEffectsTable = function (entity, event)
    if not entity or not _isValidEvent(event) then
        return nil;
    end

    if not entity._events then
        entity._events = {};
    end

    if not entity._events[event.name] then
        entity._events[event.name] = {};
    end

    return entity._events[event.name];
end

function ToAGame:subscribeToEvent(event, effect, entity)
    if not entity or not _isValidEvent(event) or not _isValidEffect(effect) then
        return;
    end

    local effectsOnEvent = _getEntityEventEffectsTable(entity, event);         -- this entity's event table which record in each event's subscribers
    local effectData = Data:getData('EFFECTDATA')[effect.name];     -- preloaded effect data

    if not effectsOnEvent[effect.name] then
        effectsOnEvent[effect.name] = {
            stack = 0,
            CDRT = -1,
        };
    end

    effectsOnEvent[effect.name].stack = effectsOnEvent[effect.name].stack + 1;
end

function ToAGame:unsubscribeToEvent(event, effect, entity)
    if not entity or not _isValidEvent(event) or not _isValidEffect(effect) then
        return;
    end

    local effectsOnEvent = _getEntityEventEffectsTable(entity, event);         -- this entity's event table which record in each event's subscribers

    -- invalid situation
    if not effectsOnEvent[effect.name] then
        return;
    end

    effectsOnEvent[effect.name].stack = effectsOnEvent[effect.name].stack - 1;
end

-- data object is only used for some of the information
function ToAGame:onEvent(event, effect, entity, dataObj)
    if not entity or not _isValidEvent(event) or not _isValidEffect(effect) then
        return;
    end

    local effectsOnEvent = _getEntityEventEffectsTable(entity, event);         -- this entity's event table which record in each event's subscribers
    local effectData = Data:getData('EFFECTDATA')[effect.name];     -- preloaded effect data

    -- iterate event table to trigger each possible events
    for effectName, table in pairs(effectsOnEvent) do
        if table.stack and table.stack >= 1 then
            -- trigger call back with some data
            -- if trigger, add cooldown to the event!
        end
    end
end
