-- src/Server/CombatServer.server.luau
print("--- COMBAT SERVER SCRIPT IS RUNNING ---")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Ensure the RemoteEvent exists on the server as well
local combatEvent = ReplicatedStorage:FindFirstChild("PerformAttackEvent")
if not combatEvent then
    combatEvent = Instance.new("RemoteEvent")
    combatEvent.Name = "PerformAttackEvent"
    combatEvent.Parent = ReplicatedStorage
end

combatEvent.OnServerEvent:Connect(function(player, attackType)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    
    -- HIGH VISUAL, LOW COST: Spawn a quick neon punch flash in front of the player
    local fxPart = Instance.new("Part")
    fxPart.Size = Vector3.new(4, 4, 4)
    fxPart.CFrame = rootPart.CFrame + (rootPart.CFrame.LookVector * 4)
    fxPart.Anchored = true
    fxPart.CanCollide = false
    fxPart.Material = Enum.Material.Neon
    fxPart.Color = Color3.fromRGB(0, 255, 60) -- Neon green theme
    fxPart.Parent = workspace
    
    -- Lightweight cleanup: destroy the effect right after
    task.delay(0.12, function()
        fxPart:Destroy()
    end)
    
    -- Simple hit detection check in front of the player
    for _, otherPlayer in ipairs(game:GetService("Players"):GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            if otherRoot and humanoid then
                local distance = (rootPart.Position - otherRoot.Position).Magnitude
                if distance <= 8 then -- Hit range
                    humanoid:TakeDamage(10)
                    print(player.Name .. " successfully punched " .. otherPlayer.Name)
                end
            end
        end
    end
end)