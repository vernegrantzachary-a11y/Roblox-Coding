print("--- COMBAT CLIENT SCRIPT IS RUNNING ---")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- RemoteEvent for server communication
local combatEvent = ReplicatedStorage:WaitForChild("PerformAttackEvent")

-- Shared modules for procedural limb manipulation
local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local ProceduralPunch = require(SharedModules:WaitForChild("ProceduralPunch"))

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

local useRightPunch = false

-- ContextActionService binding (PC keybind 'E' and Mobile Button)
local function handlePunchAction(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		local character = player.Character
		if character then
			-- Execute procedural Motor6D override locally for zero latency
			ProceduralPunch.Execute(character)
		end

		triggerCameraImpact()
		combatEvent:FireServer("LightPunch", useRightPunch)
		useRightPunch = not useRightPunch
	end
end

ContextActionService:BindAction("PunchAction", handlePunchAction, true, Enum.KeyCode.E)

-- Configure Mobile UI Touch Button
ContextActionService:SetTitle("PunchAction", "Punch")
ContextActionService:SetPosition("PunchAction", UDim2.new(1, -200, 1, -120))

print("CombatClient loaded and ready with procedural override")
