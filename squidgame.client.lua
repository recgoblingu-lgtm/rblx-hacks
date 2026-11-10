local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

-- 1. GLASS BRIDGE REVEALER (Finds safe tiles instantly)
local function revealGlass()
    -- Adjust the map model name depending on the exact game variant
    local bridge = Workspace:FindFirstChild("GlassBridge") or Workspace:FindFirstChild("Bridge")
    if bridge then
        for _, part in ipairs(bridge:GetDescendants()) do
            -- Looks for hidden attributes or text identifiers used by devs to track fake glass
            if part:IsA("BasePart") and (part.Name:lower():find("fake") or part:FindFirstChild("Fake")) then
                part.Color = Color3.fromRGB(255, 0, 0) -- Highlight death tiles bright red
                part.Transparency = 0.5
            elseif part:IsA("BasePart") and (part.Name:lower():find("real") or part:FindFirstChild("Real")) then
                part.Color = Color3.fromRGB(0, 255, 0) -- Highlight safe tiles bright green
            end
        end
    end
end

-- 2. AUTO JUMP ROPE / AUTOMATIC TUG-OF-WAR MASH
local function bypassObstacles()
    -- Tug-of-war automatic interaction
    local remote = Workspace:FindFirstChild("Remote") or game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    if remote and remote:FindFirstChild("Pull") then
        task.spawn(function()
            while task.wait(0.05) do
                remote.Pull:FireServer() -- Spams the pulling network event instantly
            end
        end)
    end
end

-- 3. RED LIGHT, GREEN LIGHT ANTI-DETECTION
local function secureMovement()
    local character = localPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    
    -- Tracks the state text or value of the game manager doll
    local gameStatus = Workspace:FindFirstChild("Status") or Workspace:FindFirstChild("GameState")
    if gameStatus then
        gameStatus.Changed:Connect(function(val)
            if val == "RedLight" and root then
                -- Freezes your physical velocity vectors instantly so the doll detects zero speed
                root.Velocity = Vector3.new(0,0,0)
                root.RotVelocity = Vector3.new(0,0,0)
            end
        end)
    end
end

-- Run initial triggers
revealGlass()
secureMovement()
bypassObstacles()
