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

local function createPunchEffect(targetPosition)
    local effectPart = Instance.new("Part")
    effectPart.Size = Vector3.new(1, 1, 1)
    effectPart.Transparency = 1
    effectPart.Anchored = true
    effectPart.CanCollide = false
    effectPart.Position = targetPosition
    effectPart.Parent = workspace

    local attachment = Instance.new("Attachment")
    attachment.Parent = effectPart

    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxassetid://258129463"
    emitter.Color = ColorSequence.new(Color3.fromRGB(255, 200, 50), Color3.fromRGB(255, 50, 50))
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 3)
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    emitter.Speed = NumberRange.new(15, 25)
    emitter.SpreadAngle = Vector2.new(45, 45)
    emitter.Lifetime = NumberRange.new(0.2, 0.4)
    emitter.Rate = 0
    emitter.Parent = attachment

    emitter:Emit(25)

    task.delay(0.5, function()
        effectPart:Destroy()
    end)
end

combatEvent.OnServerEvent:Connect(function(player, attackType)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    
    -- Spawn the particle effect burst in front of the player
    local hitPos = rootPart.Position + (rootPart.CFrame.LookVector * 4)
    createPunchEffect(hitPos)
    
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