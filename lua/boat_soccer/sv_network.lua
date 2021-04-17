-- Initialize net messages
util.AddNetworkString("boat_soccer:update_controllers")
util.AddNetworkString("boat_soccer:open_menu")
util.AddNetworkString("boat_soccer:join")
util.AddNetworkString("boat_soccer:leave")
util.AddNetworkString("boat_soccer:switch_team")
util.AddNetworkString("boat_soccer:start_game")
util.AddNetworkString("boat_soccer:force_leave")

-- Functions
function boat_soccer.UpdateControllerClient(ply)
    -- Sends the table of the controller, this will contains all the controllers the player is apart of
    net.Start("boat_soccer:update_controllers")

    net.WriteTable(boat_soccer.controllers)

    if (ply == nil) then
        net.Broadcast()
    else
        net.Send(ply)
    end
end

function boat_soccer.ForceLeave(ply)
    net.Start("boat_soccer:force_leave")
    net.Send(ply)
end

function boat_soccer.OpenMenu(ply, id)
    -- Opens the derma panel on the client
    net.Start("boat_soccer:open_menu")
        net.WriteInt(id, 8)
    net.Send(ply)
end

-- Receives
net.Receive("boat_soccer:join", function(len, ply)
    local id = net.ReadInt(8)
    boat_soccer.AddPlayer(ply, id)
end )

net.Receive("boat_soccer:leave", function(len, ply)
    local id = net.ReadInt(8)
    boat_soccer.DelPlayer(ply, id)
end )

net.Receive("boat_soccer:switch_team", function(len, ply)
    local id = net.ReadInt(8)
    boat_soccer.SwitchTeam(ply, id)
end )

net.Receive("boat_soccer:start_game", function(len, ply)
    local id = net.ReadInt(8)
    boat_soccer.StartGame(id)
end )