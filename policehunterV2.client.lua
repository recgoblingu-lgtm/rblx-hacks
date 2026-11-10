-- PRISON LIFE POLICE HUNTER + AUTO-GUN GENERATOR V3
-- Toggles on and off with the P key

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local TOGGLE_KEY = Enum.KeyCode.P        
local POLICE_TEAM = "Bright blue"
_G.HunterLoopActive = false 

-- 1. STYLIZED OVERLAY (UI Canvas)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExterminatorEngineV3"
ScreenGui.ResetOnSpawn = false

local success, _ = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 60)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 2
MainFrame.Parent = ScreenGui

local IndicatorBar = Instance.new("Frame")
IndicatorBar.Size = UDim2.new(0, 12, 1, 0)
IndicatorBar.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- Starts Disabled (Red)
IndicatorBar.BorderSizePixel = 0
IndicatorBar.Parent = MainFrame

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -20, 1, 0)
StatusText.Position = UDim2.new(0, 20, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "SYSTEM ENGINE: PAUSED\nPress [P] to Fire Matrix"
StatusText.TextColor3 = Color3.fromRGB(240, 240, 240)
StatusText.Font = Enum.Font.Code
StatusText.TextSize = 13
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = MainFrame

-- 2. ITEM HANDLER SPAWNER
local function grabAK47()
    -- Directly invokes the unpatched map inventory remote handler
    local handler = Workspace:FindFirstChild("Remote") and Workspace.Remote:FindFirstChild("ItemHandler")
    local giver = Workspace:FindFirstChild("Prison_ITEMS") and Workspace.Prison_ITEMS.giver:FindFirstChild("AK-47")
    
    if handler and giver and giver:FindFirstChild("ITEMPICKUP") then
        handler:InvokeServer(giver.ITEMPICKUP)
    end
end

-- 3. MODERN GUN STATE OVERWRITER
local function injectMaxWeaponStats()
    local function modTool(tool)
        if tool:IsA("Tool") and tool:FindFirstChild("GunStates") then
            local gunState = require(tool.GunStates)
            if gunState then
                gunState.MaxAmmo = 999999
                gunState.CurrentAmmo = 999999
                gunState.StoredAmmo = 999999
                gunState.ReloadTime = 0.0001 -- Instant clip refresh cycle
                gunState.FireRate = 0.0001   -- Instantaneous loop speed
                gunState.AutoFire = true     -- Correct configuration keyword
                gunState.Spread = 0          -- Zero vector bloom variance
                gunState.Recoil = 0          -- Zero view-frame displacement
            end
        end
    end

    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do modTool(tool) end
    if LocalPlayer.Character then
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do modTool(tool) end
    end
end

-- Force auto-mods if gear pops into inventory via loop
LocalPlayer.Backpack.ChildAdded:Connect(function()
    if _G.HunterLoopActive then
        task.wait(0.05)
        injectMaxWeaponStats()
    end
end)

-- 4. POLICE TARGET TRACKING LOCATOR
local function locateNearestOfficer()
    local optimalTarget = nil
    local minimumDistance = math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.TeamColor.Name == POLICE_TEAM and player.Character then
            local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local tHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if tRoot and tHumanoid and tHumanoid.Health > 0 then
                local distance = (myRoot.Position - tRoot.Position).Magnitude
                if distance < minimumDistance then
                    minimumDistance = distance
                    optimalTarget = player
                end
            end
        end
    end
    return optimalTarget
end

-- 5. THE RUNTIME REPLICATION PIPELINE
local combatConnection
combatConnection = RunService.Heartbeat:Connect(function()
    if not _G.HunterLoopActive then return end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local activeGun = myChar and myChar:FindFirstChildOfClass("Tool")
    local shootRemote = ReplicatedStorage:FindFirstChild("ShootEvent") -- Fixed network route
    
    if not myRoot then return end
    
    -- Ensure you are constantly holding the weapon out for firing checks
    if not activeGun or not activeGun:FindFirstChild("GunStates") then
        local backupAK = LocalPlayer.Backpack:FindFirstChild("AK-47")
        if backupAK and myChar:FindFirstChildOfClass("Humanoid") then
            myChar:FindFirstChildOfClass("Humanoid"):EquipTool(backupAK)
        end
        return
    end

    local cop = locateNearestOfficer()
    if cop and cop.Character then
        local cRoot = cop.Character:FindFirstChild("HumanoidRootPart")
        local cHead = cop.Character:FindFirstChild("Head")
        
        if cRoot and cHead then
            -- A. TELEPORTATION SYSTEM: Lock 2 studs behind target frame coordinates
            myRoot.CFrame = cRoot.CFrame * CFrame.new(0, 0, 2)
            
            -- B. CAMERA AIMLOCK: Center camera straight down the skull node orientation
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, cHead.Position)
            
            -- C. STABILIZED AUTOSHOOT PACK: Pack ray data vectors to ReplicatedStorage
            if shootRemote then
                shootRemote:FireServer({
                    {
                        RayObject = Ray.new(myRoot.Position, (cHead.Position - myRoot.Position).Unit),
                        Distance = (cHead.Position - myRoot.Position).Magnitude,
                        Cframe = cHead.CFrame,
                        Hit = cHead
                    }
                }, activeGun)
            end
        end
    end
end)

-- 6. INTERFACE TRIGGER LOGIC (P BIND)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == TOGGLE_KEY then
        _G.HunterLoopActive = not _G.HunterLoopActive
        
        if _G.HunterLoopActive then
            grabAK47()               -- Instantly drops weapon structure into pack
            task.wait(0.1)           -- Give the server event time to register weapon
            injectMaxWeaponStats()   -- Apply broken stats setup
            
            IndicatorBar.BackgroundColor3 = Color3.fromRGB(60, 255, 60) -- Green
            StatusText.Text = "SYSTEM ENGINE: ACTIVE\nTracking Guard Factions..."
        else
            IndicatorBar.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- Red
            StatusText.Text = "SYSTEM ENGINE: PAUSED\nPress [P] to Fire Matrix"
        end
    end
end)
