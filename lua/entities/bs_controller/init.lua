AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")
include("boat_soccer/sh_init.lua")

local function SpawnGoal(pos, ang, color)
    local e = ents.Create("bs_goal")
    e:SetPos(pos)
    e:SetAngles(ang)
    e:SetColor(color)
    e:Spawn()

    return e
end

function ENT:Initialize()
    -- Initialize entities
    self:SetModel("models/props_c17/FurnitureWashingmachine001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    -- Initialize members
    self.goal0 = SpawnGoal(self:LocalToWorld(Vector(0, -100, 0)), self:LocalToWorldAngles(Angle(0, 90, 0)), boat_soccer_config.team0)
    self.goal1 = SpawnGoal(self:LocalToWorld(Vector(0, 100, 0)), self:LocalToWorldAngles(Angle(0, 270, 0)), boat_soccer_config.team1)
    self.spawnedBoats = {}
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
    -- Force every player to leave
    for k, v in pairs(boat_soccer.controllers[self:EntIndex()].players) do
        boat_soccer.ForceLeave(player.GetBySteamID64(k))
        boat_soccer.CloseDerma(player.GetBySteamID64(k))
    end

    -- Delete every boat
    for k, v in pairs(self.spawnedBoats) do
        v:Remove()
    end

    if (self.goal0 and self.goal0:IsValid()) then self.goal0:Remove() end
    if (self.goal1 and self.goal1:IsValid()) then self.goal1:Remove() end

    boat_soccer.controllers[self:EntIndex()] = nil
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