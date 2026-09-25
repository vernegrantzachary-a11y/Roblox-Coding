-- src/Client/CombatClient.client.luau
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Ensure RemoteEvent exists
local combatEvent = ReplicatedStorage:FindFirstChild("PerformAttackEvent")
if not combatEvent then
    combatEvent = Instance.new("RemoteEvent")
    combatEvent.Name = "PerformAttackEvent"
    combatEvent.Parent = ReplicatedStorage
end

-- Camera Shake / Impact State Variables
local shakeIntensity = 0
local shakeDuration = 0
local shakeTimer = 0

local function triggerCameraImpact()
    shakeIntensity = 1.2 -- Adjust magnitude of the punch impact
    shakeDuration = 0.2  -- Short, snappy duration
    shakeTimer = shakeDuration
end

-- Camera Shake Frame Update
RunService.RenderStepped:Connect(function(dt)
    if shakeTimer > 0 then
        shakeTimer = shakeTimer - dt
        local currentIntensity = shakeIntensity * (shakeTimer / shakeDuration)
        local randomOffset = Vector3.new(
            math.fmod(math.random(), 2) - 1,
            math.fmod(math.random(), 2) - 1,
            0
        ) * currentIntensity
        
        camera.CFrame = camera.CFrame * CFrame.Angles(randomOffset.X * 0.05, randomOffset.Y * 0.05, 0)
    end
end)

-- Core Attack Trigger Function
local function executePunch()
    triggerCameraImpact()
    combatEvent:FireServer("LightPunch")
end

-- Cross-Platform Action Binding ("E" on Keyboard, "X" on Xbox, "Square" on PS, Mobile Button)
local actionName = "PunchAction"

local function handleAction(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin then
        executePunch()
    end
end

-- Bind inputs for keyboard, gamepad, and automatically generate a mobile touch button
ContextActionService:BindActionAtPriority(
    actionName,
    handleAction,
    true, -- Creates a mobile button on screen!
    Enum.ContextActionPriority.High.Value,
    Enum.KeyCode.E,         -- Keyboard
    Enum.KeyCode.ButtonX,   -- Xbox controller
    Enum.KeyCode.ButtonSquare -- PlayStation controller
)

-- Set a clean title for the mobile button
ContextActionService:SetTitle(actionName, "Punch")