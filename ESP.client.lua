-- OwnerESP.lua  (ONE file, nothing else needed)
-- TYPE: LocalScript
-- PUT IT IN: StarterPlayer > StarterPlayerScripts
--
-- Builds its own UI and only turns on for the game owner.
-- Press P to show/hide the panel.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

---------------------------------------------------------------------
-- Owner check
---------------------------------------------------------------------

-- Extra user IDs allowed to use it. Put YOUR UserId here for Studio testing
-- (unsaved places have no creator, so the automatic check fails there).
local EXTRA_OWNER_IDS = {
	2349227107,
}

local function isOwner()
	if table.find(EXTRA_OWNER_IDS, localPlayer.UserId) then
		return true
	end
	if game.CreatorType == Enum.CreatorType.User then
		return localPlayer.UserId == game.CreatorId
	elseif game.CreatorType == Enum.CreatorType.Group then
		local ok, rank = pcall(function()
			return localPlayer:GetRankInGroup(game.CreatorId)
		end)
		return ok and rank == 255
	end
	return false
end

if not isOwner() then
	return -- everyone else: script does nothing
end

local TOGGLE_KEY = Enum.KeyCode.P
local FALLBACK_COLOR = Color3.fromRGB(255, 60, 60)

local settings = {
	Enabled = true,
	Highlight = true,
	Box = true,
	Names = true,
	TeamColors = false,
}

local ESP_NAME = "OwnerESP"

---------------------------------------------------------------------
-- ESP logic
---------------------------------------------------------------------

local function getColor(player)
	if settings.TeamColors and player.Team then
		return player.TeamColor.Color
	end
	return FALLBACK_COLOR
end

local function removeESP(character)
	local old = character and character:FindFirstChild(ESP_NAME)
	if old then
		old:Destroy()
	end
end

local function applyESP(player)
	if player == localPlayer then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	removeESP(character)

	if not settings.Enabled then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local color = getColor(player)

	local folder = Instance.new("Folder")
	folder.Name = ESP_NAME

	-- Glowing outline / fill on the whole character
	if settings.Highlight then
		local highlight = Instance.new("Highlight")
		highlight.Adornee = character
		highlight.FillColor = color
		highlight.FillTransparency = 0.6
		highlight.OutlineColor = color
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = folder
	end

	-- Box + name tag
	if settings.Box or settings.Names then
		local billboard = Instance.new("BillboardGui")
		billboard.Adornee = root
		billboard.AlwaysOnTop = true
		billboard.Size = UDim2.new(4.5, 0, 6.5, 0) -- studs, so it scales with distance
		billboard.SizeOffset = Vector2.new(0, 0)
		billboard.ResetOnSpawn = false
		billboard.Parent = folder

		if settings.Box then
			local box = Instance.new("Frame")
			box.Size = UDim2.fromScale(1, 1)
			box.BackgroundTransparency = 1
			box.BorderSizePixel = 0
			box.Parent = billboard

			local stroke = Instance.new("UIStroke")
			stroke.Color = color
			stroke.Thickness = 2
			stroke.Parent = box
		end

		if settings.Names then
			local label = Instance.new("TextLabel")
			label.AnchorPoint = Vector2.new(0.5, 1)
			label.Position = UDim2.new(0.5, 0, 0, -2)
			label.Size = UDim2.new(1.6, 0, 0, 18)
			label.BackgroundTransparency = 1
			label.Text = player.DisplayName .. " (@" .. player.Name .. ")"
			label.TextColor3 = color
			label.TextStrokeTransparency = 0.4
			label.Font = Enum.Font.GothamBold
			label.TextSize = 14
			label.Parent = billboard
		end
	end

	folder.Parent = character
end

local function refreshAll()
	for _, player in ipairs(Players:GetPlayers()) do
		applyESP(player)
	end
end

local function hookPlayer(player)
	if player == localPlayer then
		return
	end
	player.CharacterAdded:Connect(function()
		task.wait(0.5) -- let the character finish loading
		applyESP(player)
	end)
	if player.Character then
		applyESP(player)
	end
end

Players.PlayerAdded:Connect(hookPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	hookPlayer(player)
end

---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OwnerESPGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(210, 230)
panel.Position = UDim2.new(0, 20, 0.5, -115)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = screenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 34)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.BorderSizePixel = 0
title.Text = "Owner ESP  (P = hide)"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = panel
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local list = Instance.new("Frame")
list.Position = UDim2.fromOffset(0, 40)
list.Size = UDim2.new(1, 0, 1, -40)
list.BackgroundTransparency = 1
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = list

local ON_COLOR = Color3.fromRGB(60, 170, 90)
local OFF_COLOR = Color3.fromRGB(150, 55, 55)

local function makeToggle(labelText, key)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 30)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.TextColor3 = Color3.new(1, 1, 1)
	button.AutoButtonColor = true
	button.Parent = list
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

	local function render()
		button.Text = labelText .. ": " .. (settings[key] and "ON" or "OFF")
		button.BackgroundColor3 = settings[key] and ON_COLOR or OFF_COLOR
	end

	button.MouseButton1Click:Connect(function()
		settings[key] = not settings[key]
		render()
		refreshAll()
	end)

	render()
end

makeToggle("ESP", "Enabled")
makeToggle("Highlight", "Highlight")
makeToggle("Box", "Box")
makeToggle("Names", "Names")
makeToggle("Team Colors", "TeamColors")

-- Dragging the panel by its title bar
do
	local dragging, dragStart, startPos

	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = panel.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			panel.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- Show/hide panel with a key
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == TOGGLE_KEY then
		panel.Visible = not panel.Visible
	end
end)
