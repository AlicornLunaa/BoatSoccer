AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("boat_soccer/sh_init.lua")

function ENT:Initialize()
    self:SetModel("models/boat_soccer/arena.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    -- Initialize members
    self.goal0 = nil
    self.goal1 = nil
    self.bs_ball = nil
    self.spawnedBoats = {}
    boat_soccer.controllers[self:EntIndex()] = {}
    boat_soccer.controllers[self:EntIndex()].entity = self
    boat_soccer.controllers[self:EntIndex()].players = {}

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:SetMass(1000)
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
    -- Cleanup
    -- Force every player to leave
    for k, v in pairs(boat_soccer.controllers[self:EntIndex()].players) do
        boat_soccer.ForceLeave(player.GetBySteamID64(k))
        boat_soccer.CloseDerma(player.GetBySteamID64(k))
    end

    -- Delete every boat
    for k, v in pairs(self.spawnedBoats) do
        v:Remove()
    end

    -- Remove goals and ball
    if (self.goal0 and self.goal0:IsValid()) then self.goal0:Remove() end
    if (self.goal1 and self.goal1:IsValid()) then self.goal1:Remove() end
    if (self.bs_ball and self.bs_ball:IsValid()) then self.bs_ball:Remove() end
end

-- Game specific functions
function ENT:StartGame()
    -- Spawn boats for each player on each team
    for k, v in pairs(boat_soccer.controllers[self:EntIndex()].players) do
        boat_soccer.CloseDerma(player.GetBySteamID64(k))

        local color
        if (v.team == 0) then
            color = boat_soccer_config.team0
        else
            color = boat_soccer_config.team1
        end

        self.spawnedBoats[#self.spawnedBoats + 1] = ents.Create("bs_boat")
        self.spawnedBoats[#self.spawnedBoats]:SetPos(self:GetPos() + Vector(0, 0, 100))
        self.spawnedBoats[#self.spawnedBoats]:SetColor(color)
        self.spawnedBoats[#self.spawnedBoats]:Spawn()
        self.spawnedBoats[#self.spawnedBoats]:Use(player.GetBySteamID64(k))
    end
end