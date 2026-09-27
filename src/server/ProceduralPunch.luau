local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local RigBuilder = require(SharedModules:WaitForChild("RigBuilder"))
local AnimationController = require(SharedModules:WaitForChild("AnimationController"))

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(1)

		RigBuilder.EnsureMotor6Ds(character)

		local rightArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
		local shoulder = rightArm and rightArm:FindFirstChildOfClass("Motor6D")

		if shoulder then
			local originalC0 = shoulder.C0
			local activeOverride = true
			local punchProgress = 0

			-- Pause standard walk/idle tracks during the move
			AnimationController.SetBaseAnimationsEnabled(character, false)

			local connection
			connection = RunService.Stepped:Connect(function()
				if not activeOverride or not shoulder.Parent then
					connection:Disconnect()
					return
				end

				shoulder.C0 = originalC0 * CFrame.new(0, 0, -punchProgress * 2) * CFrame.Angles(math.rad(90 * punchProgress), 0, 0)
			end)

			task.spawn(function()
				for i = 0, 1, 0.1 do
					punchProgress = i
					task.wait(0.02)
				end

				task.wait(0.2)

				-- Reset joint and resume standard animations
				punchProgress = 0
				activeOverride = false
				shoulder.C0 = originalC0
				AnimationController.SetBaseAnimationsEnabled(character, true)
			end)
		end
	end)
end)
