-- Client networking
-- Receives
net.Receive("boat_soccer:update_controllers", function()
    boat_soccer_client.controllers = net.ReadTable()
    hook.Call("boat_soccer:reload_derma")
end )

net.Receive("boat_soccer:open_menu", function()
    local id = net.ReadInt(8)
    boat_soccer_client.OpenMenu(id, boat_soccer_client.IsMatchAdmin(id))
end )