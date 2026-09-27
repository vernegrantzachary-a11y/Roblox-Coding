print("--- COMBAT SERVER SCRIPT IS RUNNING ---")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local ProceduralPunch = require(SharedModules:WaitForChild("ProceduralPunch"))
local RigBuilder = require(SharedModules:WaitForChild("RigBuilder"))

-- TEMP: run once to discover animation IDs inside the punch pack model
local InsertService = game:GetService("InsertService")

local success, model = pcall(function()
	return InsertService:LoadAsset(1206194659)
end)

if success and model then
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("Animation") then
			print("Found Animation:", descendant.Name, "-", descendant.AnimationId)
		end
	end
	model:Destroy()
else
	warn("Failed to load asset:", model)
end
-- END TEMP BLOCK

-- Ensure RemoteEvent exists
local combatEvent = ReplicatedStorage:FindFirstChild("PerformAttackEvent")
if not combatEvent then
	combatEvent = Instance.new("RemoteEvent")
	combatEvent.Name = "PerformAttackEvent"
	combatEvent.Parent = ReplicatedStorage
end

-- Server Audio
local function playPunchSound(character)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://112568860476160"
	sound.Volume = 0.5
	sound.Parent = rootPart
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 2)
end

-- Anime Particle Impact Burst
local function createPunchEffect(targetPosition)
	local effectPart = Instance.new("Part")
	effectPart.Size = Vector3.new(1, 1, 1)
	effectPart.Transparency = 1
	effectPart.Anchored = true
	effectPart.CanCollide = false
	effectPart.Position = targetPosition
	effectPart.Parent = workspace

	local attachment = Instance.new("Attachment")
	attachment.Parent = effectPart

	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxassetid://1084889503"
	emitter.Color = ColorSequence.new(Color3.fromRGB(0, 255, 120), Color3.fromRGB(0, 150, 255))
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(1, 2.5)
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 1)
	})
	emitter.Speed = NumberRange.new(10, 20)
	emitter.SpreadAngle = Vector2.new(60, 60)
	emitter.Lifetime = NumberRange.new(0.2, 0.4)
	emitter.Rate = 0
	emitter.Parent = attachment

	emitter:Emit(30)

	task.delay(0.5, function()
		effectPart:Destroy()
	end)
end

-- Auto-Respawning Dummy Logic
local function spawnTestDummy(spawnCFrame)
	local dummy = Instance.new("Model")
	dummy.Name = "TargetDummy"

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.CFrame = spawnCFrame
	root.Anchored = true
	root.Parent = dummy

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.CFrame = root.CFrame
	torso.Parent = dummy

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 100
	humanoid.Health = 100
	humanoid.Parent = dummy

	dummy.PrimaryPart = root
	dummy.Parent = workspace

	RigBuilder.EnsureMotor6Ds(dummy)

	humanoid.Died:Connect(function()
		task.wait(2)
		dummy:Destroy()
		spawnTestDummy(spawnCFrame)
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local root = character:WaitForChild("HumanoidRootPart", 5)
		if root then
			spawnTestDummy(root.CFrame * CFrame.new(0, 0, -6))
		end
	end)
end)

-- Main Attack Handler
combatEvent.OnServerEvent:Connect(function(player, attackType, isRight)
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end

	local rootPart = character.HumanoidRootPart

	-- Execute server-replicated procedural Motor6D punch
	ProceduralPunch.Execute(character)

	-- Offset particle impact point
	local sideOffset = isRight and (rootPart.CFrame.RightVector * 1.2) or (rootPart.CFrame.RightVector * -1.2)
	local hitPos = rootPart.Position + (rootPart.CFrame.LookVector * 4) + sideOffset

	createPunchEffect(hitPos)
	playPunchSound(character)

	-- Hit Detection: Other Players
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Character then
			local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
			local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")

			if otherRoot and humanoid then
				local distance = (rootPart.Position - otherRoot.Position).Magnitude
				if distance <= 8 then
					humanoid:TakeDamage(10)
					print(player.Name .. " successfully punched " .. otherPlayer.Name)
				end
			end
		end
	end

	-- Hit Detection: Training / Target Dummies
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and (obj.Name == "TrainingDummy" or obj.Name == "TargetDummy") then
			local dummyRoot = obj:FindFirstChild("HumanoidRootPart")
			local dummyHumanoid = obj:FindFirstChildOfClass("Humanoid")

			if dummyRoot and dummyHumanoid then
				local distance = (rootPart.Position - dummyRoot.Position).Magnitude
				if distance <= 8 then
					dummyHumanoid:TakeDamage(10)
					print(player.Name .. " successfully punched " .. obj.Name)
				end
			end
		end
	end
end)
