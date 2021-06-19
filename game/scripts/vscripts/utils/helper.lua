function Utility:getRangedVector(origin, distance, degree)
    local angle = math.rad(degree);
    local originX = origin.x;
    local originY = origin.y;

    return Vector(originX + distance * math.cos(angle), originY + distance * math.sin(angle), origin.z);
end

function Utility:generateRandomVectors(origin, count, range, minLimit)
    if not origin or count < 1 or not range then
        return nil;
    end

    minLimit = minLimit or 0;

    local vectors = {};
    local deltaDegree = 360 / count;
    local degreeOffset = math.max(12, deltaDegree * 0.25);
    local degreeInit = RandomFloat(0, 360);

    for i = 1, count do
        local distance = RandomFloat(minLimit, range);
        local degree = degreeInit + deltaDegree * i + RandomFloat(-degreeOffset, degreeOffset);
        vectors[i] = Utility:getRangedVector(origin, distance, degree);
    end

    return vectors;
end
