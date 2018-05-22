function getInfo()
	return {
		onNoUnits = SUCCESS,
		parameterDefs = {
			{ 
				name = "targetPosition",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = ""
			},
      { 
				name = "transporterId",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "Sensors.nota_pat_task_two.TransporterId()"
			}
		}
	}
end

local alreadyLaunch = false
local threshold = 20

function Run(self, unitIds, parameter) 
	units = unitIds
	unitsSize = #unitIds
  
  if parameter.transporterId == nil then 
    Spring.Echo("Transporte ID doesn't have to be nil. If you use recommended Sensor, you assure that you have a Bear selected.")
    return FAILURE
  end
  -- becouse the target position in mission is enemy position, the target will be moved slightly away
  local target = parameter.targetPosition + Vec3(20,0,20) 
  
  -- order already launched
  if alreadyLaunch then 
    if CheckTransporterPosition(parameter.transporterId, target) then 
      return RUNNING
    else 
      return SUCCESS 
    end 
  end       
  Spring.GiveOrderToUnit(parameter.transporterId, CMD.MOVE, target:AsSpringVector(), {})
  alreadyLaunch = true
  return RUNNING
end

-- function for sending commands
function CheckTransporterPosition(tid, target)
  local isRunning = false
  local lx, ly, lz = Spring.GetUnitPosition(tid)
  -- is tansporter outside the target area? -> RUNNING state
  if math.abs(lx - target.x) > threshold or math.abs(lz - target.z) > threshold then 
      isRunning = true  
  end
  return isRunning
end
  