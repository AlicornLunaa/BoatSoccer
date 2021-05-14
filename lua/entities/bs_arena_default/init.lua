AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("boat_soccer/sh_init.lua")

function ENT:Initialize()
    self:ArenaInit("models/boat_soccer/arena0.mdl", "models/boat_soccer/goal0.mdl")
end