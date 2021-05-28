-- Server initialization
boat_soccer = boat_soccer or {}
boat_soccer.controllers = {}

include("sv_network.lua")
include("sh_init.lua")

-- Convars
CreateConVar("bs_pickup_disabled", 1, FCVAR_NONE, "Whether or not you can pickup entities in a game", 0, 1)

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
    local ma = (boat_soccer.controllers[id].playerCount == 0)
    local t = 0

    if (boat_soccer.GetTeamCount(0, id) >= boat_soccer_config.maxTeamSize) then
        t = 1
    end

    if (boat_soccer.controllers[id].players[ply:SteamID64()] == nil) then
        -- Only increment playerCount if the player is joining for the first time
        boat_soccer.controllers[id].playerCount = boat_soccer.controllers[id].playerCount + 1
    else
        -- If the player isn't joining for the first time, matchAdmin flag should be the same
        ma = boat_soccer.controllers[id].players[ply:SteamID64()].matchAdmin
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
    boat_soccer.controllers[id].playerCount = boat_soccer.controllers[id].playerCount - 1
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
    if (!GetConVar("bs_pickup_disabled"):GetBool()) then return true end

    -- Disable pickup for started arenas
    if (ent.Base == "bs_arena_base") then
        return !boat_soccer.IsStarted(ent:EntIndex())
    elseif (ent.ClassName == "bs_ball") then
        return false
    elseif (ent.Base == "bs_boat_base") then
        return ent.team == -1
    end

    return true
end )

hook.Add("CanPlayerUnfreeze", "boat_soccer:allowfreeze", function(ply, ent)
    if (!GetConVar("bs_pickup_disabled"):GetBool()) then return true end

    -- Disable pickup for started arenas
    if (ent.Base == "bs_arena_base") then
        return !boat_soccer.IsStarted(ent:EntIndex())
    elseif (ent.ClassName == "bs_ball") then
        return false
    elseif (ent.Base == "bs_boat_base") then
        return ent.team == -1
    end

    return true
end )

local function FixBuoyancy(_, ent)
    if (ent:IsValid() and ent.bs_buoyancy) then
        local phys = ent:GetPhysicsObject()

        timer.Simple(0, function()
            if (phys:IsValid()) then
                phys:SetBuoyancyRatio(ent.bs_buoyancy)
            end
        end )
    end
end
hook.Add("PhysgunDrop", "boat_soccer:fix_buoyancy", FixBuoyancy)
hook.Add("GravGunOnDropped", "boat_soccer:fix_buoyancy", FixBuoyancy)