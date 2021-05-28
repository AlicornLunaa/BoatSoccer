-- Client file initialization
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Include entity settings
include("shared.lua")
include("boat_soccer/sh_init.lua")

-- Entity functions
function ENT:Initialize()
    -- Initialize entity
    self:SetModel("models/boat_soccer/speedboat.mdl")
    self:InitializeData()
    self.offset = Angle(0, 0, 0)
    self.bs_buoyancy = 5
    self.speed = 700
    self:InitPhys()
end