function getInfo()
	return {
		onNoUnits = SUCCESS,
		parameterDefs = {
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
local threshold = 25

function Run(self, unitIds, parameter) 
	units = unitIds
	unitsSize = #unitIds
  
  if parameter.transporterId == nil then 
    Spring.Echo("Transporte ID doesn't have to be nil. If you use recommended Sensor, you assure that you have a Bear selected.")
    return FAILURE
  end
  
  -- order already launched
  if alreadyLaunch then 
    if CheckUnload(parameter.transporterId, units) then 
      return RUNNING
    else 
      return SUCCESS 
    end 
  end
  local lx, ly, lz = Spring.GetUnitPosition(parameter.transporterId)
  Spring.GiveOrderToUnit(parameter.transporterId, CMD.UNLOAD_UNITS, {lx,ly,lz,90}, {})      
  alreadyLaunch = true
  return RUNNING
end

-- function for sending commands
function CheckUnload(tid, units)
  isRunning = false
  for index = 1, #units do
    unitId = units[index]
    local transport = Spring.GetUnitTransporter(unitId)
    -- is thre unloaded unit? 
    if transport ~= nil then
        isRunning = true
        break 
    end
  end
  return isRunning
end
  