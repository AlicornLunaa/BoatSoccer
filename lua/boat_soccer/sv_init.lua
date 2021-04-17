-- Server initialization
boat_soccer = boat_soccer or {}
boat_soccer.controllers = {}

include("sv_network.lua")

-- Functions
function boat_soccer.AddPlayer(ply, id)
    -- Adds player to the controller with that id
    local ma
    if (#boat_soccer.controllers[id].players > 1) then
        ma = false
    else
        ma = true
    end

    boat_soccer.controllers[id].players[ply:SteamID64()] = {
        name = ply:Nick(),
        team = 0,
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
    if (boat_soccer.controllers[id].players[ply:SteamID64()].team == 0) then
        boat_soccer.controllers[id].players[ply:SteamID64()].team = 1
    else
        boat_soccer.controllers[id].players[ply:SteamID64()].team = 0
    end
end

function boat_soccer.StartGame(id)
    boat_soccer.controllers[id].entity:StartGame()
end

-- Debug
concommand.Add("bs_spawn_goal", function(ply)
    -- Spawns goal and sets the ball as well
    local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 10000,
        filter = function(ent) if (!ent:IsPlayer()) then return true end end
    })

    if (!tr.Hit) then return end

    local SpawnPos = tr.HitPos + tr.HitNormal * 16

    local ballEnt = ents.Create("bs_ball")
    ballEnt:SetPos( SpawnPos )
	ballEnt:Spawn()

	local goalEnt = ents.Create("bs_goal")
	goalEnt:SetPos( SpawnPos )
	goalEnt:Spawn()
    goalEnt:SetBall(ballEnt)
end )