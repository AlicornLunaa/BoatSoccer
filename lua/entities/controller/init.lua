AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

function ENT:Initialize()
    -- Initialize entities
    self:SetModel("models/props_c17/FurnitureWashingmachine001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    -- Initialize members
    self.users = {} -- The list of users actually ready to play

    -- Physics initialization
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:SetMass(500)
        phys:Wake()
    end
end

function ENT:Use( activator, caller )
    if (activator:IsValid() and activator:IsPlayer()) then
        if (self.users[activator:SteamID64()] == nil) then
            self.users[activator:SteamID64()] = true
            return
        end

        self.users[activator:SteamID64()] = !self.users[activator:SteamID64()]
    end

    PrintTable(self.users)
end

function ENT:Think()

    -- Faster update
    self:NextThink(CurTime())
    return true
end