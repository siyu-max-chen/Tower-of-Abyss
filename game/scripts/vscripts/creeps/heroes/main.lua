local HERO = 'HERO';
local LOAD_DATA = 'LOAD_DATA';
local CHANGE = 'CHANGE';

Hero = class({});

require('creeps/heroes/titan_guardian');
require('creeps/heroes/ice_sorceress');

Hero['TitanGuardian'] = TitanGuardian;
Hero['IceSorceress'] = IceSorceress;

local _ToAHeroDataMap = {};

function Hero:findHeroByName(name)
    if not name or not _ToAHeroDataMap[name] or not _ToAHeroDataMap[name].class then
        return nil;
    end

    return _ToAHeroDataMap[name].class;
end

function Hero:_initialize()
    local dataTable = Data:getDataTable('HERO_DATA');

    for heroName, table in pairs(dataTable) do
        _ToAHeroDataMap[heroName] = {
            class = Hero[table.class];
        };
    end

    if isDebugEnabled(HERO, LOAD_DATA) then
        debugLog(HERO, LOAD_DATA, 'Hero Data Map is loaded: ');
        Utility:printObjKeys(_ToAHeroDataMap, '_ToAHeroDataMap');
    end
end
