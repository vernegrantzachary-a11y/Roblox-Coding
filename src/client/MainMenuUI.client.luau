-- src/Client/MainMenuUI.client.luau
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ScreenGui container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainMenuUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Bottom-left holder frame for the menu buttons
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuBar"
menuFrame.AnchorPoint = Vector2.new(0, 1)
menuFrame.Position = UDim2.new(0, 20, 1, -20)
menuFrame.Size = UDim2.new(0, 320, 0, 50)
menuFrame.BackgroundTransparency = 1
menuFrame.Parent = screenGui

-- Lay buttons out left-to-right with even spacing
local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = menuFrame

local BUTTON_NAMES = {"Kits", "Avatar", "Settings", "Codes"}

-- Placeholder callbacks — wire these up to your actual menus later
local function onMenuButtonClicked(name)
    print("Menu button clicked:", name)
    -- TODO: e.g. if name == "Kits" then openKitsMenu() end
end

for _, name in ipairs(BUTTON_NAMES) do
    local button = Instance.new("TextButton")
    button.Name = name .. "Button"
    button.Size = UDim2.new(0, 70, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = menuFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    button.MouseButton1Click:Connect(function()
        onMenuButtonClicked(name)
    end)
end