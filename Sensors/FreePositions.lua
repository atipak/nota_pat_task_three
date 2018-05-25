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


-- @description return current wind statistics
return function()
  -- help variables
  local mapHeight = Game.mapSizeZ
  local mapWidth = Game.mapSizeX
  local step = 20
  -- creating grid
  local map = {}
  local maxX = 1
  local maxZ = 1
  for x = 1, mapWidth, step do
    map[x] = {} 
    for z = 1, mapHeight, step do 
      map[x][z] = true 
    end 
  end
  -- getting enemy teams
  local teams = Spring.GetTeamList()
  local myTeam = Spring.GetLocalTeamID()
  local enemyTeams = {}
  local index = 1
  for i = 1, #teams do
    if not Spring.AreTeamsAllied(myTeam, teams[i]) then 
      enemyTeams[index] = teams[i]
      index = index + 1
    end
  end
  for teamIndex = 1, #enemyTeams do
    local enemyUnits =  Spring.GetTeamUnits(enemyTeams[teamIndex]) 
    for unitIndex = 1, #enemyUnits do
      local unitId = enemyUnits[unitIndex]
      local unitDefId = Spring.GetUnitDefID(unitId)
      if unitDefId ~= nil then
        local unitDef = UnitDefs[unitDefId]
        local lx, ly, lz = Spring.GetUnitPosition(unitId)
        local unitPosition = Vec3(lx, ly, lz)
        local weapons = unitDef.weapons
        for weaponIndex = 1, #weapons do
          local weapon = weapons[weaponIndex]
          -- weapon radius
          local weaponRadius = 10 --TODO
          local dangerPoints = pointsInCircle(unitPosition, weaponRadius, step) 
          for index = 1, #dangerPoints do
            local dangerPoint = dangerPoints[index]
            map[dangerPoint.x][dangerPoint.z] = false
          end
        end
      end
    end
  end
end



function findClosestInGrid(position, step, maxWidth, maxHeight)
  -- variables
  local left = math.fmod(position.x, step) * step + 1 
  local right = (math.fmod(position.x, step) + 1) * step + 1 
  local top = math.fmod(position.z, step) * step + 1
  local bottom = (math.fmod(position.z, step) + 1) * step + 1 

  -- east point
  if right > mapWidth then 
     right = math.fmod(mapWidth, step) * step + 1  
  end 
  -- south point
  if top < 1 then 
     top = 1
  end 
  -- west point
  if left < 1 then 
     left = 1
  end 
  -- nord point
  if bottom > mapHeight then 
     bottom = math.fmod(mapHeight, step) * step + 1  
  end   
  -- top left corner, top right corner, bottom left corner, bottom right corner
  corners = {}
  corners.bottomLeft = Vec3(left, Spring.GetGroundHeight(left, bottom), bottom)
  corners.bottomRight = Vec3(right, Spring.GetGroundHeight(right, bottom), bottom)
  corners.topLeft = Vec3(left, Spring.GetGroundHeight(left, top), top)
  corners.topRight = Vec3(right, Spring.GetGroundHeight(right, top), top)
  return corners
end

function pointsInCircle(position, radius, step, maxWidth, maxHeight) 
  local x, z = position.x, position.z
  local px, mx, pz, mz = mapWidth, 1, mapHeight, 1
  -- east point
  if x + radius < mapWidth then 
     px = x + radius
  end 
  -- south point
  if z - radius > 1 then 
     mz = z - radius
  end 
  -- west point
  if x - radius > 1 then 
     mx = x - radius
  end 
  -- nord point
  if z + radius < mapHeight then 
     pz = z + radius
  end 
  -- NW, NE, SW, SE 
  local nwPoint, nePoint, swPoint, sePoint =  Vec3(mx, position.y, pz), Vec3(px, position.y, pz), Vec3(mx, position.y, mz), Vec3(px, position.y, mz)
  local topLeft, topRight =  findClosestInGrid(nwPoint, step, maxWidth, maxHeight).topLeft, findClosestInGrid(nePoint, step, maxWidth, maxHeight).topRight
  local bottomLeft, bottomRight = findClosestInGrid(swPoint, step, maxWidth, maxHeight).bottomLeft, findClosestInGrid(sePoint, step, maxWidth, maxHeight).bottomRight
  local dangerPoints = {}
  local pointsIndex = 1
  for pointX = topLeft.x, topRight.x, step do
    for pointZ = topLeft.z, bottomLeft.z, step do
      local dangerPoint = Vec3(pointX, Spring.GetGroundHeight(pointX, pointZ), pointZ)
      if isInArea(position, radius, dangerPoint) then 
        dangerPoints[pointsIndex] = dangerPoint
        pointsIndex = pointsIndex + 1
      end
    end
  end
end

function isInArea(basePosition, radius, position)
  return (position.x - basePosition.x)^2 + (position.z - basePosition.z)^2 <= radius^2
end