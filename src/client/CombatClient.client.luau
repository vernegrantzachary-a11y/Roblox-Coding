-- src/Client/CombatClient.client.luau
print("--- COMBAT CLIENT SCRIPT IS RUNNING ---")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local combatEvent = ReplicatedStorage:FindFirstChild("PerformAttackEvent")
if not combatEvent then
    combatEvent = Instance.new("RemoteEvent")
    combatEvent.Name = "PerformAttackEvent"
    combatEvent.Parent = ReplicatedStorage
end

-- Camera Shake Setup
local shakeIntensity = 0.25
local shakeDuration = 0.15
local shakeTimer = 0

local function triggerCameraImpact()
    shakeTimer = shakeDuration
end

RunService.RenderStepped:Connect(function(dt)
    if shakeTimer > 0 then
        shakeTimer = shakeTimer - dt
        local currentIntensity = shakeIntensity * (shakeTimer / shakeDuration)
        local randomOffset = Vector3.new(
            math.random() * 2 - 1,
            math.random() * 2 - 1,
            0
        ) * currentIntensity
        camera.CFrame = camera.CFrame * CFrame.Angles(randomOffset.X * 0.05, randomOffset.Y * 0.05, 0)
    end
end)

-- Combat Animation Setup with Clean Combat IDs & Maximum Action Priority
local leftAnimTrack: AnimationTrack = nil
local rightAnimTrack: AnimationTrack = nil
local useRightPunch = false

task.spawn(function()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")

    -- Left Jab / Punch ID (Action4 overrides custom bundles)
    local leftAnim = Instance.new("Animation")
    leftAnim.AnimationId = "rbxassetid://10468665991" 
    leftAnimTrack = animator:LoadAnimation(leftAnim)
    leftAnimTrack.Priority = Enum.AnimationPriority.Action4
    leftAnimTrack.Looped = false

    -- Right Cross / Punch ID (Action4 overrides custom bundles)
    local rightAnim = Instance.new("Animation")
    rightAnim.AnimationId = "rbxassetid://13532562418" 
    rightAnimTrack = animator:LoadAnimation(rightAnim)
    rightAnimTrack.Priority = Enum.AnimationPriority.Action4
    rightAnimTrack.Looped = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        print("E key pressed locally!")
        triggerCameraImpact()

        -- Play alternating punch tracks cleanly
        if useRightPunch then
            if rightAnimTrack then
                leftAnimTrack:Stop(0.1) -- Stop opposite track to prevent blending locks
                rightAnimTrack:Play(0.1, 1, 1.2) -- Slight speed boost for snappiness
            end
        else
            if leftAnimTrack then
                rightAnimTrack:Stop(0.1)
                leftAnimTrack:Play(0.1, 1, 1.2)
            end
        end

        combatEvent:FireServer("LightPunch", useRightPunch)
        useRightPunch = not useRightPunch
    end
end)