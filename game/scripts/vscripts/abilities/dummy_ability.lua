TIMER_TEAM_NUMBER = 0;
DEFAULT_LOC = Vector(0, 0, 0);

LinkLuaModifier('modifier_timer_event', 'abilities/dummy_ability.lua',
    LUA_MODIFIER_MOTION_NONE);

dummy_ability = class({});

function dummy_ability:OnSpellStart()
end

function timerEvent(duration, dataObj, callback)
    local timer = CreateModifierThinker(DUMMY_UNIT, nil, 'modifier_timer_event', { duration = duration }, DEFAULT_LOC,
        TIMER_TEAM_NUMBER, false);

    timer._data = {
        dataObj = dataObj, callback = callback,
    };
end

modifier_timer_event = class({});

function modifier_timer_event:OnCreated(data)
end

function modifier_timer_event:OnDestroy()
    local timer = self:GetParent();
    local dataObj = timer._data.dataObj;
    local callback = timer._data.callback;

    if (callback ~= nil) then
        callback(dataObj);
    end

    timer._data = nil;
    self:Destroy();
end

if _G.timerEvent == nil then
    _G.timerEvent = timerEvent;
end
