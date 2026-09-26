-- src/Client/CombatClient.client.luau
print("--- COMBAT CLIENT SCRIPT IS RUNNING ---")
print("CLIENT SCRIPT LOADED AND RUNNING")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- Ensure RemoteEvent exists
local combatEvent = ReplicatedStorage:FindFirstChild("PerformAttackEvent")
if not combatEvent then
    combatEvent = Instance.new("RemoteEvent")
    combatEvent.Name = "PerformAttackEvent"
    combatEvent.Parent = ReplicatedStorage
end

-- Camera Shake Variables (Tuned down intensity to prevent stacking overload)
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

-- Animation Variables for Left/Right Combo Chain
local leftAnimTrack: AnimationTrack = nil
local rightAnimTrack: AnimationTrack = nil
local useRightPunch = false

task.spawn(function()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")

    -- Load Left Punch Animation
    local leftAnim = Instance.new("Animation")
    leftAnim.AnimationId = "rbxassetid://913376220"
    leftAnimTrack = animator:LoadAnimation(leftAnim)
    leftAnimTrack.Priority = Enum.AnimationPriority.Action
    leftAnimTrack.Looped = false

    -- Load Right Punch Animation
    local rightAnim = Instance.new("Animation")
    rightAnim.AnimationId = "rbxassetid://913372543"
    rightAnimTrack = animator:LoadAnimation(rightAnim)
    rightAnimTrack.Priority = Enum.AnimationPriority.Action
    rightAnimTrack.Looped = false
end)

-- Direct Input Listener for 'E' Key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        print("E key pressed locally!")
        triggerCameraImpact()

        -- Alternate between left and right punch animations
        if useRightPunch then
            if rightAnimTrack then rightAnimTrack:Play() end
        else
            if leftAnimTrack then leftAnimTrack:Play() end
        end

        -- Fire server with the attack type and the current combo side boolean
        combatEvent:FireServer("LightPunch", useRightPunch)

        -- Toggle state for the next punch
        useRightPunch = not useRightPunch
    end
end)