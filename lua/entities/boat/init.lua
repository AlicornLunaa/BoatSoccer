-- Client file initialization
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Include entity settings
include("shared.lua")

-- Entity functions
function ENT:Initialize()
    self:SetModel("models/props_canal/boat002b.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end
end

function ENT:Use( activator, caller )
    return
end