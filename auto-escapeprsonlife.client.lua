local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer

local function executeAutoEscape()
    local character = localPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if rootPart then
        -- 1. Trigger the team change event
        -- This updates your status to Criminal and ensures you don't get shot by prison turrets
        local teamEvent = Workspace:FindFirstChild("Remote") and Workspace.Remote:FindFirstChild("TeamEvent")
        if teamEvent then
            teamEvent:FireServer("Bright red")
        end
        
        -- 2. Teleport to the Criminal Base
        -- These exact coordinates land you safely inside the criminal spawn warehouse
        local criminalBaseCoordinates = Vector3.new(-943, 94, 2063)
        rootPart.CFrame = CFrame.new(criminalBaseCoordinates) + Vector3.new(0, 4, 0)
        
        print("Successfully escaped! Character moved to Criminal Base.")
    else
        warn("Escape failed: HumanoidRootPart is missing.")
    end
end

executeAutoEscape()
