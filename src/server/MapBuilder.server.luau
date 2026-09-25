-- MapBuilder.server.luau
local Workspace = game:GetService("Workspace")

-- Clear old arena if it exists to prevent duplication
local oldMap = Workspace:FindFirstChild("ProceduralArena")
if oldMap then
    oldMap:Destroy()
end

local mapFolder = Instance.new("Folder")
mapFolder.Name = "ProceduralArena"
mapFolder.Parent = Workspace

-- 1. Build the massive fighting floor
local floor = Instance.new("Part")
floor.Name = "ArenaFloor"
floor.Size = Vector3.new(300, 2, 300)
floor.Position = Vector3.new(0, 0, 0)
floor.Anchored = true
floor.BrickColor = BrickColor.new("Dark stone grey")
floor.Material = Enum.Material.Concrete
floor.Parent = mapFolder

-- 2. Build high perimeter walls
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

createWall(Vector3.new(arenaSize, wallHeight, wallThickness), Vector3.new(0, wallHeight/2, -halfSize))
createWall(Vector3.new(arenaSize, wallHeight, wallThickness), Vector3.new(0, wallHeight/2, halfSize))
createWall(Vector3.new(wallThickness, wallHeight, arenaSize), Vector3.new(-halfSize, wallHeight/2, 0))
createWall(Vector3.new(wallThickness, wallHeight, arenaSize), Vector3.new(halfSize, wallHeight/2, 0))

-- 3. THE UPDATE MARKER PROP (Locked position, color changed to blue for this update)
local updateMarker = Instance.new("Part")
updateMarker.Name = "UpdateMarkerProp"
updateMarker.Size = Vector3.new(12, 12, 12)
updateMarker.Position = Vector3.new(100, 6, -100) -- Locked coordinate position
updateMarker.Anchored = true
updateMarker.BrickColor = BrickColor.new("Cyan") -- Blue update color
updateMarker.Material = Enum.Material.Neon
updateMarker.Parent = mapFolder

print("Arena updated with locked position and blue marker color!")