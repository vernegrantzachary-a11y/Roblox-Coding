local RunService = game:GetService("RunService")

local ProceduralPunch = {}

function ProceduralPunch.Execute(character: Model)
	local rightArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
	local shoulder = rightArm and rightArm:FindFirstChildOfClass("Motor6D")

	if not shoulder then return end

	local originalC0 = shoulder.C0
	local punchProgress = 0
	local activeOverride = true

	local connection
	connection = RunService.Stepped:Connect(function()
		if not activeOverride or not shoulder.Parent then
			connection:Disconnect()
			return
		end
		shoulder.C0 = originalC0 * CFrame.new(0, 0, -punchProgress * 2.5) * CFrame.Angles(math.rad(90 * punchProgress), 0, 0)
	end)

	task.spawn(function()
		for i = 0, 1, 0.15 do
			punchProgress = i
			task.wait(0.01)
		end
		task.wait(0.1)
		for i = 1, 0, -0.15 do
			punchProgress = i
			task.wait(0.01)
		end

		activeOverride = false
		shoulder.C0 = originalC0
	end)
end

return ProceduralPunch
