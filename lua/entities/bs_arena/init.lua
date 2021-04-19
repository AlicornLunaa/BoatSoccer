AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("boat_soccer/sh_init.lua")

local function SpawnGoal(pos, ang)
    local e = ents.Create("prop_physics")
    e:SetModel("models/boat_soccer/goal.mdl")
    e:SetPos(pos)
    e:SetAngles(ang)
    e:Spawn()
    e:SetRenderMode(RENDERMODE_TRANSCOLOR)
    e:GetPhysicsObject():EnableMotion(false)
    e:SetColor(Color(0, 0, 0, 0))

    return e
end

function ENT:Initialize()
    self:SetModel("models/boat_soccer/arena.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    -- Initialize members
    self.goal0 = SpawnGoal(self:GetPos(), self:GetAngles())
    self.goal1 = SpawnGoal(self:GetPos(), self:LocalToWorldAngles(Angle(0, 180, 0)))
    self.bs_ball = nil
    self.spawnedBoats = {}
    boat_soccer.controllers[self:EntIndex()] = {}
    boat_soccer.controllers[self:EntIndex()].entity = self
    boat_soccer.controllers[self:EntIndex()].players = {}

    constraint.NoCollide(self, self.goal0, 0, 0)
    constraint.NoCollide(self, self.goal1, 0, 0)

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
    -- Keep goals in position
    self.goal0:SetPos(self:GetPos())
    self.goal0:SetAngles(self:GetAngles())
    self.goal0:GetPhysicsObject():EnableMotion(false)

    self.goal1:SetPos(self:LocalToWorld(Vector(0, 0, 0)))
    self.goal1:SetAngles(self:LocalToWorldAngles(Angle(0, 180, 0)))
    self.goal1:GetPhysicsObject():EnableMotion(false)

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
        if (player.GetBySteamID64(k)) then continue end

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
    spawn0 = 1
    spawn1 = 1
    for k, v in pairs(boat_soccer.controllers[self:EntIndex()].players) do
        boat_soccer.CloseDerma(player.GetBySteamID64(k))

        local pos
        local ang
        local color
        if (v.team == 0) then
            pos = self:LocalToWorld(boat_soccer_config.team0_spawns[spawn0])
            ang = self:LocalToWorldAngles(Angle(0, 0, 0))
            color = boat_soccer_config.team0

            spawn0 = spawn0 + 1
            if (spawn0 > 10) then spawn0 = 1 end
        else
            pos = self:LocalToWorld(boat_soccer_config.team1_spawns[spawn1])
            ang = self:LocalToWorldAngles(Angle(0, 180, 0))
            color = boat_soccer_config.team1

            spawn1 = spawn1 + 1
            if (spawn1 > 10) then spawn1 = 1 end
        end

        self.spawnedBoats[#self.spawnedBoats + 1] = ents.Create("bs_boat")
        self.spawnedBoats[#self.spawnedBoats]:SetPos(pos)
        self.spawnedBoats[#self.spawnedBoats]:SetAngles(ang)
        self.spawnedBoats[#self.spawnedBoats]:SetColor(color)
        self.spawnedBoats[#self.spawnedBoats]:Spawn()
        self.spawnedBoats[#self.spawnedBoats]:GetPhysicsObject():EnableMotion(false)
        self.spawnedBoats[#self.spawnedBoats]:Use(player.GetBySteamID64(k))
    end
end