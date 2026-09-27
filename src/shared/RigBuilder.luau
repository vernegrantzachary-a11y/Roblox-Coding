local RigBuilder = {}

-- Standard R15 Joint Map
local R15_JOINTS = {
	{ "HumanoidRootPart", "LowerTorso", "RootRigAttachment", "Root" },
	{ "LowerTorso", "UpperTorso", "WaistRigAttachment", "Waist" },
	{ "UpperTorso", "Head", "NeckRigAttachment", "Neck" },
	{ "UpperTorso", "LeftUpperArm", "LeftShoulderRigAttachment", "LeftShoulder" },
	{ "UpperTorso", "RightUpperArm", "RightShoulderRigAttachment", "RightShoulder" },
	{ "LeftUpperArm", "LeftLowerArm", "LeftElbowRigAttachment", "LeftElbow" },
	{ "LeftLowerArm", "LeftHand", "LeftWristRigAttachment", "LeftWrist" },
	{ "RightUpperArm", "RightLowerArm", "RightElbowRigAttachment", "RightElbow" },
	{ "RightLowerArm", "RightHand", "RightWristRigAttachment", "RightWrist" },
	{ "LowerTorso", "LeftUpperLeg", "LeftHipRigAttachment", "LeftHip" },
	{ "LeftUpperLeg", "LeftLowerLeg", "LeftKneeRigAttachment", "LeftKnee" },
	{ "LeftLowerLeg", "LeftFoot", "LeftAnkleRigAttachment", "LeftAnkle" },
	{ "LowerTorso", "RightUpperLeg", "RightHipRigAttachment", "RightHip" },
	{ "RightUpperLeg", "RightLowerLeg", "RightKneeRigAttachment", "RightKnee" },
	{ "RightLowerLeg", "RightFoot", "RightAnkleRigAttachment", "RightAnkle" },
}

-- Classic R6 Joint Map
local R6_JOINTS = {
	{ "HumanoidRootPart", "Torso", "RootAttachment", "RootJoint" },
	{ "Torso", "Head", "NeckAttachment", "Neck" },
	{ "Torso", "Left Arm", "LeftShoulderAttachment", "Left Shoulder" },
	{ "Torso", "Right Arm", "RightShoulderAttachment", "Right Shoulder" },
	{ "Torso", "Left Leg", "LeftHipAttachment", "Left Hip" },
	{ "Torso", "Right Leg", "RightHipAttachment", "Right Hip" },
}

local function applyJoints(character: Model, jointTable)
	for _, jointData in ipairs(jointTable) do
		local part0Name, part1Name, attachmentName, jointName = jointData[1], jointData[2], jointData[3], jointData[4]
		
		local part0 = character:FindFirstChild(part0Name) :: BasePart
		local part1 = character:FindFirstChild(part1Name) :: BasePart

		if part0 and part1 then
			local existingMotor = part1:FindFirstChildOfClass("Motor6D") or part0:FindFirstChild(jointName)
			
			if not existingMotor then
				local attachment0 = part0:FindFirstChild(attachmentName) :: Attachment
				local attachment1 = part1:FindFirstChild(attachmentName) :: Attachment

				local motor = Instance.new("Motor6D")
				motor.Name = jointName
				motor.Part0 = part0
				motor.Part1 = part1

				if attachment0 and attachment1 then
					motor.C0 = attachment0.CFrame
					motor.C1 = attachment1.CFrame
				else
					motor.C0 = part0.CFrame:ToObjectSpace(part1.CFrame)
				end

				motor.Parent = part1
			end
		end
	end
end

function RigBuilder.EnsureMotor6Ds(character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	
	-- Detect R6 vs R15 rig type automatically
	if humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 then
		applyJoints(character, R6_JOINTS)
	else
		applyJoints(character, R15_JOINTS)
	end
	
	-- Fallback check for any unjointed BaseParts in custom models
	local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	if root then
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("BasePart") and child ~= root and not child:FindFirstChildOfClass("Motor6D") and not child:FindFirstChildOfClass("Weld") then
				local motor = Instance.new("Motor6D")
				motor.Name = child.Name .. "Joint"
				motor.Part0 = root
				motor.Part1 = child
				motor.C0 = root.CFrame:ToObjectSpace(child.CFrame)
				motor.Parent = child
			end
		end
	end
end

return RigBuilder