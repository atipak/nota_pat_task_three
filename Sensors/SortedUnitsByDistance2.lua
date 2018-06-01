local sensorInfo = {
	name = "SortedUnitsByDistance",
	desc = "Sorts units by distance from basicPosition",
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

-- bubble sort
function sort(distances)
  while true do
    local again = false 
    for i = 1, #distances - 1 do
      if distances[i].dist > distances[i + 1].dist then 
        local temp = distances[i + 1]
        distances[i + 1] = distances[i]  
        distances[i] = temp
        again = true
      end           
    end
    if not again then
      break
    end
  end
  return distances
end


-- return euclide distance
function vectorsDistance(positionOne, positionTwo) 
  return math.sqrt(math.pow(positionOne.x - positionTwo.x, 2) + math.pow(positionOne.z - positionTwo.z, 2))
end

-- @description ff 
return function(basicPosition, unitsIds)
  -- basic conditions
  if #unitsIds == 0 or basicPosition == nil then 
    return {}
  end
  -- sort units by distance from basic position
  -- calculate distance and creates an array
  head = nil
  local distances = {}
  for index = 1, #unitsIds do
    local unitId = unitsIds[index]
    local lx, ly, lz = Spring.GetUnitPosition(unitId)
    local posVec = Vec3(lx,ly,lz)
    local distance = vectorsDistance(basicPosition, posVec)
    distances[index] = {unitID = unitId, dist = distance, vector = posVec}
  end  
  -- sorting
  distances = sort(distances)         
  -- iterate over units with distance and return only units IDs
  ids = {}
  for i = 1, #distances do
    ids[i] = distances[i].unitID           
  end
  return ids
end


