local _generateIndentation = function(depth)
    local result = '';

    if depth <= 0 then
        return result;
    end

    for i = 1, depth do
        result = result .. '\t';
    end

    return result;
end

--- stringfy object into string format
---@param object table required
---@param objectName string optional
---@param depth integer optional
---@return string
function Utility:stringfy(object, objectName, depth)
    if not object and type(object) ~= 'boolean' then
        return '';
    end

    objectName = objectName or 'No Object Name Provided';
    depth = depth or 0;

    local indentation = _generateIndentation(depth);
    local result = '';

    if type(object) ~= 'table' then
        return indentation .. ' [ ' .. tostring(objectName) .. ' (' .. type(object) .. ')\t' .. tostring(object) ..
                   ' ],';
    end

    result = indentation .. ' [ \n';
    result = result .. indentation .. '\t ' .. tostring(objectName) .. ' (' .. type(object) .. ')';

    for objName, obj in pairs(object) do
        result = result .. '\n' .. Utility:stringfy(obj, objName, depth + 1);
    end
    result = result .. '\n' .. indentation .. ' ], ';

    if type(object) == 'table' and depth == 0 then
        result = '\n-----------------------------------------------------------------------------------\n' .. result ..
                     '\n-----------------------------------------------------------------------------------\n\n\n';
    end

    return result;
end

--- print out stringfied object
---@param object table required
---@param objectName string optional
---@param depth integer optional
function Utility:printObj(object, objectName, depth)
    if not object and type(object) ~= 'boolean' then
        return '';
    end

    objectName = objectName or 'No Object Name Provided';
    depth = depth or 0;

    local indentation = _generateIndentation(depth);

    if type(object) ~= 'table' then
        return print(indentation .. ' [ ' .. tostring(objectName) .. ' (' .. type(object) .. ')\t' .. tostring(object) ..
        ' ],');
    end

    local isParentObj = type(object) == 'table' and depth == 0;

    if isParentObj then
        print('\n-----------------------------------------------------------------------------------\n');
    end

    -- object info
    print( indentation .. ' [' );
    print( indentation .. '\t ' .. tostring(objectName) .. ' (' .. type(object) .. ')' );

    for objName, obj in pairs(object) do
        Utility:printObj(obj, objName, depth + 1);
    end

    print(indentation .. ' ], ');

    if isParentObj then
        print('\n-----------------------------------------------------------------------------------\n\n\n');
    end
end

function Utility:printObjKeys(object, objectName)
    if not object and type(object) ~= 'boolean' then
        return '';
    end

    objectName = objectName or 'No Object Name Provided';

    local indentation = _generateIndentation(0);

    if type(object) ~= 'table' then
        return print(' [ ' .. tostring(objectName) .. ' (' .. type(object) .. ')\t' .. tostring(object) ..
        ' ],');
    end

    print('\n-----------------------------------------------------------------------------------\n');
    print( indentation .. ' [' );
    print( indentation .. '\t ' .. tostring(objectName) .. ' (' .. type(object) .. ')' );

    for key, val in pairs(object) do
        print( indentation .. '\t ' .. key );
    end

    print(indentation .. ' ], ');
    print('\n-----------------------------------------------------------------------------------\n\n\n');
end

--- Generate unified unit log with its id and name
---@param unit table
---@return string
function Utility:formatUnitLog(unit)
    if not unit then
        return 'nil unit (nil)';
    end

    return unit:GetUnitName() .. '(' .. tostring(unit) .. ')';
end

--- Generate obj log with format: object_addr (object type)
---@param obj any
function Utility:formatObjLog(obj)
    if not obj then
        return 'nil object (nil)';
    end

    return tostring(obj) .. '(' .. type(obj) .. ')';
end

function Utility:formatAbilityHitLog(ability, units)
    if not ability or not ability:GetAbilityName() or not units or not #units then
        return 'Invalid ability hit unit event!!!';
    end

    local unitArrayStr = '[ ';
    for _, val in pairs(units) do
        unitArrayStr = unitArrayStr .. Utility:formatUnitLog(val) .. ' , ';
    end
    unitArrayStr = unitArrayStr .. ' ]';

    return ability:GetAbilityName() .. ' Hit: ' .. unitArrayStr;
end
