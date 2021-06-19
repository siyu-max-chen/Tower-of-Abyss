function Booster:_updateScout(unit, prevLev, nextLev)
    local updateInfo = Booster:_getBoosterUpdateInfo(Booster.ENUM.SCOUT, prevLev, nextLev);

    if updateInfo.isNoUpdate then
        return;
    end

    -- add/remove max level bonus
    if updateInfo.isMax then
        Battle.Attribute:incrementUnitAttribute(Battle.Attribute.ENUM.MOVE_SPEED.ENHANCE, unit, Booster.ENUM.SCOUT.values[3], updateInfo.isIncrement);
    end

    local value = 0;

    if updateInfo.min == 0 then
        value = Booster.ENUM.SCOUT.values[1] - Booster.ENUM.SCOUT.values[2];
    end

    value = value + (updateInfo.max - updateInfo.min) * Booster.ENUM.SCOUT.values[2];
    Battle.Attribute:incrementUnitAttribute(Battle.Attribute.ENUM.MOVE_SPEED.BONUS, unit, value, updateInfo.isIncrement);
end
