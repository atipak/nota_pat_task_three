function getInfo()
	return {
		onNoUnits = SUCCESS,
		parameterDefs = {
      { 
				name = "transporterId",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "Sensors.nota_pat_task_two.TransporterId()"
			},
      { 
				name = "unitsToLoad",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "{}"
			}
		}
	}
end

local alreadyLaunch = false

function Run(self, unitIds, parameter) 
	units = unitIds
	unitsSize = #units
  
  if parameter.transporterId == nil then 
    Spring.Echo("Transporte ID doesn't have to be nil. If you use recommended Sensor, you assure that you have a Bear selected.")
    return FAILURE
  end
  
  -- order already launched
  if alreadyLaunch then 
    if CheckLoadedUnits(units, parameter.transporterId) then 
      return RUNNING
    else 
      return SUCCESS 
    end 
  end
  -- for each unit (except a transporter) add command for its loading
  for index = 1, #units do
    local unitId = units[index] 
    if (unitId ~= parameter.transporterId) then
      Spring.GiveOrderToUnit(parameter.transporterId, CMD.INSERT, {-1, CMD.LOAD_UNITS, CMD.OPT_SHIFT, unitId}, {"alt"})
      --Spring.GiveOrderToUnit(parameter.transporterId, CMD.LOAD_UNITS, {unitId}, {})
    end
  end
  alreadyLaunch = true
  return RUNNING
end

-- function for sending commands
function CheckLoadedUnits(units, tid)
  local isRunning = false
  for index = 1, #units do
    unitId = units[index]
    -- unit isn't a transporter
    if unitId ~= tid then
      -- is unit in the transporter?
      local transport = Spring.GetUnitTransporter(unitId)
      -- if ins't
      if transport == nil then
        -- there is no command left, add new command to command queue
        if #Spring.GetUnitCommands(tid) == 0 then 
          Spring.GiveOrderToUnit(tid, CMD.INSERT, {-1, CMD.LOAD_UNITS, CMD.OPT_SHIFT, unitId}, {"alt"})
        end
        isRunning = true
        break 
      end
    end          
  end 
  return isRunning
end
  