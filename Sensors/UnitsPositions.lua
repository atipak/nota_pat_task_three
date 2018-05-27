local sensorInfo = {
	name = "UnitsToRescue",
	desc = "Returns ids of units to rescue. It can return {}",
	author = "Patik",
	date = "2018-05-11",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = 0 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- check function
function isUnitOK(unitID)
  if not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead(unitID) then
    transportersStates[unitID] = endedState
    return false
  else
    return true
  end
end


-- @description 
return function(unitsIds)
  local positions = {}
  for i = 1, #unitsIds do
    local unitId = unitsIds[i]
    if isUnitOK(unitId) then
      local lx, ly, lz = Spring.GetUnitPosition(unitId)
      positions[i] = {unitId = unitId, position = Vec3(lx, ly, lz)}
    end     
  end 
  return positions
end