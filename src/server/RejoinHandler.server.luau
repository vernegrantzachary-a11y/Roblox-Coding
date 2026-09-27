local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local rejoinEvent = ReplicatedStorage:WaitForChild("RejoinEvent", 10)
if not rejoinEvent then
	rejoinEvent = Instance.new("RemoteEvent")
	rejoinEvent.Name = "RejoinEvent"
	rejoinEvent.Parent = ReplicatedStorage
end

rejoinEvent.OnServerEvent:Connect(function(player)
	TeleportService:Teleport(game.PlaceId, player)
end)
