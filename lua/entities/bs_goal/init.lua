AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/boat_soccer/goal.mdl")
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    self.bs_buoyancy = 1

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:SetMass(10)
        phys:SetBuoyancyRatio(self.bs_buoyancy)
        phys:Wake()
    end
end

function ENT:Use( activator, caller )
    return
end