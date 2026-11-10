local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

-- 1. REMOTE WEAPON GIVER (Gets guns from any location)
local weaponSpawns = Workspace:FindFirstChild("Prison_ITEMS") and Workspace.Prison_ITEMS:FindFirstChild("giver")
if weaponSpawns then
    -- List of default weapons available in the map layers
    local guns = {"M9", "Remington 870", "AK-47"}
    for _, gunName in ipairs(guns) do
        local giver = weaponSpawns:FindFirstChild(gunName)
        if giver and giver:FindFirstChild("ITEMPICKUP") then
            -- Fires the pickup event directly to trick the server into giving the gun
            Workspace.Remote.ItemHandler:InvokeServer(giver.ITEMPICKUP)
        end
    end
end

-- 2. GUN MODDER (Applies infinite fire-rate, auto-fire, and max ammo)
local function modGuns()
    for _, item in ipairs(localPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") and item:FindFirstChild("GunStates") then
            -- Targets the module script that controls how the weapon behaves
            local gunState = require(item.GunStates)
            if gunState then
                gunState.Damage = 100       -- One-shot kill damage matrix
                gunState.FireRate = 0.001   -- Insanely fast automatic firing speed
                gunState.MaxAmmo = 99999    -- Infinite clip size reserve
                gunState.CurrentAmmo = 99999
                gunState.Automatic = true   -- Turns the semi-auto pistol into a machine gun
                gunState.Spread = 0         -- Absolute perfect laser accuracy
                gunState.Recoil = 0         -- Zero screen shaking when shooting
            end
        end
    end
end

-- Monitor backpack updates to ensure newly spawned weapons get modded instantly
localPlayer.Backpack.ChildAdded:Connect(function()
    task.wait(0.1)
    modGuns()
end)

-- Run it initially for guns already in your inventory
modGuns()
