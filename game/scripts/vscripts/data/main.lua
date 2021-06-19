Data = class({});

Data.SOUND_TYPES = {'SOUND.CAST', 'SOUND.HIT'};

function Data:_initialize()
    Data._ToADataMap = {
        CONFIG = LoadKeyValues('scripts/kv/config.txt'),
        PARTICLE = LoadKeyValues('scripts/kv/particles.txt'),
        SOUND = LoadKeyValues('scripts/kv/sounds.txt'),
        GAME = LoadKeyValues('scripts/kv/game.txt'),
        BOOSTER = LoadKeyValues('scripts/kv/boosters.txt'),
        ATTRIBUTE = LoadKeyValues('scripts/kv/attributes.txt'),
        ABILITY_DATA = LoadKeyValues('scripts/kv/abilities.txt'),
        CREEP_DATA = LoadKeyValues('scripts/kv/creep_data.txt'),
        HERO_DATA = LoadKeyValues('scripts/kv/hero_data.txt'),

        MODIFIER_DATA = LoadKeyValues('scripts/kv/modifiers.txt'),
        DEBUG_DATA = LoadKeyValues('scripts/kv/debug.txt'),
    };
end

--- Get key-values table based on the tableName and node PATHs.
---@param tableName string
function Data:getDataTable(tableName, ...)
    if tableName == nil or not tableName or not Data._ToADataMap[tableName] then
        return nil;
    end

    local table, args = Data._ToADataMap[tableName], {...};

    if not args or #args == 0 then
        return table;
    end

    for i = 1, #args do
        if not table[args[i]] then
            return nil;
        end

        table = table[args[i]];
    end

    return table;
end
