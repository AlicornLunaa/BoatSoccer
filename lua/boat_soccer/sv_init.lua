-- Server initialization
boat_soccer = boat_soccer or {}
boat_soccer.controllers = {}

include("sv_network.lua")

-- Functions
function boat_soccer.AddPlayer(ply, c, id)
    -- Adds player to the controller with that id
    boat_soccer.controllers[id].players[ply:SteamID64()] = {
        name = ply:Nick(),
        color = c
    }
end

function boat_soccer.DelPlayer(ply, id)
    -- Removes player from the controller with that id
    boat_soccer.controllers[id].players[ply:SteamID64()] = nil
    boat_soccer.UpdateControllerClient(ply)
end