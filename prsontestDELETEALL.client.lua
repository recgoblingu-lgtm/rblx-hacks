-- Removals utility for all security gates and doors
local Workspace = game:GetService("Workspace")

local function mapClearance()
    -- Safely targets the primary folder holding door assets
    local doors = Workspace:FindFirstChild("Doors")
    if doors then
        doors:Destroy()
    end
    
    -- Recursively checks for remaining cell gates or security models
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("door") or obj.Name:lower():find("gate")) then
            obj:Destroy()
        end
    end
end

mapClearance()
