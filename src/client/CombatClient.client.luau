-- src/Client/CombatClient.client.luau
print("--- COMBAT CLIENT SCRIPT IS RUNNING ---")
print("CLIENT SCRIPT LOADED AND RUNNING")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local camera = workspace.CurrentCamera

-- Ensure RemoteEvent exists
local combatEvent = ReplicatedStorage:FindFirstChild("PerformAttackEvent")
if not combatEvent then
    combatEvent = Instance.new("RemoteEvent")
    combatEvent.Name = "PerformAttackEvent"
    combatEvent.Parent = ReplicatedStorage
end

-- Camera Shake Variables
local shakeIntensity = 0
local shakeDuration = 0
local shakeTimer = 0

local function triggerCameraImpact()
    shakeIntensity = 1.2
    shakeDuration = 0.2
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

-- Direct Input Listener for 'E' Key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        print("E key pressed locally!")
        triggerCameraImpact()
        combatEvent:FireServer("LightPunch")
    end
end)