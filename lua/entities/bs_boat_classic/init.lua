-- Client file initialization
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Include entity settings
include("shared.lua")
include("boat_soccer/sh_init.lua")

-- Entity functions
function ENT:Initialize()
    -- Initialize entity
    self:SetModel("models/props_canal/boat002b.mdl")
    self:SetModelScale(0.25, 0)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:InitializeData()

    -- Start physics
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:SetMass(100)
        phys:Wake()
    end

    self:Activate()
end