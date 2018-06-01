local sensorInfo = {
	name = "ValleyPathFinder",
	desc = "Finds path between two points in valley. Path is stored in key 'path'",
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

-- BFS 
-- beginPosition Vec3
-- endPosition Vec3
-- step in grid 
function findPathInValley(beginPosition, endPosition, step, mapWidth, mapHeight)
  local frontier = List.new()
  local backPath = {}
  local frontierCount = 0
  List.pushleft(frontier, beginPosition)
  frontierCount = frontierCount + 1
  while frontierCount > 0 do
    local node = List.popright(frontier)
    frontierCount = frontierCount - 1
    -- the current point has to be the same like end point -> find the path using precedessors
    if endPosition.x == node.x and endPosition.z == node.z then 
      local index = 1 
      while node.x ~= beginPosition.x or node.z ~= beginPosition.z do
        local pred = predecessor[node.x][node.z]
        backPath[index] = node
        index = index + 1
        node = pred
      end
      backPath[index] = node
      index = index + 1
      break
    end     
    -- east point
    px = node.x + step
    -- south point
    mz = node.z - step
    -- west point
    mx = node.x - step
    -- nord point
    pz = node.z + step
    -- nord
    if isOnMap(node.x, pz, mapWidth, mapHeight) and map[node.x][pz] and predecessor[node.x][pz] == nil then
      local newNode = Vec3(node.x, 0, pz) 
      predecessor[node.x][pz] = node
      List.pushleft(frontier, newNode)  
      frontierCount = frontierCount + 1
    end
    -- south
    if isOnMap(node.x, mz, mapWidth, mapHeight) and map[node.x][mz] and predecessor[node.x][mz] == nil then
      local newNode = Vec3(node.x, 0, mz) 
      predecessor[node.x][mz] = node
      List.pushleft(frontier, newNode) 
      frontierCount = frontierCount + 1 
    end
    -- east
    if isOnMap(px, node.z, mapWidth, mapHeight) and map[px][node.z] and predecessor[px][node.z] == nil then
      local newNode = Vec3(px, 0, node.z) 
      predecessor[px][node.z] = node
      List.pushleft(frontier, newNode)  
      frontierCount = frontierCount + 1
    end
    -- west
    if isOnMap(mx, node.z, mapWidth, mapHeight) and map[mx][node.z] and predecessor[mx][node.z] == nil then
      local newNode = Vec3(mx, 0, node.z) 
      predecessor[mx][node.z] = node
      List.pushleft(frontier, newNode)  
      frontierCount = frontierCount + 1
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
  resetPredecessor(step, mapWidth, mapHeight)
  return backPath
end

-- reset of array with predecessors
function resetPredecessor(step, mapWidth, mapHeight)
  for x = 1, mapWidth, step do
    for z = 1, mapHeight, step do 
      predecessor[x][z]  = nil
    end
  end 
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


-- @description return current wind statistics
return function(pathParameters, heightThreshold, step)
  -- help variables
  local mapHeight = Game.mapSizeZ
  local mapWidth = Game.mapSizeX
  
  -- creating grid
  -- point under limit height are true, initialize predecessor array
  map = {}
  predecessor = {}
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
  local pathParams = {}
  for i = 1, #pathParameters do
    --Spring.Echo(i)
    local p = findPathInValley(pathParameters[i]["begin"], pathParameters[i]["end"], step, mapWidth, mapHeight)   
    pathParams[i] = pathParameters[i]
    pathParams[i]["path"] = p
  end
  return pathParams
end






