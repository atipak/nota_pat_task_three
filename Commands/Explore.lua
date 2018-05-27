function getInfo()
	return {
		onNoUnits = SUCCESS,
		parameterDefs = {
      
		}
	}
end

targetPlaces = {}
threshold = 700

function Run(self, unitIds, parameter) 
  -- creating keyset from parameter.transUnitsPairs
    -- help variables
  local mapHeight = Game.mapSizeZ
  local mapWidth = Game.mapSizeX
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
    transportersStates[unitID] = endedState
    return false
  else
    return true
  end
end


function isOnPosition(transporterID, targetPosition) 
  local tranPosX, tranPosY, tranPosZ = Spring.GetUnitPosition(transporterID)
  if math.abs(tranPosX - targetPosition.x) > threshold or math.abs(tranPosZ - targetPosition.z) > threshold then 
      return false  
  end 
  return true
end


 
  