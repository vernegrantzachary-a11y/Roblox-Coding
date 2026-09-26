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
    print("Setting up rig for character:", character.Name)

    local humanoid = character:WaitForChild("Humanoid")
    local rigType = humanoid.RigType

    if rigType == Enum.HumanoidRigType.R6 then
        print("R6 rig detected")
        isR6 = true
        local torso = character:WaitForChild("Torso")
        rightShoulder = torso:WaitForChild("Right Shoulder")
        leftShoulder = torso:WaitForChild("Left Shoulder")
        print("R6 shoulders found")
    elseif rigType == Enum.HumanoidRigType.R15 then
        print("R15 rig detected")
        isR6 = false
        local upperTorso = character:WaitForChild("UpperTorso")
        rightShoulder = upperTorso:WaitForChild("RightShoulder")
        leftShoulder = upperTorso:WaitForChild("LeftShoulder")
        print("R15 shoulders found")
    else
        print("ERROR: Unknown rig type:", rigType)
    end
end

if player.Character then
    setupCombatRig(player.Character)
end
player.CharacterAdded:Connect(setupCombatRig)

local function playProceduralPunch(isRight)
    if isPunching then return end
    isPunching = true

    local shoulder = isRight and rightShoulder or leftShoulder
    local defaultCFrame = isR6 and (isRight and RIGHT_SHOULDER_DEFAULT_R6 or LEFT_SHOULDER_DEFAULT_R6) or (isRight and RIGHT_SHOULDER_DEFAULT_R15 or LEFT_SHOULDER_DEFAULT_R15)

    if not shoulder then
        print("ERROR: shoulder is nil, returning")
        isPunching = false
        return
    end

    -- Same punch angles work for both R6 and R15
    local windupCFrame = defaultCFrame * CFrame.Angles(math.rad(-20), 0, math.rad(isRight and 10 or -10))
    local punchCFrame = defaultCFrame * CFrame.Angles(math.rad(-160), 0, 0)

    local windupTween = TweenService:Create(shoulder, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C0 = windupCFrame})
    local punchTween = TweenService:Create(shoulder, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C0 = punchCFrame})
    local returnTween = TweenService:Create(shoulder, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {C0 = defaultCFrame})

    windupTween:Play()
    windupTween.Completed:Wait()
    punchTween:Play()
    punchTween.Completed:Wait()
    returnTween:Play()

    isPunching = false
end

local function playPunchSound()
    local char = player.Character
    if not char then return end
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://112568860476160"
    sound.Volume = 0.5
    sound.Parent = char:FindFirstChild("HumanoidRootPart") or char
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.E then
        triggerCameraImpact()
        task.spawn(playProceduralPunch, useRightPunch)
        task.spawn(playPunchSound)
        combatEvent:FireServer("LightPunch", useRightPunch)
        useRightPunch = not useRightPunch
    end
end)

print("CombatClient loaded and ready for R6 or R15")