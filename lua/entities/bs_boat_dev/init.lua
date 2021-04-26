-- Client file initialization
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Include entity settings
include("shared.lua")
include("boat_soccer/sh_init.lua")

-- Entity functions
function ENT:Initialize()
    -- Initialize entity
    self:SetModel("models/props_borealis/bluebarrel001.mdl")
    self:SetModelScale(0.25, 0)
    self:InitializeData()

    -- Start physics
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:SetMass(100)
        phys:Wake()
    end

    self:Activate()
end