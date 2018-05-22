function getInfo()
	return {
		onNoUnits = SUCCESS,
		parameterDefs = {
      { 
				name = "enemyId",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "Sensors.nota_pat_task_two.TransporterId()"
			}
		}
	}
end

local alreadyLaunch = false
local threshold = 25

function Run(self, unitIds, parameter) 
	units = unitIds
	unitsSize = #unitIds
  local enemy = parameter.enemyId
  if enemy == nil then 
      enemy = Spring.GetUnitNearestEnemy(units[1])
  end
  
  -- order already launched
  if alreadyLaunch then 
    if CheckEnemy(parameter.transporterId) then 
      return RUNNING
    else 
      return SUCCESS 
    end 
  end  
  if enemy ~= nil then    
    for index = 1, #units do
      local unitId = units[index] 
      if unitId ~= parameter.transporterId then
        Spring.GiveOrderToUnit(unitId, CMD.ATTACK, {enemyId}, {})
      end
    end
  end
  alreadyLaunch = true
  return RUNNING
end

-- function for sending commands
function CheckEnemy(units)
  local enemyId = Spring.GetUnitNearestEnemy(units[1])
  if enemyId == nil then
    return false
  end
  if Spring.GetUnitIsDead(enemyId) then 
    return false
  end
  return true
end
  