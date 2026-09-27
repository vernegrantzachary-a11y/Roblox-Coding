local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local rejoinEvent = ReplicatedStorage:FindFirstChild("RejoinEvent")
if not rejoinEvent then
	rejoinEvent = Instance.new("RemoteEvent")
	rejoinEvent.Name = "RejoinEvent"
	rejoinEvent.Parent = ReplicatedStorage
end

rejoinEvent.OnServerEvent:Connect(function(player)
	local placeId = game.PlaceId
	
	if placeId == 0 then
		warn("[DevRejoin] Invalid PlaceId (0). Teleport canceled.")
		return
	end

	print(string.format("[DevRejoin] Teleporting %s to PlaceId: %d...", player.Name, placeId))

	local success, err = pcall(function()
		TeleportService:Teleport(placeId, player)
	end)

	if not success then
		warn("[DevRejoin] Teleport failed with error: " .. tostring(err))
	end
end)
