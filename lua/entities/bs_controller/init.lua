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
    boat_soccer.controllers[self:EntIndex()] = {}
    boat_soccer.controllers[self:EntIndex()].entity = self
    boat_soccer.controllers[self:EntIndex()].players = {}
    boat_soccer.UpdateControllerClient()

    -- Physics initialization
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:SetMass(500)
        phys:Wake()
    end
end

function ENT:Use( activator, caller )
    if (activator:IsValid() and activator:IsPlayer()) then
        boat_soccer.OpenMenu(activator, self:EntIndex())
    end
end

function ENT:Think()
    -- Update entity client
    boat_soccer.UpdateControllerClient()

    -- Faster update
    self:NextThink(CurTime())
    return true
end

function ENT:OnRemove()
    boat_soccer.controllers[self:EntIndex()] = nil
end

-- Game specific functions
function ENT:StartGame()
    print("Starting game!")
end