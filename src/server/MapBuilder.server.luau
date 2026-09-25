-- MapBuilder.server.luau
local Workspace = game:GetService("Workspace")

local mapFolder = Instance.new("Folder")
mapFolder.Name = "ProceduralArena"
mapFolder.Parent = Workspace

-- 1. Build a much bigger fighting floor (e.g., 300x300 instead of 120x120)
local floor = Instance.new("Part")
floor.Name = "ArenaFloor"
floor.Size = Vector3.new(300, 2, 300)
floor.Position = Vector3.new(0, 0, 0)
floor.Anchored = true
floor.BrickColor = BrickColor.new("Dark stone grey")
floor.Material = Enum.Material.Concrete
floor.Parent = mapFolder

-- 2. Build much higher perimeter walls (e.g., 40 studs high)
local wallThickness = 6
local wallHeight = 40
local arenaSize = 300
local halfSize = arenaSize / 2

local function createWall(size, position)
    local wall = Instance.new("Part")
    wall.Size = size
    wall.Position = position
    wall.Anchored = true
    wall.BrickColor = BrickColor.new("Medium stone grey")
    wall.Material = Enum.Material.Slate
    wall.Parent = mapFolder
end

-- North and South walls
createWall(Vector3.new(arenaSize, wallHeight, wallThickness), Vector3.new(0, wallHeight/2, -halfSize))
createWall(Vector3.new(arenaSize, wallHeight, wallThickness), Vector3.new(0, wallHeight/2, halfSize))

-- East and West walls
createWall(Vector3.new(wallThickness, wallHeight, arenaSize), Vector3.new(-halfSize, wallHeight/2, 0))
createWall(Vector3.new(wallThickness, wallHeight, arenaSize), Vector3.new(halfSize, wallHeight/2, 0))

print("Massive arena generated!")