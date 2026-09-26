-- src/Server/CombatServer.server.luau
print("--- COMBAT SERVER SCRIPT IS RUNNING ---")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- TEMP: run once to discover animation IDs inside the punch pack model
-- Remove this block once we have the real AnimationId(s) and CombatClient
-- has been updated with the real PUNCH_ANIMATION_ID.
local InsertService = game:GetService("InsertService")

local success, model = pcall(function()
    return InsertService:LoadAsset(1206194659)
end)

if success and model then
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("Animation") then
            print("Found Animation:", descendant.Name, "-", descendant.AnimationId)
        end
    end
    model:Destroy()
else
    warn("Failed to load asset:", model)
end
-- END TEMP BLOCK

-- Ensure the RemoteEvent exists on the server
local combatEvent = ReplicatedStorage:FindFirstChild("PerformAttackEvent")
if not combatEvent then
    combatEvent = Instance.new("RemoteEvent")
    combatEvent.Name = "PerformAttackEvent"
    combatEvent.Parent = ReplicatedStorage
end

-- Play the punch sound on the server so it replicates to every client,
-- parented to the puncher's own character so it comes from the right position.
local function playPunchSound(character)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://112568860476160"
    sound.Volume = 0.5
    sound.Parent = rootPart
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
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
    emitter.Texture = "rbxassetid://1084889503"
    emitter.Color = ColorSequence.new(Color3.fromRGB(0, 255, 120), Color3.fromRGB(0, 150, 255)) -- Cyan/Green anime impact
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(1, 2.5)
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 1)
    })
    emitter.Speed = NumberRange.new(10, 20)
    emitter.SpreadAngle = Vector2.new(60, 60)
    emitter.Lifetime = NumberRange.new(0.2, 0.4)
    emitter.Rate = 0
    emitter.Parent = attachment

    -- Fire a clean burst
    emitter:Emit(30)

    -- Quick cleanup
    task.delay(0.5, function()
        effectPart:Destroy()
    end)
end

combatEvent.OnServerEvent:Connect(function(player, attackType, isRight)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local rootPart = character.HumanoidRootPart

    -- Alternate particle offset side based on left/right combo state
    local sideOffset = isRight and (rootPart.CFrame.RightVector * 1.2) or (rootPart.CFrame.RightVector * -1.2)
    local hitPos = rootPart.Position + (rootPart.CFrame.LookVector * 4) + sideOffset

    -- Trigger visual effects and audio
    createPunchEffect(hitPos)
    playPunchSound(character)

    -- Hit detection for other players
    for _, otherPlayer in ipairs(game:GetService("Players"):GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")

            if otherRoot and humanoid then
                local distance = (rootPart.Position - otherRoot.Position).Magnitude
                if distance <= 8 then
                    humanoid:TakeDamage(10)
                    print(player.Name .. " successfully punched " .. otherPlayer.Name)
                end
            end
        end
    end

    -- Hit detection for the Training Dummy model in workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "TrainingDummy" then
            local dummyRoot = obj:FindFirstChild("HumanoidRootPart")
            local dummyHumanoid = obj:FindFirstChildOfClass("Humanoid")

            if dummyRoot and dummyHumanoid then
                local distance = (rootPart.Position - dummyRoot.Position).Magnitude
                if distance <= 8 then
                    dummyHumanoid:TakeDamage(10)
                    print(player.Name .. " successfully punched the TrainingDummy!")
                end
            end
        end
    end
end)