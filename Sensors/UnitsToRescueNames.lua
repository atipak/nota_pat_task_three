local sensorInfo = {
	name = "UnitsToRescueNames",
	desc = "Returns names of units to rescue.",
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
return function()
  values = {}
  values["armbox"] = true
  values["armmllt"] = true
  values["armham"] = true
  values["armrock"] = true
  values["armbull"] = true 
  return values 
end