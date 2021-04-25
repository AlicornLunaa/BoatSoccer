if (SERVER) then
    AddCSLuaFile("boat_soccer_init.lua")
    AddCSLuaFile("boat_soccer/sh_init.lua")
    AddCSLuaFile("boat_soccer/cl_init.lua")
    AddCSLuaFile("boat_soccer/cl_network.lua")
    AddCSLuaFile("boat_soccer/cl_menu.lua")
    AddCSLuaFile("boat_soccer/cl_boat_hud.lua")

    include("boat_soccer/sv_init.lua")
else
    include("boat_soccer/cl_init.lua")
    include("boat_soccer/cl_boat_hud.lua")
end