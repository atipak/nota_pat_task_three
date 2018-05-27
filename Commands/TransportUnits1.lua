function getInfo()
	return {
		onNoUnits = SUCCESS,
		parameterDefs = {
      { 
				name = "unitsToRescue",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "{}"
			}, 
      { 
				name = "safePos",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "{}"
			},
      { 
				name = "safeRadius",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "{}"
			}
		}
	}
end

local states = {}
local safeZoneVectors = {}
local assignedUnits = {} 
local unitToRescue = {}
local pathIndex = {}
local threshold = 50
local thereState, backState, loadState, unloadState, toSafeZoneState = "moveThere", "moveBack", "loadUnit", "unloadUnit", "transportToSafeZone"



function Run(self, unitIds, parameter) 
  -- creating keyset from parameter.transUnitsPairs
  for i = 1, #unitIds do 
    local unitId = unitIds[i]
    local unitState = states[unitId]
    if isUnitOK(unitId) then
      -- no task
      if unitState == nil then
        -- get free unit to rescue
        local index = getFreeUnit(parameter.unitsToRescue, parameter.safePos, parameter.safeRadius)
        if index ~= -1 then
          assignUnit(index) 
          states[unitId] = thereState
          unitToRescue[unitId] = index
          pathIndex[unitId] = 1
          Spring.GiveOrderToUnit(unitId, CMD.MOVE, parameter.unitsToRescue[index].path[1]:AsSpringVector(), {})
        end           
      end
      -- moving there
      if unitState == thereState then
        local index = unitToRescue[unitId]
        local targetPos = parameter.unitsToRescue[index].path[pathIndex[unitId]]
        if isOnPosition(unitId, targetPos) then
          if pathIndex[unitId] < #parameter.unitsToRescue[index].path then
            pathIndex[unitId] = pathIndex[unitId] + 1
            Spring.GiveOrderToUnit(unitId, CMD.MOVE, parameter.unitsToRescue[index].path[pathIndex[unitId]]:AsSpringVector(), {})
          else
            Spring.GiveOrderToUnit(unitId, CMD.LOAD_UNITS, {parameter.unitsToRescue[index].unitId}, {})
            states[unitId] = loadState
          end
        end
      end
      -- loading
      if unitState == loadState then
        local index = unitToRescue[unitId]
        local unitInDanger = parameter.unitsToRescue[index].unitId
        if isLoaded(unitId, unitInDanger) then
          Spring.GiveOrderToUnit(unitId, CMD.MOVE, parameter.unitsToRescue[index].path[pathIndex[unitId]]:AsSpringVector(), {})
          states[unitId] = backState  
        end
      end
      -- moving back
      if unitState == backState then
        local index = unitToRescue[unitId]
        local targetPos = parameter.unitsToRescue[index].path[pathIndex[unitId]]
        if isOnPosition(unitId, targetPos) then
          if pathIndex[unitId] > 1 then
            pathIndex[unitId] = pathIndex[unitId] - 1
            Spring.GiveOrderToUnit(unitId, CMD.MOVE, parameter.unitsToRescue[index].path[pathIndex[unitId]]:AsSpringVector(), {})
          else
            local diff = 50
            local x = math.random(parameter.safeRadius - diff)
            local z = math.random(parameter.safeRadius - diff) 
            x = ternary(math.random() > 0.5, -1 * x, x) 
            z = ternary(math.random() > 0.5,  -1 * z, z) 
            local targetVector = Vec3(parameter.safePos.x + x, Spring.GetGroundHeight(parameter.safePos.x + x, parameter.safePos.z + z), parameter.safePos.z + z)
            safeZoneVectors[unitId] = targetVector
            Spring.GiveOrderToUnit(unitId, CMD.MOVE, safeZoneVectors[unitId]:AsSpringVector(), {})
            states[unitId] = toSafeZoneState
          end
        end
      end
      -- transporting to safe zone
      if unitState == toSafeZoneState then
        local index = unitToRescue[unitId]
        local targetVector = safeZoneVectors[unitId]
        if isOnPosition(unitId, targetVector) then  
          local lx, ly, lz = Spring.GetUnitPosition(unitId)        
          Spring.GiveOrderToUnit(unitId, CMD.UNLOAD_UNITS, {lx, ly, lz, 15} , {})
          safeZoneVectors[unitId] = nil
          states[unitId] = unloadState                              
        end
      end
      -- unload
      if unitState == unloadState then
        local index = unitToRescue[unitId]
        local unitInDanger = parameter.unitsToRescue[index].unitId
        if isUnloaded(unitId, unitInDanger) then
          -- clean up 
          unitToRescue[unitId] = nil
          states[unitId] = nil
          safeZoneVectors[unitId] = nil
          unassignUnit(index)
        else 
          local lx, ly, lz = Spring.GetUnitPosition(unitId)  
          Spring.GiveOrderToUnit(unitId, CMD.UNLOAD_UNITS, {lx, ly, lz, 15} , {})
        end
      end
    else 
      -- remove all saved values
      unitToRescue[unitId] = nil
      states[unitId] = nil
      safeZoneVectors[unitId] = nil
      unassignUnit(index) 
    end
  end 
  return RUNNING
end

-- removing after dead units   TODO
function cleaning() 

end

function ternary (cond , T , F)
    if cond then return T else return F end
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

function isInArea(basePosition, radius, position)
  return (position.x - basePosition.x)^2 + (position.z - basePosition.z)^2 <= radius^2
end

-- returns units to rescue
function getFreeUnit(unitsToRescue, safePos, safeRadius) 
  for i = 1, #unitsToRescue do
    if assignedUnits[i] == nil then
      local unitId = unitsToRescue[i].unitId 
      local lx, ly, lz = Spring.GetUnitPosition(unitId)
      if not isInArea(safePos, safeRadius, Vec3(lx, ly, lz)) then
        return i
      end
    end
  end  
  return -1  
end

function assignUnit(index)
  assignedUnits[index] = true 
end

function unassignUnit(index)
  assignedUnits[index] = nil 
end
     

function isOnPosition(unitId, target) 
  local x, y, z = Spring.GetUnitPosition(unitId)
  if math.abs(x - target.x) > threshold or math.abs(z - target.z) > threshold then
      return false  
  end 
  return true
end


function isLoaded(transporterID, transporteeID)
  -- transporterId 
  local tranID = Spring.GetUnitTransporter(transporteeID)
  return nil ~= tranID and tranID == transporterID
end


function isUnloaded(transporterID, transporteeID)
  return nil == Spring.GetUnitTransporter(transporteeID)
end

  