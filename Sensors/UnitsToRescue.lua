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


-- @description 
return function(unitsNames)
  local allMyUnits = Spring.GetTeamUnits(Spring.GetLocalTeamID())
  -- there are no units
  if #units == 0 then 
    return {}
  end
  local unitsToRescue = {}
  -- if unit name is in array with correct names is this unit added
  -- unitsNames from sensor UnitNames
  local index = 1
  for i = 1, #allMyUnits do
    local unitId = allMyUnits[i]
    local unitDefID = Spring.GetUnitDefID(unitId)
    if unitsNames[UnitDefs[unitDefID].name] then
       unitsToRescue[index] = unitId
       index = index + 1  
    end          
  end 
  return unitsToRescue
end