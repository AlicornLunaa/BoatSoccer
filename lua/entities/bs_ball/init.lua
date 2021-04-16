AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_phx/misc/soccerball.mdl")
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

-- Hooks
local function FixBuoyancy(_, ent)
    if (ent:IsValid() and ent.bs_buoyancy) then
        local phys = ent:GetPhysicsObject()

        if (phys:IsValid()) then
            timer.Simple(0, function()
                phys:SetBuoyancyRatio(ent.bs_buoyancy)
            end )
        end
    end
end
hook.Add("PhysgunDrop", "boat_soccer:fix_buoyancy", FixBuoyancy)
hook.Add("GravGunOnDropped", "boat_soccer:fix_buoyancy", FixBuoyancy)