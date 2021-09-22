-- Client networking
-- Receives
net.Receive("boat_soccer:update_controllers", function()
    boat_soccer_client.controllers = net.ReadTable()
    hook.Call("boat_soccer:reload_derma")
end )

net.Receive("boat_soccer:open_menu", function()
    local id = net.ReadInt(32)
    boat_soccer_client.OpenMenu(id, boat_soccer_client.IsMatchAdmin(id))
end )

net.Receive("boat_soccer:force_leave", function()
    boat_soccer_client.joined = false
    hook.Call("boat_soccer:close_derma")
end )

net.Receive("boat_soccer:close_derma", function()
    hook.Call("boat_soccer:close_derma")
end )

net.Receive("boat_soccer:play_end_sound", function()
    local id = net.ReadInt(32)
    local winner = net.ReadBool()

    print(winner)

    if winner then
        boat_soccer_client.controllers[id].entity:EmitSound("game_won")
    else
        boat_soccer_client.controllers[id].entity:EmitSound("game_lost")
    end
end )