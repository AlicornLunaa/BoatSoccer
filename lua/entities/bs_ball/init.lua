AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("boat_soccer/sh_init.lua")

function ENT:Initialize()
    self:SetModel("models/props_phx/misc/soccerball.mdl")
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    self.bs_buoyancy = 2

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:SetMass(50)
        phys:SetBuoyancyRatio(self.bs_buoyancy)
        phys:Wake()
    end
end

function ENT:PhysicsCollide(data, phys)
    -- Set color of the ball to the last team who touched it
    if (data.HitEntity.ClassName == "bs_boat") then
        local team = data.HitEntity.team

        if (team == 0) then
            self:SetColor(boat_soccer_config.team0)
        else
            self:SetColor(boat_soccer_config.team1)
        end
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