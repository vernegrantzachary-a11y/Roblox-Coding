local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local rejoinEvent = ReplicatedStorage:FindFirstChild("RejoinEvent") or Instance.new("RemoteEvent")
rejoinEvent.Name = "RejoinEvent"
rejoinEvent.Parent = ReplicatedStorage

-- Press F8 to trigger instant rejoin
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.F8 then
		print("Rejoin key pressed. Transferring to fresh server...")
		rejoinEvent:FireServer()
	end
end)
