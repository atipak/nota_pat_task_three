local sensorInfo = {
	name = "UnitsToRescue",
	desc = "Creates vector of dimension count with values of given value",
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