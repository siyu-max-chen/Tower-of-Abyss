local UI = 'UI';
local SERVER = 'SERVER';
local CLIENT = 'CLIENT';

ability_test = class({});

function ability_test:OnSpellStart()
    print('!!!!!!!!!');
    CustomGameEventManager:Send_ServerToAllClients('event_call_panel_test_ability', {});

    if isDebugEnabled(UI, SERVER) then
        debugLog(UI, SERVER, 'Server: Request open Test Ability Panel');
    end
end
