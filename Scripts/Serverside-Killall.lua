-- Script to kill all players except for specified usernames
local exemptPlayers = {
    ["Syfer_eng"] = true,
    ["Reviwedpuppy93"] = true
}

local function killAllExcept()
    for _, player in pairs(game.Players:GetPlayers()) do
        if not exemptPlayers[player.Name] then
            -- Check if the player has a character and humanoid
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Health = 0
            end
        end
    end
end

-- Run the function once when the script starts
killAllExcept()

-- Optionally, you can set this to run periodically
-- game:GetService("RunService").Heartbeat:Connect(killAllExcept)

-- Or when a new player joins
game.Players.PlayerAdded:Connect(function(player)
    -- Give the player time to load their character
    wait(1)
    if not exemptPlayers[player.Name] then
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = 0
        end
    end
end)

-- Handle when a player's character respawns
game.Players.PlayerRespawned:Connect(function(player)
    if not exemptPlayers[player.Name] then
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = 0
        end
    end
end)
