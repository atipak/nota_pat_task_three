local sensorInfo = {
	name = "CreatesPairs",
	desc = "Returns {[transporterID] = transporteeID, ...}. It can return {}",
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
pairing = {}
local startIndex = 1


-- @description return current wind statistics
return function(sortedUnits, safeRadius, safeBase)
  startIndex = 1
  safeBase = Vec3(safeBase[1], safeBase[2], safeBase[3])  
  local values = checkPairing()
  for i = 1, #units do
    if isUnitReady(units[i]) and pairing[units[i]] == nil then
      pairing[units[i]] = findFreeUnit(sortedUnits, safeBase, safeRadius, values)
    end   
  end
  return pairing
end

function isInArea(basePosition, radius, position)
  return (position.x - basePosition.x)^2 + (position.z - basePosition.z)^2 <= radius^2
end

function findFreeUnit(sortedUnits, safeBase, safeRadius, values)
  while startIndex < #sortedUnits do 
    unitID = sortedUnits[startIndex]
    local lx, ly, lz = Spring.GetUnitPosition(unitID)
    local position = Vec3(lx, ly, lz)   
    startIndex = startIndex + 1     
    if isUnitReady(unitID) and not values[unitID] and not isInArea(safeBase, safeRadius, position) then
      return unitID
    end
  end
  return nil
end

function checkPairing() 
  values = {}
  for k,v in pairs(pairing) do
    if isUnitReady(k) and isUnitReady(v) then
      values[v] = true
    else
      pairing[k] = nil
    end    
  end
  return values 
end

function isUnitReady(unitID)
  if not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead(unitID)then
      return false
    else
      return true
  end  
end


