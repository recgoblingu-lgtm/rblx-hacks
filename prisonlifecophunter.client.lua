local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- CONFIGURATION
local TOGGLE_KEY = Enum.KeyCode.P        -- Switched to P key
local POLICE_TEAM = "Bright blue"
_G.HuntingActive = false 

-- 1. VISUAL INTERFACE (UI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PoliceHunterHubP"
ScreenGui.ResetOnSpawn = false

local success, _ = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 60)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 2
MainFrame.Parent = ScreenGui

local StatusIndicator = Instance.new("Frame")
StatusIndicator.Size = UDim2.new(0, 15, 1, 0)
StatusIndicator.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
StatusIndicator.BorderSizePixel = 0
StatusIndicator.Parent = MainFrame

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -25, 1, 0)
InfoLabel.Position = UDim2.new(0, 20, 0, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "POLICE HUNTER: OFF\nPress [P] to Toggle"
InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoLabel.Font = Enum.Font.SourceSansBold
InfoLabel.TextSize = 14
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.Parent = MainFrame

-- 2. TARGET SELECTION FUNCTION
local function findTargetCop()
    local closestCop = nil
    local shortestDistance = math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.TeamColor.Name == POLICE_TEAM and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local distance = (myRoot.Position - targetRoot.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestCop = player
                end
            end
        end
    end
    return closestCop
end

-- 3. AUTOMATED COMBAT LOOP
local trackingLoop
trackingLoop = RunService.Heartbeat:Connect(function()
    if not _G.HuntingActive then return end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local targetCop = findTargetCop()
    if targetCop and targetCop.Character then
        local targetRoot = targetCop.Character:FindFirstChild("HumanoidRootPart")
        local targetHead = targetCop.Character:FindFirstChild("Head")
        
        if targetRoot and targetHead then
            -- Teleport 3 studs behind them
            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3) 
            
            -- Lock camera
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
            
            -- Autoshoot (requires holding a weapon)
            local activeTool = myChar:FindFirstChildOfClass("Tool")
            local shootEvent = Workspace:FindFirstChild("Remote") and Workspace.Remote:FindFirstChild("ShootEvent")
            
            if activeTool and shootEvent then
                shootEvent:FireServer({
                    {
                        RayObject = Ray.new(myRoot.Position, (targetHead.Position - myRoot.Position).Unit),
                        Distance = (targetHead.Position - myRoot.Position).Magnitude,
                        Cframe = targetHead.CFrame,
                        Hit = targetHead
                    }
                }, activeTool)
            end
        end
    end
end)

-- 4. INPUT CONTROLLER (P KEY BIND)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- gameProcessed keeps it from toggling while typing messages containing "P" in chat
    if gameProcessed then return end
    
    if input.KeyCode == TOGGLE_KEY then
        _G.HuntingActive = not _G.HuntingActive
        
        if _G.HuntingActive then
            StatusIndicator.BackgroundColor3 = Color3.fromRGB(75, 255, 75) -- Green
            InfoLabel.Text = "POLICE HUNTER: ACTIVE\nPress [P] to Stop"
        else
            StatusIndicator.BackgroundColor3 = Color3.fromRGB(255, 75, 75) -- Red
            InfoLabel.Text = "POLICE HUNTER: OFF\nPress [P] to Toggle"
        end
    end
end)
