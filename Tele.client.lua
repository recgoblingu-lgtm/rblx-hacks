local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Connection storage so it doesn't duplicate if executed multiple times
if _G.TeleportConnection then 
    _G.TeleportConnection:Disconnect() 
end

_G.TeleportConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- This ensures typing in the executor box or game chat doesn't trigger a teleport
    if gameProcessed then return end
    
    -- Check for Left Click + Left Control
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if rootPart and mouse.Target then
                -- Sets position and safely prevents clipping into the ground floor matrix
                rootPart.CFrame = mouse.Hit + Vector3.new(0, 3, 0)
            end
        end
    end
end)
