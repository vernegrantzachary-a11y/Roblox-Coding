-- src/Client/CombatClient.client.luau
print("--- COMBAT CLIENT SCRIPT IS RUNNING ---")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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

-- Punch Animation Setup (replaces old Motor6D-tweening approach, which
-- doesn't work on this character's custom UGC rig)
local useRightPunch = false
local punchTrack = nil

-- TODO: replace this with the real AnimationId pulled from the R15 punch pack
local PUNCH_ANIMATION_ID = "rbxassetid://PASTE_REAL_ID_HERE"

local function setupPunchAnimation(character)
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")

    local punchAnim = Instance.new("Animation")
    punchAnim.AnimationId = PUNCH_ANIMATION_ID

    punchTrack = animator:LoadAnimation(punchAnim)
    punchTrack.Priority = Enum.AnimationPriority.Action4
end

if player.Character then
    setupPunchAnimation(player.Character)
end
player.CharacterAdded:Connect(setupPunchAnimation)

-- ContextActionService binds both a PC keybind (E) AND an automatic
-- on-screen touch button on mobile, so punching works on both platforms
-- with one binding. Punch sound is now handled server-side (in
-- CombatServer.server.luau) so it replicates and everyone can hear it.
local function handlePunchAction(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin then
        triggerCameraImpact()
        if punchTrack then
            punchTrack:Play()
        end
        combatEvent:FireServer("LightPunch", useRightPunch)
        useRightPunch = not useRightPunch
    end
end

ContextActionService:BindAction("PunchAction", handlePunchAction, true, Enum.KeyCode.E)

print("CombatClient loaded and ready")