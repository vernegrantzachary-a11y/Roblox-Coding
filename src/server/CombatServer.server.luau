print("--- COMBAT SERVER SCRIPT IS RUNNING ---")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local ProceduralPunch = require(SharedModules:WaitForChild("ProceduralPunch"))
local RigBuilder = require(SharedModules:WaitForChild("RigBuilder"))

-- Ensure RemoteEvent exists
local combatEvent = ReplicatedStorage:FindFirstChild("PerformAttackEvent") or Instance.new("RemoteEvent")
combatEvent.Name = "PerformAttackEvent"
combatEvent.Parent = ReplicatedStorage

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

-- Impact Effect
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
	emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 2.5)})
	emitter.Speed = NumberRange.new(10, 20)
	emitter.Lifetime = NumberRange.new(0.2, 0.4)
	emitter.Parent = attachment

	emitter:Emit(30)
	task.delay(0.5, function() effectPart:Destroy() end)
end

-- Visible Auto-Respawning Dummy
local function spawnTestDummy(spawnCFrame)
	local dummy = Instance.new("Model")
	dummy.Name = "TargetDummy"

	-- HumanoidRootPart
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.CFrame = spawnCFrame
	root.Anchored = true
	root.CanCollide = true
	root.Material = Enum.Material.SmoothPlastic
	root.Color = Color3.fromRGB(180, 50, 50) -- Bright Red so it stands out
	root.Parent = dummy

	-- Head
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.2, 1.2, 1.2)
	head.CFrame = root.CFrame * CFrame.new(0, 1.6, 0)
	head.Anchored = true
	head.Color = Color3.fromRGB(220, 220, 220)
	head.Parent = dummy

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 100
	humanoid.Health = 100
	humanoid.Parent = dummy

	dummy.PrimaryPart = root
	dummy.Parent = workspace

	RigBuilder.EnsureMotor6Ds(dummy)

	-- Respawn Listener
	humanoid.Died:Connect(function()
		print("[Dummy] TargetDummy defeated! Respawning in 2s...")
		task.wait(2)
		dummy:Destroy()
		spawnTestDummy(spawnCFrame)
	end)
end

-- Spawn dummy right in front of player character when loaded
local function onCharacterAdded(character)
	local root = character:WaitForChild("HumanoidRootPart", 5)
	if root then
		-- Spawns 6 studs directly in front at standing height
		local dummyPosition = root.CFrame * CFrame.new(0, 0, -6)
		spawnTestDummy(dummyPosition)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(onCharacterAdded)
end)

-- Combat Receiver with Expanded Hit Range
combatEvent.OnServerEvent:Connect(function(player, attackType, isRight)
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end

	local rootPart = character.HumanoidRootPart

	ProceduralPunch.Execute(character)

	local sideOffset = isRight and (rootPart.CFrame.RightVector * 1.2) or (rootPart.CFrame.RightVector * -1.2)
	local hitPos = rootPart.Position + (rootPart.CFrame.LookVector * 4) + sideOffset

	createPunchEffect(hitPos)
	playPunchSound(character)

	-- Hit Detection for Dummies (Expanded distance check to 12 studs)
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and (obj.Name == "TrainingDummy" or obj.Name == "TargetDummy") then
			local dummyRoot = obj:FindFirstChild("HumanoidRootPart")
			local dummyHumanoid = obj:FindFirstChildOfClass("Humanoid")

			if dummyRoot and dummyHumanoid then
				local distance = (rootPart.Position - dummyRoot.Position).Magnitude
				if distance <= 12 then
					dummyHumanoid:TakeDamage(25)
					print(string.format("[Hit System] Damaged %s! Health: %d/%d", obj.Name, dummyHumanoid.Health, dummyHumanoid.MaxHealth))
				end
			end
		end
	end
end)
