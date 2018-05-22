local sensorInfo = {
	name = "TransporterID",
	desc = "Returns ids of transporters. It can return {}",
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


-- @description return current wind statistics
return function()
  -- there are no units
  if #units == 0 then 
    return nil
  end
  local transpotersIds = {}
  -- searching over all units, if tranaporters is found, its id is stored
  local index = 1
  for i = 1, #units do
    local unitId = units[i]
    local unitDefID = Spring.GetUnitDefID(unitId)
    if UnitDefs[unitDefID].name == "armthovr" then
       transportersIds[index] = unitId
       index = index + 1  
    end          
  end 
  return transportersIds
end