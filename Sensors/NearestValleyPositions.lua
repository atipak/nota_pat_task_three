local sensorInfo = {
	name = "FreePositions",
	desc = "Returns nearest valley positions. It can return {}",
	author = "Patik",
	date = "2018-05-11",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- more times per frame

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- global variable
-- grid of the map
map = {}
-- array of predecessors of nodes in BFS
predecessor = {}

-- ====
-- ====
-- queue
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
-- ====
-- ====


-- BFS algorithm
-- beginPosition: Vec3 the position where BFS should begin
-- step in grid
function findNearestPoint(beginPosition, step, mapWidth, mapHeight)
  local frontier = List.new()
  local frontierCount = 0
  local backPath = {}
  List.pushleft(frontier, beginPosition)
  frontierCount = frontierCount + 1
  -- if there are nodes to proccess do
  while frontierCount > 0 do
    local node = List.popright(frontier)
    frontierCount = frontierCount - 1
    -- current node is under limit height
    if map[node.x][node.z] then 
      resetPredecessor(step, mapWidth, mapHeight)
      return Vec3(node.x, Spring.GetGroundHeight(node.x, node.z), node.z)
    end     
    -- east point
    px = node.x + step
    -- south point
    mz = node.z - step
    -- west point
    mx = node.x - step
    -- nord point
    pz = node.z + step
    -- north  
    if isOnMap(node.x, pz, mapWidth, mapHeight) and predecessor[node.x][pz] == nil then
      local newNode = Vec3(node.x, 0, pz) 
      predecessor[node.x][pz] = node
      List.pushleft(frontier, newNode)  
      frontierCount = frontierCount + 1
    end
    -- south
    if isOnMap(node.x, mz, mapWidth, mapHeight) and predecessor[node.x][mz] == nil then   
      local newNode = Vec3(node.x, 0, mz) 
      predecessor[node.x][mz] = node
      List.pushleft(frontier, newNode)  
      frontierCount = frontierCount + 1
    end
    -- east
    if isOnMap(px, node.z, mapWidth, mapHeight) and predecessor[px][node.z] == nil then    
      local newNode = Vec3(px, 0, node.z) 
      predecessor[px][node.z] = node
      List.pushleft(frontier, newNode)  
      frontierCount = frontierCount + 1
    end
    -- west
    if isOnMap(mx, node.z, mapWidth, mapHeight) and predecessor[mx][node.z] == nil then   
      local newNode = Vec3(mx, 0, node.z) 
      predecessor[mx][node.z] = node
      List.pushleft(frontier, newNode) 
      frontierCount = frontierCount + 1 
    end
  end
  return nil
end

-- check if point with coors x and z is on map 
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

-- set nil into predecessor array 
function resetPredecessor(step, mapWidth, mapHeight)
  for x = 1, mapWidth, step do
    for z = 1, mapHeight, step do 
      predecessor[x][z]  = nil
    end
  end 
end


-- @description return current wind statistics
return function(positions, heightThreshold, step)
  -- help variables
  local mapHeight = Game.mapSizeZ
  local mapWidth = Game.mapSizeX
  -- creating grid
  -- point under limit height are true, initialize predecessor array
  map = {}
  predecessor = {}
  local maxX = 1
  local maxZ = 1
  for x = 1, mapWidth, step do
    map[x] = {} 
    predecessor[x] = {} 
    for z = 1, mapHeight, step do 
      if Spring.GetGroundHeight(x, z) <= heightThreshold then
        map[x][z] = true
      else
        map[x][z] = false
      end
      predecessor[x][z]  = nil
    end
  end 
  -- for given points finds nearest low points and the referred node set into "end" key  
  do
    local nearestPositions = {}
    for i = 1, #positions do
      local position = positions[i].position
      local beginPosition = Vec3(math.floor(position.x / step) * step + 1,255, math.floor(position.z / step) * step + 1)
      nearestPositions[i] = positions[i] 
      nearestPositions[i]["end"] = findNearestPoint(beginPosition, step, mapWidth, mapHeight)
    end   
    return nearestPositions
  end
end






