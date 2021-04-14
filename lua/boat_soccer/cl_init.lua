-- Client initialization
boat_soccer_client = boat_soccer_client or {}
boat_soccer_client.controllers = {}
boat_soccer_client.joined = false 

include("cl_network.lua")
include("cl_menu.lua")

concommand.Add("bs_open_menu", function()
    boat_soccer_client.OpenMenu()
end )

-- Functions
function boat_soccer_client.Join(color, id)
    boat_soccer_client.joined = true

    net.Start("boat_soccer:join")
        net.WriteInt(id, 8)
        net.WriteColor(color)
    net.SendToServer()
end

function boat_soccer_client.Leave(id)
    boat_soccer_client.joined = false

    net.Start("boat_soccer:leave")
        net.WriteInt(id, 8)
    net.SendToServer()
end

function boat_soccer_client.SwitchTeam(id)
    if (boat_soccer_client.joined) then
        net.Start("boat_soccer:switch_team")
            net.WriteInt(id, 8)
        net.SendToServer()
    end
end