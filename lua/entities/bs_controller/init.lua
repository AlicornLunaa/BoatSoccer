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
    boat_soccer.controllers[self:EntIndex()] = {}
    boat_soccer.controllers[self:EntIndex()].players = {}
    boat_soccer.UpdateControllerClient(self:GetOwner())

    -- Physics initialization
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:SetMass(500)
        phys:Wake()
    end
end

function ENT:Use( activator, caller )
    if (activator:IsValid() and activator:IsPlayer()) then
        if (self.users[activator] == nil) then
            self.users[activator] = true

            boat_soccer.controllers[self:EntIndex()].players[activator:SteamID64()] = {
                name = activator:Nick()
            }
        else
            self.users[activator] = nil
            boat_soccer.controllers[self:EntIndex()].players[activator:SteamID64()] = nil
            boat_soccer.UpdateControllerClient(activator)
        end
    end
end

function ENT:Think()
    -- Update entity client
    for k, v in pairs(self.users) do
        boat_soccer.UpdateControllerClient(k)
    end

    -- Faster update
    self:NextThink(CurTime())
    return true
end

function ENT:OnRemove()
    boat_soccer.controllers[self:EntIndex()] = nil
end