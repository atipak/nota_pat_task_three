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


head = nil


-- @description return current wind statistics
return function(basicPosition, unitsIds)
  if #unitsIds == 0 or basicPosition == nil or type(basicPositon) ~= Vec3 then 
    return {}
  end
  head = nil
  for index = 0, #unitsIds do
    unitId = unitsIds[index]
    local lx, ly, lz = Spring.GetUnitPosition(unitId)
    local posVec = Vec3(lx,ly,lz)
    local distance = nota_pat_task_three.Distance(basicPosition, posVec)
    insertNode(posVec, distance)  
  end
  vectors = {}
  local node = head
  local index = 1
  while node ~= nil do
    vectors[index] = node.vector
    node = node.next
    index = index + 1
  end
  return vectors
end

function insertNode(vector, distance)
  local node = head 
  local nextNode = nil
  if node ~= nil then 
    nextNode = node.next
  end
  while nextNode ~= nil or nextNode.distance <= distance do
    node = nextNode
    nextNode = node.next 
  end
  if node ~= nil then 
    node.next = {next = nextNode, distance = distance, vector = vector}
  else 
    head = {next = nextNode, distance = distance, vector = vector} 
  end 
end