-- MapBuilder.server.luau
local Workspace = game:GetService("Workspace")

-- Create a folder to keep our map organized in the Workspace
local mapFolder = Instance.new("Folder")
mapFolder.Name = "ProceduralArena"
mapFolder.Parent = Workspace

-- 1. Build the main fighting floor
local floor = Instance.new("Part")
floor.Name = "ArenaFloor"
floor.Size = Vector3.new(120, 2, 120) -- Width, Thickness, Length
floor.Position = Vector3.new(0, 0, 0)
floor.Anchored = true
floor.BrickColor = BrickColor.new("Dark stone grey")
floor.Material = Enum.Material.Concrete
floor.Parent = mapFolder

-- 2. Build perimeter walls for cover and boundaries
local wallThickness = 4
local wallHeight = 15
local arenaSize = 120
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

-- 3. Add internal cover pillars/obstacles so players have tactical spots to hide
local pillarPositions = {
    Vector3.new(-30, 5, -30),
    Vector3.new(30, 5, -30),
    Vector3.new(-30, 5, 30),
    Vector3.new(30, 5, 30),
    Vector3.new(0, 5, 0) -- Center pillar/obelisk
}

for _, pos in ipairs(pillarPositions) do
    local pillar = Instance.new("Part")
    pillar.Size = Vector3.new(8, 10, 8)
    pillar.Position = pos
    pillar.Anchored = true
    pillar.BrickColor = BrickColor.new("Persian blue")
    pillar.Material = Enum.Material.Neon
    pillar.Parent = mapFolder
end

print("Battlegrounds arena successfully generated!")