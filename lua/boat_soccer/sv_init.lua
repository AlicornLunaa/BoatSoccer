-- Server initialization
boat_soccer = boat_soccer or {}
boat_soccer.controllers = {}

include("sv_network.lua")
include("sh_init.lua")

-- Functions
function boat_soccer.GetTeamCount(team, id)
    local count = 0

    for k, v in pairs(boat_soccer.controllers[id].players) do
        if (v.team == team) then
            count = count + 1
        end
    end

    return count
end

function boat_soccer.IsStarted(id)
    return boat_soccer.controllers[id].gameStarted
end

function boat_soccer.AddPlayer(ply, id, boatSelection)
    -- Adds player to the controller with that id
    local ma = (#boat_soccer.controllers[id].players == 0)
    local t = 0

    if (boat_soccer.GetTeamCount(0, id) >= boat_soccer_config.maxTeamSize) then
        t = 1
    end

    boat_soccer.controllers[id].players[ply:SteamID64()] = {
        name = ply:Nick(),
        team = t,
        boatType = boatSelection,
        matchAdmin = ma
    }
end

function boat_soccer.DelPlayer(ply, id)
    -- Removes player from the controller with that id
    boat_soccer.controllers[id].players[ply:SteamID64()] = nil
    boat_soccer.UpdateControllerClient(ply)
end

function boat_soccer.SwitchTeam(ply, id)
    -- Removes player from the controller with that id
    local currentTeam = boat_soccer.controllers[id].players[ply:SteamID64()].team
    if (boat_soccer.GetTeamCount(1 - currentTeam, id) >= boat_soccer_config.maxTeamSize) then return end -- Dont allow more than 5 people on a team

    boat_soccer.controllers[id].players[ply:SteamID64()].team = (1 - currentTeam)
end

function boat_soccer.StartGame(id)
    boat_soccer.controllers[id].entity:StartGame()
end

function boat_soccer.UpdateGameSettings(id, matchLength, winningScore, boostDrain, boostRegen, boostMult)
    boat_soccer.controllers[id].settings.matchLength = matchLength
    boat_soccer.controllers[id].settings.winningScore = winningScore
    boat_soccer.controllers[id].settings.boostDrain = boostDrain
    boat_soccer.controllers[id].settings.boostRegen = boostRegen
    boat_soccer.controllers[id].settings.boostMultiply = boostMult
end

-- Hooks
hook.Add("PhysgunPickup", "boat_soccer:allowpickup", function(ply, ent)
    -- Disable pickup for started arenas
    if (ent.ClassName == "bs_arena") then
        return !boat_soccer.IsStarted(ent:EntIndex())
    elseif (ent.ClassName == "bs_ball") then
        return false
    elseif (ent.ClassName == "bs_boat") then
        return ent.team == -1
    end

    return true
end )