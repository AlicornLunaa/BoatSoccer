-- Client networking
net.Receive("boat_soccer:update_controllers", function()
    boat_soccer_client.controllers = net.ReadTable()
end )