-- MapBuilder.server.luau
print("--- MAP BUILDER SCRIPT IS RUNNING ---")
local Workspace = game:GetService("Workspace")

local oldMap = Workspace:FindFirstChild("ProceduralArena")
if oldMap then
    oldMap:Destroy()
end

local mapFolder = Instance.new("Folder")
mapFolder.Name = "ProceduralArena"
mapFolder.Parent = Workspace

-- Arena Floor
local floor = Instance.new("Part")
floor.Name = "ArenaFloor"
floor.Size = Vector3.new(300, 2, 300)
floor.Position = Vector3.new(0, 0, 0)
floor.Anchored = true
floor.BrickColor = BrickColor.new("Dark stone grey")
floor.Material = Enum.Material.Concrete
floor.Parent = mapFolder

-- Perimeter Walls
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

-- Neon Green Update Marker
local updateMarker = Instance.new("Part")
updateMarker.Name = "UpdateMarkerProp"
updateMarker.Size = Vector3.new(12, 12, 12)
updateMarker.Position = Vector3.new(100, 6, -100)
updateMarker.Anchored = true
updateMarker.Color = Color3.fromRGB(0, 255, 60)
updateMarker.Material = Enum.Material.Neon
updateMarker.Parent = mapFolder

-- Gameplay: Spawn Location
local spawnLocation = Instance.new("SpawnLocation")
spawnLocation.Name = "GameSpawn"
spawnLocation.Size = Vector3.new(10, 1, 10)
spawnLocation.Position = Vector3.new(0, 2, 0)
spawnLocation.Anchored = true
spawnLocation.BrickColor = BrickColor.new("Deep blue")
spawnLocation.Material = Enum.Material.Neon
spawnLocation.Parent = mapFolder

-- Gameplay: Interactive Target Dummy (Touch to print points/score concept)
local targetDummy = Instance.new("Part")
targetDummy.Name = "TargetDummy"
targetDummy.Size = Vector3.new(6, 12, 6)
targetDummy.Position = Vector3.new(-100, 7, -100)
targetDummy.Anchored = true
targetDummy.BrickColor = BrickColor.new("Hot pink")
targetDummy.Material = Enum.Material.Neon
targetDummy.Parent = mapFolder

targetDummy.Touched:Connect(function(hit)
    local character = hit.Parent
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        print("Player interacted with the target dummy!")
    end
end)

print("Arena generated with spawn point and interactive target dummy.")