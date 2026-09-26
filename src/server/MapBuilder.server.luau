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

-- Gameplay: Interactive Target Dummy using a standard Roblox character model + Health Bar
task.spawn(function()
    local success, dummyModel = pcall(function()
        return game:GetService("Players"):CreateHumanoidModelFromUserId(1)
    end)

    if success and dummyModel then
        dummyModel.Name = "TrainingDummy"
        
        local rootPart = dummyModel:FindFirstChild("HumanoidRootPart")
        local head = dummyModel:FindFirstChild("Head") or rootPart
        local humanoid = dummyModel:FindFirstChildOfClass("Humanoid")

        if rootPart then
            rootPart.CFrame = CFrame.new(0, 5, -15)
            rootPart.Anchored = true
        end

        -- Create BillboardGui Health Bar above the dummy
        if head then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "HealthGui"
            billboard.Size = UDim2.new(0, 120, 0, 30)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = head

            local bgFrame = Instance.new("Frame")
            bgFrame.Size = UDim2.new(1, 0, 0, 8)
            bgFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            bgFrame.BorderSizePixel = 0
            bgFrame.Parent = billboard

            local cornerBg = Instance.new("UICorner")
            cornerBg.CornerRadius = UDim.new(1, 0)
            cornerBg.Parent = bgFrame

            local healthBar = Instance.new("Frame")
            healthBar.Name = "BarFill"
            healthBar.Size = UDim2.new(1, 0, 1, 0)
            healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            healthBar.BorderSizePixel = 0
            healthBar.Parent = bgFrame

            local cornerFill = Instance.new("UICorner")
            cornerFill.CornerRadius = UDim.new(1, 0)
            cornerFill.Parent = healthBar

            -- Update health bar dynamically when damage is taken
            if humanoid then
                humanoid.HealthChanged:Connect(function(newHealth)
                    local healthPercent = math.clamp(newHealth / humanoid.MaxHealth, 0, 1)
                    healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
                end)
            end
        end

        dummyModel.Parent = mapFolder
        print("Successfully loaded standard Roblox avatar dummy with health bar!")
    else
        print("Failed to load avatar dummy model.")
    end
end)

print("Arena generated with spawn point and avatar target dummy.")