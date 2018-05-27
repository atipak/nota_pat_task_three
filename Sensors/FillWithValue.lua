local sensorInfo = {
	name = "UnitsToRescue",
	desc = "Returns ids of units to rescue. It can return {}",
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


-- @description 
return function(value, count)
  filled = {}
  for i = 1, count do
    filled[i] = value
  end
  return filled
end