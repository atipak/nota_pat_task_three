local sensorInfo = {
	name = "FreePositions",
	desc = "Returns free positions. It can return {}",
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

-- global variable
map = {}
predecessor = {}


-- @description return current wind statistics
return function()
  -- help variables
  local mapHeight = Game.mapSizeZ
  local mapWidth = Game.mapSizeX
  local step = 20
  -- creating grid
  map = {}
  predecessor = {}
  local maxX = 1
  local maxZ = 1
  for x = 1, mapWidth, step do
    map[x] = {} 
    predecessor[x] = {} 
    for z = 1, mapHeight, step do 
      if Spring.GetGroundHeight(x, z) == 0 then
        map[x][z] = true
      else
        map[x][z] = false
      end
      predecessor[x][z]  = nil
    end 
  end
end

List = {}
function List.new ()
  return {first = 0, last = -1}
end

function List.pushleft (list, value)
  local first = list.first - 1
  list.first = first
  list[first] = value
end

function List.pushright (list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
end

function List.popleft (list)
  local first = list.first
  if first > list.last then error("list is empty") end
  local value = list[first]
  list[first] = nil        -- to allow garbage collection
  list.first = first + 1
  return value
end

function List.popright (list)
  local last = list.last
  if list.first > last then error("list is empty") end
  local value = list[last]
  list[last] = nil         -- to allow garbage collection
  list.last = last - 1
  return value
end

-- predecessor
-- node type: Vec3
function findPathInValley(beginPosition, endPosition, step, mapWidth, mapHeight)
  local frontier = List.new()
  local backPath = {}
  List.pushleft(frontier, beginPosition)
  while #frontier > 0 do
    local node = List.popright(frontier)
    if endPosition.x == node.x and endPosition.y == node.y and endPosition.z == node.z then 
      local index = 1 
      while node ~= nil do
        local pred = predecessor[node.x][node.z]
        backPath[index] = node
        node = pred
      end
      break
    end     
    -- east point
    px = node.x + iterationShift
    -- south point
    mz = node.z - iterationShift
    -- west point
    mx = node.x - iterationShift
    -- nord point
    pz = node.z + iterationShift
    -- nord
    if isOnMap(node.x, pz, mapWidth, mapHeight) and map[node.x][pz] then
      local newNode = Vec3(node.x, 0, pz) 
      predecessor[node.x][pz] = node
      List.pushleft(frontier, newNode)  
    end
    -- south
    if isOnMap(node.x, mz, mapWidth, mapHeight) and map[node.x][mz] then
      local newNode = Vec3(node.x, 0, mz) 
      predecessor[node.x][mz] = node
      List.pushleft(frontier, newNode)  
    end
    -- east
    if isOnMap(px, node.z, mapWidth, mapHeight) and map[px][node.z] then
      local newNode = Vec3(px, 0, node.z) 
      predecessor[px][node.z] = node
      List.pushleft(frontier, newNode)  
    end
    -- west
    if isOnMap(mx, node.z, mapWidth, mapHeight) and map[mx][node.z] then
      local newNode = Vec3(mx, 0, node.z) 
      predecessor[mx][node.z] = node
      List.pushleft(frontier, newNode)  
    end
  end
  -- reversing of backPath
  if #backPath > 0 then
    newBackPath = {}
    for i = #backPath, 1, -1 do
      newBackPath[#backPath - i + 1] = backPath[i]
    end
    backPath = newBackPath
  end
  return backPath
end

function isOnMap(x, z, mapWidth, mapHeight)
  -- east point
  if x > mapWidth then 
     return false
  end 
  -- south point
  if z < 1 then 
     return false
  end 
  -- west point
  if x < 1 then 
     return false
  end 
  -- nord point
  if z > mapHeight then 
     return false
  end 
  return true
end




