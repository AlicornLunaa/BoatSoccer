-- Initialize net messages
util.AddNetworkString("boat_soccer:update_controllers")

-- Functions
function boat_soccer.UpdateControllerClient(ply)
    -- Sends the table of the controller, this will contains all the controllers the player is apart of
    net.Start("boat_soccer:update_controllers")

    net.WriteTable(boat_soccer.controllers)

    if(ply == nil) then
        net.Broadcast()
    else
        net.Send(ply)
    end
end
