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

-- Procedural Punch Setup
local rightShoulder: Motor6D = nil
local leftShoulder: Motor6D = nil
local useRightPunch = false
local isPunching = false

local RIGHT_SHOULDER_DEFAULT = CFrame.new(1, 0.5, 0)
local LEFT_SHOULDER_DEFAULT = CFrame.new(-1, 0.5, 0)

local function setupCombatRig(character)
    print("setupCombatRig called for", character.Name)
    local torso = character:WaitForChild("Torso")
    print("Torso found:", torso)
    rightShoulder = torso:WaitForChild("Right Shoulder")
    leftShoulder = torso:WaitForChild("Left Shoulder")
    print("Shoulders set. Right:", rightShoulder, "Left:", leftShoulder)
end

if player.Character then
    setupCombatRig(player.Character)
end
player.CharacterAdded:Connect(setupCombatRig)

local function playProceduralPunch(isRight)
    print("playProceduralPunch called, isRight:", isRight)
    if isPunching then 
        print("Already punching, returning")
        return 
    end
    isPunching = true

    local shoulder = isRight and rightShoulder or leftShoulder
    local defaultCFrame = isRight and RIGHT_SHOULDER_DEFAULT or LEFT_SHOULDER_DEFAULT
    print("shoulder reference:", shoulder, "defaultCFrame:", defaultCFrame)
    if not shoulder then
        print("ERROR: shoulder is nil, returning")
        isPunching = false
        return
    end

    local windupCFrame = defaultCFrame * CFrame.Angles(math.rad(-20), 0, math.rad(isRight and 10 or -10))
    local punchCFrame = defaultCFrame * CFrame.Angles(math.rad(-160), 0, 0)

    print("Creating tweens...")
    local windupTween = TweenService:Create(shoulder, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C0 = windupCFrame})
    local punchTween = TweenService:Create(shoulder, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C0 = punchCFrame})
    local returnTween = TweenService:Create(shoulder, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {C0 = defaultCFrame})

    windupTween:Play()
    windupTween.Completed:Wait()
    punchTween:Play()
    punchTween.Completed:Wait()
    returnTween:Play()

    print("Punch animation complete")
    isPunching = false
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.E then
        print("E key pressed locally!")
        triggerCameraImpact()
        task.spawn(playProceduralPunch, useRightPunch)
        combatEvent:FireServer("LightPunch", useRightPunch)
        useRightPunch = not useRightPunch
    end
end)

print("CombatClient fully loaded. Shoulders at startup:", rightShoulder, leftShoulder)