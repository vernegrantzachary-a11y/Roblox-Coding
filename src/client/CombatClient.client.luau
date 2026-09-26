-- src/Client/CombatClient.client.luau
print("--- COMBAT CLIENT SCRIPT IS RUNNING ---")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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

RunService:BindToRenderStep("CombatCameraShake", Enum.RenderPriority.Camera.Value + 1, function(dt)
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

-- Adaptive Punch Setup (R6 or R15 auto-detect)
local rightShoulder: Motor6D = nil
local leftShoulder: Motor6D = nil
local useRightPunch = false
local isPunching = false
local isR6 = false

local RIGHT_SHOULDER_DEFAULT_R6 = CFrame.new(1, 0.5, 0)
local LEFT_SHOULDER_DEFAULT_R6 = CFrame.new(-1, 0.5, 0)
local RIGHT_SHOULDER_DEFAULT_R15 = CFrame.new(0.5, 0, 0)
local LEFT_SHOULDER_DEFAULT_R15 = CFrame.new(-0.5, 0, 0)

local function