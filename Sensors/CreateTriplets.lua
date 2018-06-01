local sensorInfo = {
	name = "CreatesTriplets",
	desc = "Add to given array with already stored keys a new key with begin positions",
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

-- global variable


function isUnitReady(unitID)
  if not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead(unitID)then
      return false
    else
      return true
  end  
end

-- @description 
return function(sortedUnitsWithLoc, beginPositions)
  local trios = {}
  if #sortedUnitsWithLoc ~= #beginPositions then
    return trios
  end
  for i = 1, #sortedUnitsWithLoc do
    trios[i] = sortedUnitsWithLoc[i]
    trios[i]["begin"] = beginPositions[i]
  end
  return trios
end