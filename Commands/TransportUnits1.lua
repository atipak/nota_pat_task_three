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

-- current states of units
local states = {}
-- target location, where the unit should put down transportee
local safeZoneVectors = {}
-- already rescued or being rescued units
local assignedUnits = {} 
-- which unit has to rescue which unit
local unitToRescue = {}
-- current index of path, where the units is located
local pathIndex = {}
local threshold = 50
-- enumeration of states for units
local thereState, backState, loadState, unloadState, toSafeZoneState = "moveThere", "moveBack", "loadUnit", "unloadUnit", "transportToSafeZone"



-- if there are units to rescue and there are transports as well, the node returns running
function Run(self, unitIds, parameter) 
  -- gies through units array and check if the unit has a task or assigns a new task to it if there is a unit to rescue 
  for i = 1, #unitIds do 
    local unitId = unitIds[i]
    local unitState = states[unitId]
    if isUnitOK(unitId) then
      -- no task
      if unitState == nil then
        -- get free unit to rescue
        local index = getFreeUnit(parameter.unitsToRescue, parameter.safePos, parameter.safeRadius)
        -- there is free unit
        if index ~= -1 then
          -- reserve unit
          assignUnit(index)
          -- set a new state 
          states[unitId] = thereState
          -- remember the unit
          unitToRescue[unitId] = index
          -- move transporter to first path point, there should be every time a one point in path
          pathIndex[unitId] = 1
          Spring.GiveOrderToUnit(unitId, CMD.MOVE, parameter.unitsToRescue[index].path[1]:AsSpringVector(), {})
        end           
      end
      -- moving there
      if unitState == thereState then
        local index = unitToRescue[unitId]
        local targetPos = parameter.unitsToRescue[index].path[pathIndex[unitId]]
        -- if the unit is on position, change its state to "load" and execute action
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
        -- if the unit loaded a unit in danger, change its state to "move" and transport unit to first point of backpath 
        if isLoaded(unitId, unitInDanger) then
          Spring.GiveOrderToUnit(unitId, CMD.MOVE, parameter.unitsToRescue[index].path[pathIndex[unitId]]:AsSpringVector(), {})
          states[unitId] = backState  
        end
      end
      -- moving back
      if unitState == backState then
        local index = unitToRescue[unitId]
        local targetPos = parameter.unitsToRescue[index].path[pathIndex[unitId]]
        -- if the unit is on position (last point of path), choose random point in safe area and transport the unit there
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
        -- if the unit is on position, change its state to "unload" and execute action
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
        -- if the unit is unloaded, set the unit state to nil, so the unit can obtain new task
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
      -- something bad happend to transportee
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

-- implementation of ternary operator
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

  