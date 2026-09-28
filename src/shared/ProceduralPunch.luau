local RunService = game:GetService("RunService")

local ProceduralPunch = {}

function ProceduralPunch.Execute(character: Model)
	local rightUpperArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
	if not rightUpperArm then return end

	local shoulder = rightUpperArm:FindFirstChild("RightShoulder") 
		or rightUpperArm:FindFirstChildOfClass("Motor6D") 
		or (character:FindFirstChild("Torso") and character.Torso:FindFirstChild("Right Shoulder"))

	if not shoulder then return end

	local originalC0 = shoulder.C0
	local punchProgress = 0
	local activeOverride = true

	local stepConnection
	stepConnection = RunService.RenderStepped:Connect(function()
		if not activeOverride or not shoulder.Parent then
			stepConnection:Disconnect()
			return
		end
		
		shoulder.C0 = originalC0 
			* CFrame.new(0, 0, -punchProgress * 2) 
			* CFrame.Angles(math.rad(90 * punchProgress), math.rad(-20 * punchProgress), 0)
	end)

	task.spawn(function()
		for i = 0, 1, 0.2 do
			punchProgress = i
			task.wait(0.01)
		end
		
		task.wait(0.05)

		for i = 1, 0, -0.2 do
			punchProgress = i
			task.wait(0.01)
		end

		activeOverride = false
		shoulder.C0 = originalC0
	end)
end

return ProceduralPunch
