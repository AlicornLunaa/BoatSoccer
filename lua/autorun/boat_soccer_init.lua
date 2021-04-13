if (SERVER) then
    AddCSLuaFile("boat_soccer_init.lua")
    AddCSLuaFile("boat_soccer/sh_init.lua")
    AddCSLuaFile("boat_soccer/cl_init.lua")
    AddCSLuaFile("boat_soccer/cl_network.lua")

    include("boat_soccer/sv_init.lua")
else
    include("boat_soccer/cl_init.lua")
end