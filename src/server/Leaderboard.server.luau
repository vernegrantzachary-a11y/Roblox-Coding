local Players = game:GetService("Players")

local function onPlayerAdded(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local kills = Instance.new("IntValue")
    kills.Name = "Kills"
    kills.Value = 0
    kills.Parent = leaderstats

    local streak = Instance.new("IntValue")
    streak.Name = "Streak"
    streak.Value = 0
    streak.Parent = leaderstats
end

Players.PlayerAdded:Connect(onPlayerAdded)
-- Force update check
