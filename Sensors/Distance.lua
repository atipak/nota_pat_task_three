local sensorInfo = {
	name = "Distance",
	desc = "Distance between two points on map",
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
return function(positionOne, positionTwo)
  if positionTwo == nil or positionOne == nil or type(positionOne) ~= Vec3 or type(positionTwo) ~= Vec3 then 
    return -1
  end 
  return math.sqrt(math.pow(positionOne.x - positionTwo.x, 2) + math.pow(positionOne.y - positionTwo.y, 2) + math.pow(positionOne.z - positionTwo.z, 2))
end