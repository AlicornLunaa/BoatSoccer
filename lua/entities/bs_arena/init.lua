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

local function SpawnBall(pos)
    local e = ents.Create("bs_ball")
    e:SetPos(pos)
    e:Spawn()
    e:GetPhysicsObject():EnableMotion(false)

    return e
end

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
    self.resetting = false
    boat_soccer.controllers[self:EntIndex()] = {}
    boat_soccer.controllers[self:EntIndex()].entity = self
    boat_soccer.controllers[self:EntIndex()].players = {}
    boat_soccer.controllers[self:EntIndex()].gameStarted = false

    -- Networked variables
    self:SetNWInt("score0", 0)
    self:SetNWInt("score1", 0)
    self:SetNWInt("round", 1)

    -- Phys init
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
    if (self.goal0 and self.goal0:IsValid()) then
        self.goal0:SetPos(self:GetPos())
        self.goal0:SetAngles(self:GetAngles())
        self.goal0:GetPhysicsObject():EnableMotion(false)
    end

    if (self.goal1 and self.goal1:IsValid()) then
        self.goal1:SetPos(self:LocalToWorld(Vector(0, 0, 0)))
        self.goal1:SetAngles(self:LocalToWorldAngles(Angle(0, 180, 0)))
        self.goal1:GetPhysicsObject():EnableMotion(false)
    end

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
        if (!player.GetBySteamID64(k)) then continue end

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

    -- Remove controller input
    boat_soccer.controllers[self:EntIndex()] = false
    boat_soccer.UpdateControllerClient()
end

-- Game specific functions
function ENT:StartGame()
    -- Spawn ball
    boat_soccer.controllers[self:EntIndex()].gameStarted = true
    self.goal0 = SpawnGoal(self:GetPos(), self:GetAngles())
    self.goal1 = SpawnGoal(self:GetPos(), self:LocalToWorldAngles(Angle(0, 180, 0)))
    self.bs_ball = SpawnBall(self:LocalToWorld(Vector(0, 0, 80)))

    constraint.NoCollide(self, self.goal0, 0, 0)
    constraint.NoCollide(self, self.goal1, 0, 0)

    -- Callbacks for goals
    self.goal0:AddCallback("PhysicsCollide", function(e, data)
        if (data.HitEntity == self.bs_ball and !self.resetting) then
            self.resetting = true
            self:SetNWInt("score1", self:GetNWInt("score1", 0) + 1)

            self.bs_ball:GetPhysicsObject():EnableMotion(false)

            timer.Simple(2, function()
                self:ResetRound()
            end )
        end
    end )

    self.goal1:AddCallback("PhysicsCollide", function(e, data)
        if (data.HitEntity == self.bs_ball and !self.resetting) then
            self.resetting = true
            self:SetNWInt("score0", self:GetNWInt("score0", 0) + 1)

            self.bs_ball:GetPhysicsObject():EnableMotion(false)

            timer.Simple(2, function()
                self:ResetRound()
            end )
        end
    end )

    -- Spawn boats for each player on each team
    local spawn0 = 1
    local spawn1 = 1
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
        self.spawnedBoats[#self.spawnedBoats]:BSSetTeam(v.team)
        self.spawnedBoats[#self.spawnedBoats]:Use(player.GetBySteamID64(k))
    end

    timer.Simple(5, function()
        if (!self:IsValid()) then return end

        self.bs_ball:GetPhysicsObject():EnableMotion(true)
        self.bs_ball:PhysWake()

        for k, v in pairs(self.spawnedBoats) do
            v:GetPhysicsObject():EnableMotion(true)
            v:PhysWake()
        end
    end )
end

function ENT:ResetRound()
    -- Resets the position of everything
    if (self:CheckScore()) then return end
    self:SetNWInt("round", self:GetNWInt("round", 1) + 1)
    self.bs_ball:GetPhysicsObject():EnableMotion(false)
    self.bs_ball:SetPos(self:LocalToWorld(Vector(0, 0, 80)))
    self.bs_ball:ResetBall()

    -- Spawn boats for each player on each team
    local spawn0 = 1
    local spawn1 = 1
    for k, v in pairs(self.spawnedBoats) do
        local pos
        local ang
        if (v.team == 0) then
            pos = self:LocalToWorld(boat_soccer_config.team0_spawns[spawn0])
            ang = self:LocalToWorldAngles(Angle(0, 0, 0))

            spawn0 = spawn0 + 1
            if (spawn0 > 5) then spawn0 = 1 end
        else
            pos = self:LocalToWorld(boat_soccer_config.team1_spawns[spawn1])
            ang = self:LocalToWorldAngles(Angle(0, 180, 0))

            spawn1 = spawn1 + 1
            if (spawn1 > 5) then spawn1 = 1 end
        end

        v:SetPos(pos)
        v:SetAngles(ang)
        v:GetPhysicsObject():EnableMotion(false)
    end

    timer.Simple(5, function()
        if (!self:IsValid()) then return end

        self.resetting = false

        self.bs_ball:GetPhysicsObject():EnableMotion(true)
        self.bs_ball:PhysWake()

        for k, v in pairs(self.spawnedBoats) do
            v:GetPhysicsObject():EnableMotion(true)
            v:PhysWake()
        end
    end )
end

function ENT:CheckScore()
    -- Checks score to see if anyone has won
    if (self:GetNWInt("score0", 0) >= boat_soccer_config.winningScore) then
        -- Team 0 has won
        print("Red team won!")
        self:EndGame()

        return true
    elseif (self:GetNWInt("score1", 0) >= boat_soccer_config.winningScore) then
        -- Team 1 has won
        print("Blue team won!")
        self:EndGame()

        return true
    end

    return false
end

function ENT:EndGame()
    -- Ends the game without actually removing the entity
    boat_soccer.controllers[self:EntIndex()].gameStarted = false
    self:SetNWInt("round", 1)
    self.resetting = false

    self:SetNWInt("score0", 0)
    self:SetNWInt("score1", 0)

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

    self.spawnedBoats = {}

    -- Remove goals and ball
    if (self.goal0 and self.goal0:IsValid()) then self.goal0:Remove() end
    if (self.goal1 and self.goal1:IsValid()) then self.goal1:Remove() end
    if (self.bs_ball and self.bs_ball:IsValid()) then self.bs_ball:Remove() end
end