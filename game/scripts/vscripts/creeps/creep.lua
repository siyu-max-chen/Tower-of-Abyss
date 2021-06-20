local CREEP = 'CREEP';
local LOAD_DATA = 'LOAD_DATA';
local CHANGE = 'CHANGE';
local INIT = 'INIT';

Creep = class({});

function Creep:new(type, playerId, originVec, initializer, skipCreateEntity)
    local obj = {};
    setmetatable(obj, self);
    self.__index = self;

    if not originVec then
        originVec = Vector(0, 0, 0);
    end

    obj._entity = skipCreateEntity or CreateUnitByName(type, originVec, true, nil, nil, playerId);
    obj._entity._instance = obj;

    self:init(initializer);

    return obj;
end

function Creep:init()
    print('Into the Init Function!!!!');

end
