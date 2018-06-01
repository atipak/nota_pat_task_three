function getInfo()
	return {
		onNoUnits = SUCCESS,
		parameterDefs = {
      
		}
	}
end

targetPlaces = {}
threshold = 700

-- the function always returns RUNNING except there are no units 
function Run(self, unitIds, parameter) 
  --math.randomseed(42)
  -- help variables
  local mapHeight = Game.mapSizeZ
  local mapWidth = Game.mapSizeX
  -- for each unit check if it is on the target position
  -- if no target position is given, choose a random point on map
  for i = 1, #unitIds do
    local unitId = unitIds[i]
    if isUnitOK(unitId) then
      if targetPlaces[unitId] ~= nil then
        if isOnPosition(unitId, targetPlaces[unitId]) then
          targetPlaces[unitId] = nil 
        end
      else
        local x = math.random(mapWidth)
        local z = math.random(mapHeight) 
        local targetVector = Vec3(x, Spring.GetGroundHeight(x, z), z)
        targetPlaces[unitId] = targetVector
        Spring.GiveOrderToUnit(unitId, CMD.MOVE, targetVector:AsSpringVector(), {})
      end
    end
  end
  return RUNNING
end

-- check function
function isUnitOK(unitID)
  if not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead(unitID) then
    return false
  else
    return true
  end
end

-- check if given unit is on target position 
-- threshold is global variable
function isOnPosition(transporterID, targetPosition) 
  local tranPosX, tranPosY, tranPosZ = Spring.GetUnitPosition(transporterID)
  if math.abs(tranPosX - targetPosition.x) > threshold or math.abs(tranPosZ - targetPosition.z) > threshold then 
      return false  
  end 
  return true
end


 
  