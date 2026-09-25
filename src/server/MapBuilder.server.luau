-- MapBuilder.server.luau
local Workspace = game:GetService("Workspace")

-- Create a folder to keep our map organized in the Workspace
local mapFolder = Instance.new("Folder")
mapFolder.Name = "ProceduralArena"
mapFolder.Parent = Workspace

local arenaSize = 120
local halfSize = arenaSize / 2

-- 1. Build a detailed, tiled floor
local tileSize = 10
for x = -halfSize, halfSize - tileSize, tileSize do
    for z = -halfSize, halfSize - tileSize, tileSize do
        local tile = Instance.new("Part")
        tile.Size = Vector3.new(tileSize, 2, tileSize)
        -- Center each tile properly on the grid
        tile.Position = Vector3.new(x + tileSize/2, 0, z + tileSize/2)
        tile.Anchored = true
        tile.Material = Enum.Material.Concrete
        
        -- Alternate tile colors for a cool tactical grid pattern
        if (x / tileSize + z / tileSize) % 2 == 0 then
            tile.BrickColor = BrickColor.new("Dark stone grey")
        else
            tile.BrickColor = BrickColor.new("Medium stone grey")
        end
        
        tile.Parent = mapFolder
    end
end

-- 2. Build much higher perimeter walls for the battlegrounds
local wallThickness = 4
local wallHeight = 40 -- Made much higher!

local function createWall(size, position)
    local wall = Instance.new("Part")
    wall.Size = size
    wall.Position = position
    wall.Anchored = true
    wall.BrickColor = BrickColor.new("Black")
    wall.Material = Enum.Material.SmoothPlastic
    wall.Parent = mapFolder
end

-- North and South walls
createWall(Vector3.new(arenaSize, wallHeight, wallThickness), Vector3.new(0, wallHeight/2, -halfSize))
createWall(Vector3.new(arenaSize, wallHeight, wallThickness), Vector3.new(0, wallHeight/2, halfSize))

-- East and West walls
createWall(Vector3.new(wallThickness, wallHeight, arenaSize), Vector3.new(-halfSize, wallHeight/2, 0))
createWall(Vector3.new(wallThickness, wallHeight, arenaSize), Vector3.new(halfSize, wallHeight/2, 0))

print("Detailed high-wall arena successfully generated!")