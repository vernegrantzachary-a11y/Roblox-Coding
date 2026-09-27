local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local dummyModel = ReplicatedStorage:WaitForChild("Dummy")

-- Clone the dummy and place it near the spawn point
local clonedDummy = dummyModel:Clone()
clonedDummy:PivotTo(CFrame.new(5, 3, 5))
clonedDummy.Parent = Workspace
