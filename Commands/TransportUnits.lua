function getInfo()
	return {
		onNoUnits = SUCCESS,
		parameterDefs = {
      { 
				name = "transUnitsPairs",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "{}"
			}, 
      { 
				name = "safePosition",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "{}"
			}
		}
	}
end

local alreadyLaunch = false
local transportersStates = {}
local threshold = 5
local moveThere, moveBack, loadUnit, unloadUnit = "moveThere", "moveBack", "loadUnit", "unloadUnit"



function Run(self, unitIds, parameter) 
  -- creating keyset from parameter.transUnitsPairs
  local units ={}
  local n=0
  
  for k,v in pairs(parameter.transUnitsPairs) do
    n=n+1
    units[n]=k
  end
  
  if #units == 0 then
    return SUCCESS
  end
  

  
  -- iterating over units a finding their states 
  for index = 1, #units do 
    local unitID = units[index]
    local transporteeID = transUnitsPairs[unitID] 
    if isUnitOK(unitID) and isUnitOK(transporteeID) then 
      if transportersStates[unitID] == nil then
        -- no record in table -> the task wasn't started
        local lx, ly, lz = Spring.GetUnitPosition(transporteeID) 
        moveOnPosition(unitID, Vec3(lx, ly, lz))
        transportersStates[unitID] = moveThere
      end
      -- moveThere
      if transportersStates[unitID] == moveThere then
        -- no record in table -> the task wasn't started
        local lx, ly, lz = Spring.GetUnitPosition(transporteeID) 
        if moveOnPosition(unitID, Vec3(lx, ly, lz)) then
          transportersStates[unitID] = loadUnit
        end
      end
      -- load
      if transportersStates[unitID] == loadUnit then
        -- no record in table -> the task wasn't started
        local lx, ly, lz = Spring.GetUnitPosition(transporteeID) 
        if loadUnit(unitID, transporteeID) then
          transportersStates[unitID] = moveBack
        end
      end
      -- moveBack
      if transportersStates[unitID] == moveBack then
        -- no record in table -> the task wasn't started
        local lx, ly, lz = Spring.GetUnitPosition(transporteeID) 
        if moveOnPosition(unitID, parameter.safePosition) then
          transportersStates[unitID] = unloadUnit
        end
      end
      -- unload
      if transportersStates[unitID] == unloadUnit then
        -- no record in table -> the task wasn't started
        local lx, ly, lz = Spring.GetUnitPosition(transporteeID) 
        if unloadUnit(unitID, transporteeID) then
          transportersStates[unitID] = nil
        end
      end
    end
  end
  if #transportersStates > 0 then
    return RUNNING
  else 
    return SUCCESS
  end
end

-- check function
function isUnitOK(unitID)
  if not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead(unitID) then
    transportersStates[unitID] = nil
    return false
  else
    return true
  end
end


-- functions for first, third step
function moveOnPosition(transporterID, targetPosition) 
  local onPos = isOnPosition (transporterID, targetPosition) 
  if #Spring.GetUnitCommands(transporterID) == 0 and onPos == false then 
    Spring.GiveOrderToUnit(transporterID, CMD.MOVE, targetPosition:AsSpringVector(), {})
    return false
  else
    if onPos then 
      return true
    else
      return false
    end
  end
end   

function isOnPosition(transporterID, targetPosition) 
  local tranPosX, tranPosY, tranPosZ = Spring.GetUnitPosition(transporterID)
  if math.abs(tranPosX - targetPosition.x) > threshold or math.abs(tranPosZ - targetPosition.z) > threshold then 
      return false  
  end 
  return true
end

-- functions for second step
funtion loadUnit(transporterID, transporteeID) 
  local loaded = isLoaded(transporterID, transporteeID) 
  if #Spring.GetUnitCommands(transporterID) == 0 and loaded == false then 
    Spring.GiveOrderToUnit(transporterID, CMD.LOAD_UNITS, {transporteeID}, {})
    return false
  else
    if loaded then 
      return true
    else
      return false
    end
  end
end

function isLoaded(transporterID, transporteeID)
  -- transporterId 
  local tranID = Spring.GetUnitTransporter(transporteeID)
  return not nil == tranID and tranID == transporterID
end

-- functions for fourth step
funtion unloadUnit(transporterID, transporteeID) 
  local unloaded = isUnloaded(transporterID, transporteeID) 
  if #Spring.GetUnitCommands(transporterID) == 0 and loaded == false then 
    local lx, ly, lz = Spring.GetUnitPOsition(transportedID)
    local radius = 1
    local actualHeight = Spring.GetGroundHeight(lx, lz)    
    Spring.GiveOrderToUnit(parameter.transporterId, CMD.UNLOAD_UNITS, {ly, actualHeight, lz, radius} , {})  
    return false
  else
    if unloaded then 
      return true
    else
      return false
    end
  end
end

function isUnloaded(transporterID, transporteeID)
  return nil == Spring.GetUnitTransporter(transporteeID)
end
 
  