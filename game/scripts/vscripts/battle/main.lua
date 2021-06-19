Battle = class({});

require('battle/state');
require('battle/attribute');
require('battle/damage');

function Battle:_initialize()
    -- initilize recursion
    for _, child in pairs(self) do
        if child and child ~= self and type(child) == 'table' and child._initialize and type(child._initialize) == 'function' then
            child:_initialize();
        end
    end
end
