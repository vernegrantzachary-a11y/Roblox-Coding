-- src/Client/CombatClient.client.luau
print("--- COMBAT CLIENT SCRIPT IS RUNNING ---")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- IMPORTANT: only WAIT for the RemoteEvent here. Never create it on the client —
-- an Instance.new() on a LocalScript is local-only and does NOT replicate to the
-- server.
local combatEvent = ReplicatedStorage:WaitForChild("PerformAttackEvent")

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

local function setupCombatRig(character)
    print("Character children:", character:GetChildren())
    print("Setting up rig for character:", character.Name)

    -- Try R6 first (look for Torso)
    local torso = character:FindFirstChild("Torso")
    if torso then
        print("R6 rig detected")
        isR6 = true
        rightShoulder = torso:WaitForChild("Right Shoulder")
        leftShoulder = torso:WaitForChild("Left Shoulder")
        print("R6 shoulders found")
        return
    end

    -- Fall back to R15 (look for UpperTorso)
    local upperTorso = character:FindFirstChild("UpperTorso")
    if upperTorso then
        print("R15 rig detected")
        isR6 = false
        rightShoulder = upperTorso:WaitForChild("RightShoulder")
        leftShoulder = upperTorso:WaitForChild("LeftShoulder")
        print("R15 shoulders found")
        return
    end

    print("ERROR: Neither R6 Torso nor R15 UpperTorso found!")
end

if player.Character then
    setupCombatRig(player.Character)
end
player.CharacterAdded:Connect(setupCombatRig)

local function