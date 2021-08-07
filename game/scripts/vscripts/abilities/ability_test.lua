local UI = 'UI';
local SERVER = 'SERVER';
local CLIENT = 'CLIENT';

ability_test = class({});

LinkLuaModifier('modifier_timer_event', 'abilities/ability_test.lua',
    LUA_MODIFIER_MOTION_NONE);

function ability_test:OnSpellStart()
    print('!!!!!!!!!');
    CustomGameEventManager:Send_ServerToAllClients('event_call_panel_test_ability', {});

    if isDebugEnabled(UI, SERVER) then
        debugLog(UI, SERVER, 'Server: Request open Test Ability Panel');
    end
end

function timerEvent(duration, dataObj, callback)
    local timerTeamNumber = 0;
    local timer = CreateModifierThinker(nil, nil, 'modifier_timer_event', { duration = duration }, Vector(0, 0, 0),
        timerTeamNumber, false);

    print('Timer Event!!!!!');

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

    callback(dataObj);

    self:Destroy();
end

if _G.timerEvent == nil then
    _G.timerEvent = timerEvent;
end
