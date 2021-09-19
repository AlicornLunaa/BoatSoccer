AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("boat_soccer/sh_init.lua")

local function SpawnGoal(mdl, pos, ang)
    local e = ents.Create("prop_physics")
    e:SetModel(mdl)
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

local function ThrowBoats(boats, pos, strength)
    -- Pushes boats away from the position given
    for k, v in pairs(boats) do
        v:GetPhysicsObject():ApplyForceCenter((v:GetPos() - pos):GetNormalized() * strength)
    end
end

local function IntroScene(parent, pos, ang, ply)
    local bsCam = ents.Create("bs_camera")
    bsCam:Spawn()
    bsCam:InitTransition(parent, Vector(0, 0, 150), Angle(0, 0, 0))
    bsCam:SetTransition(Vector(-200, 200, 0), Angle(25, 0, 0), 0.01)
    bsCam:SetTransition(Vector(0, -200, 0), Angle(2, 0, 0), 1)
    bsCam:SetTransition(Vector(0, -200, 0), Angle(-2, 0, 0), 1)
    bsCam:SetTransition(Vector(800, 300, 0), Angle(0, 180, 0), 2)
    bsCam:SetTransition(Vector(0, -200, 0), Angle(2, 0, 0), 1)
    bsCam:SetTransition(Vector(0, -200, 0), Angle(-2, 0, 0), 1)
    bsCam:StartTransition(ply)
end

local function IsInGame(ply)
    -- Checks if a player is in another game
    for index, controller in pairs(boat_soccer.controllers) do
        if (!controller) then continue end

        for id, player in pairs(controller.players) do
            if (ply:SteamID64() == id) then
                return index
            end
        end
    end

    return false
end

function ENT:ArenaInit(mdl, goalMdl)
    -- Initialize an arena
    self:SetModel(mdl)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    -- Initialize members
    self.goalMdl = goalMdl
    self.goal0 = nil
    self.goal1 = nil
    self.bs_ball = nil
    self.spawnedBoats = {}
    self.resetting = false
    boat_soccer.controllers[self:EntIndex()] = {}
    boat_soccer.controllers[self:EntIndex()].entity = self
    boat_soccer.controllers[self:EntIndex()].playerCount = 0
    boat_soccer.controllers[self:EntIndex()].players = {}
    boat_soccer.controllers[self:EntIndex()].gameStarted = false
    boat_soccer.controllers[self:EntIndex()].counting = false
    boat_soccer.controllers[self:EntIndex()].settings = {
        winningScore = boat_soccer_config.winningScoreDefault,
        matchLength = boat_soccer_config.matchLengthDefault,
        boostDrain = boat_soccer_config.boostDrainDefault,
        boostRegen = boat_soccer_config.boostRegenDefault,
        boostMultiply = boat_soccer_config.boostMultiplyDefault
    }

    -- Networked variables
    self:SetNWInt("score0", 0)
    self:SetNWInt("score1", 0)
    self:SetNWInt("round", 1)
    self:SetNWInt("winner", -1)
    self:SetNWBool("overtime", false)

    -- Phys init
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:SetMass(1000)
        phys:Wake()
    end

    -- Update values
    boat_soccer.UpdateControllerClient()
end

function ENT:Initialize()
    -- Default
    self:ArenaInit("models/boat_soccer/arena0.mdl", "models/boat_soccer/goal0.mdl")
end

function ENT:GetSettings()
    return boat_soccer.controllers[self:EntIndex()].settings
end

function ENT:Use( activator, caller )
    if (activator:IsValid() and activator:IsPlayer() and !boat_soccer.controllers[self:EntIndex()].gameStarted and (IsInGame(activator) == false or IsInGame(activator) == self:EntIndex())) then
        -- Send the information to the clients
        boat_soccer.OpenMenu(activator, self:EntIndex())
    end
end

function ENT:SpawnFunction(ply, tr, className)
    if (tr.Hit) then
        local pos = tr.HitPos + tr.HitNormal * 500 + Vector(0, 0, 100)
        local ang = ply:EyeAngles()
        ang.p = 0
        ang.y = ang.y + 180

        local ent = ents.Create(className)
        ent:SetPos(pos)
        ent:SetAngles(ang)
        ent:Spawn()
        ent:Activate()

        return ent
    else
        local pos = ply:EyePos() + ply:EyeAngles():Forward() * 1500
        local ang = ply:EyeAngles()
        ang.p = 0
        ang.y = ang.y + 180

        local ent = ents.Create(className)
        ent:SetPos(pos)
        ent:SetAngles(ang)
        ent:Spawn()
        ent:Activate()

        return ent
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

    -- Check ball position
    if (self.bs_ball and self.bs_ball:IsValid() and !timer.Exists("ballCheck")) then
        -- Casting a ray to the center of the arena that only collides with the arena will give a rough answer
        -- if the ball is inside the arena or out.
        local function isHittingArena()
            local res = util.TraceLine({
                start = self.bs_ball:GetPos(),
                endpos = self:GetPos(),
                filter = function(e)
                    if e == self then return true end
                    return false
                end,
                ignoreworld = true
            })
            return res.Hit
        end

        if isHittingArena() then
            timer.Create("ballCheck", 6, 1, function()
                -- Check if the ball is still out of bounds after 6 seconds
                if self.bs_ball and self.bs_ball:IsValid() and isHittingArena() then
                    -- Reset the ball
                    self.bs_ball:SetPos(self:GetPos())
                end
            end )
        end
    end

    -- Update entity client
    boat_soccer.UpdateControllerClient()

    -- Faster update
    self:NextThink(CurTime())
    return true
end

function ENT:OnRemove()
    -- Cleanup
    timer.Stop("roundTime")

    -- Force every player to leave
    for k, v in pairs(boat_soccer.controllers[self:EntIndex()].players) do
        if (!player.GetBySteamID64(k)) then continue end

        boat_soccer.ForceLeave(player.GetBySteamID64(k))
        boat_soccer.CloseDerma(player.GetBySteamID64(k))
    end

    -- Delete every boat
    for k, v in pairs(self.spawnedBoats) do
        if (v:IsValid()) then
            v:Remove()
        end
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
    self.goal0 = SpawnGoal(self.goalMdl, self:GetPos(), self:LocalToWorldAngles(Angle(0, 180, 0)))
    self.goal1 = SpawnGoal(self.goalMdl, self:GetPos(), self:LocalToWorldAngles(Angle(0, 0, 0)))
    self.bs_ball = SpawnBall(self:LocalToWorld(Vector(0, 0, 80)))

    constraint.NoCollide(self, self.goal0, 0, 0)
    constraint.NoCollide(self, self.goal1, 0, 0)

    -- Callbacks for goals
    self.goal0:AddCallback("PhysicsCollide", function(e, data)
        if (data.HitEntity == self.bs_ball and !self.resetting) then
            boat_soccer.controllers[self:EntIndex()].counting = false
            timer.Pause("roundTime")

            self.resetting = true
            self:SetNWInt("score0", self:GetNWInt("score0", 0) + 1)

            ThrowBoats(self.spawnedBoats, self.bs_ball:GetPos(), boat_soccer_config.throwForce)
            self.bs_ball:GetPhysicsObject():EnableMotion(false)
            self.bs_ball:ScoreAnim()

            timer.Simple(2, function()
                if (!self:IsValid()) then return end
                self:ResetRound()
            end )
        end
    end )

    self.goal1:AddCallback("PhysicsCollide", function(e, data)
        if (data.HitEntity == self.bs_ball and !self.resetting) then
            boat_soccer.controllers[self:EntIndex()].counting = false
            timer.Pause("roundTime")

            self.resetting = true
            self:SetNWInt("score1", self:GetNWInt("score1", 0) + 1)

            ThrowBoats(self.spawnedBoats, self.bs_ball:GetPos(), boat_soccer_config.throwForce)
            self.bs_ball:GetPhysicsObject():EnableMotion(false)
            self.bs_ball:ScoreAnim()

            timer.Simple(2, function()
                if (!self:IsValid()) then return end
                self:ResetRound()
            end )
        end
    end )

    -- Round timer
    timer.Create("roundTime", self:GetSettings().matchLength, 1, function()
        -- End round
        boat_soccer.controllers[self:EntIndex()].counting = false
        self.resetting = true

        ThrowBoats(self.spawnedBoats, self.bs_ball:GetPos(), boat_soccer_config.throwForce)
        self.bs_ball:GetPhysicsObject():EnableMotion(false)
        self.bs_ball:ScoreAnim()

        timer.Simple(2, function()
            if (self:CalcWinnerForced() == -1) then
                -- Start overtime
                self:Overtime()
                self:SetNWBool("overtime", true)
            end
        end )
    end )

    -- Spawn boats for each player on each team
    local spawn0 = 1
    local spawn1 = 1
    local introRiders = {}
    for k, v in pairs(boat_soccer.controllers[self:EntIndex()].players) do
        introRiders[#introRiders + 1] = player.GetBySteamID64(k)
        boat_soccer.CloseDerma(player.GetBySteamID64(k))

        local pos
        local ang
        local color
        if (v.team == 0) then
            pos = self:LocalToWorld(boat_soccer_config.team0_spawns[spawn0])
            ang = self:LocalToWorldAngles(Angle(0, 180, 0))
            color = boat_soccer_config.team0

            spawn0 = spawn0 + 1
            if (spawn0 > 5) then spawn0 = 1 end
        else
            pos = self:LocalToWorld(boat_soccer_config.team1_spawns[spawn1])
            ang = self:LocalToWorldAngles(Angle(0, 0, 0))
            color = boat_soccer_config.team1

            spawn1 = spawn1 + 1
            if (spawn1 > 5) then spawn1 = 1 end
        end

        ang.p = 0
        ang.r = 0

        self.spawnedBoats[#self.spawnedBoats + 1] = ents.Create(boat_soccer_config.boats[v.boatType].class)
        self.spawnedBoats[#self.spawnedBoats]:SetPos(pos)
        self.spawnedBoats[#self.spawnedBoats]:SetAngles(ang)
        self.spawnedBoats[#self.spawnedBoats]:SetColor(color)
        self.spawnedBoats[#self.spawnedBoats]:Spawn()
        self.spawnedBoats[#self.spawnedBoats]:GetPhysicsObject():EnableMotion(false)
        self.spawnedBoats[#self.spawnedBoats]:BSSetTeam(v.team)
        self.spawnedBoats[#self.spawnedBoats]:SetValues(self:GetSettings().boostDrain, self:GetSettings().boostRegen, self:GetSettings().boostMultiply)
        self.spawnedBoats[#self.spawnedBoats]:Use(player.GetBySteamID64(k))
    end

    IntroScene(self, self:LocalToWorld(Vector(0, 0, 150)), self:LocalToWorldAngles(Angle(0, 0, 0)), introRiders)

    timer.Simple(boat_soccer_config.setupLength, function()
        if (!self:IsValid()) then return end

        self.bs_ball:GetPhysicsObject():EnableMotion(true)
        self.bs_ball:PhysWake()

        for k, v in pairs(self.spawnedBoats) do
            v:GetPhysicsObject():EnableMotion(true)
            v:PhysWake()
        end

        boat_soccer.controllers[self:EntIndex()].counting = true
        timer.Start("roundTime")
    end )
end

function ENT:ResetRound()
    -- Resets the position of everything
    if (self:CheckScore()) then return end
    self:SetNWInt("round", self:GetNWInt("round", 1) + 1)
    self.bs_ball:GetPhysicsObject():EnableMotion(false)
    self.bs_ball:SetPos(self:LocalToWorld(Vector(0, 0, 80)))
    self.bs_ball:ResetBall()

    timer.Pause("roundTime")

    -- Spawn boats for each player on each team
    local spawn0 = 1
    local spawn1 = 1
    local introRiders = {}
    for k, v in pairs(self.spawnedBoats) do
        if (v.driver and v.driver:IsValid()) then
            introRiders[#introRiders + 1] = v.driver
        end

        local pos
        local ang
        if (v.team == 0) then
            pos = self:LocalToWorld(boat_soccer_config.team0_spawns[spawn0])
            ang = self:LocalToWorldAngles(Angle(0, 180, 0))

            spawn0 = spawn0 + 1
            if (spawn0 > 5) then spawn0 = 1 end
        else
            pos = self:LocalToWorld(boat_soccer_config.team1_spawns[spawn1])
            ang = self:LocalToWorldAngles(Angle(0, 0, 0))

            spawn1 = spawn1 + 1
            if (spawn1 > 5) then spawn1 = 1 end
        end

        ang.p = 0
        ang.r = 0

        v:SetPos(pos)
        v:SetAngles(ang)
        v:GetPhysicsObject():EnableMotion(false)
    end

    IntroScene(self, self:LocalToWorld(Vector(0, 0, 150)), self:LocalToWorldAngles(Angle(0, 0, 0)), introRiders)

    timer.Simple(boat_soccer_config.setupLength, function()
        if (!self:IsValid()) then return end

        self.resetting = false

        self.bs_ball:GetPhysicsObject():EnableMotion(true)
        self.bs_ball:PhysWake()

        for k, v in pairs(self.spawnedBoats) do
            v:GetPhysicsObject():EnableMotion(true)
            v:PhysWake()
        end

        boat_soccer.controllers[self:EntIndex()].counting = true
        timer.UnPause("roundTime")
    end )
end

function ENT:Overtime()
    -- Resets the position of everything
    if (self:CheckScore()) then return end
    self:SetNWInt("round", self:GetNWInt("round", 1) + 1)
    self.bs_ball:GetPhysicsObject():EnableMotion(false)
    self.bs_ball:SetPos(self:LocalToWorld(Vector(0, 0, 80)))
    self.bs_ball:ResetBall()

    -- Spawn boats for each player on each team
    local spawn0 = 1
    local spawn1 = 1
    local introRiders = {}
    for k, v in pairs(self.spawnedBoats) do
        if (v.driver and v.driver:IsValid()) then
            introRiders[#introRiders + 1] = v.driver
        end

        local pos
        local ang
        if (v.team == 0) then
            pos = self:LocalToWorld(boat_soccer_config.team0_spawns[spawn0])
            ang = self:LocalToWorldAngles(Angle(0, 180, 0))

            spawn0 = spawn0 + 1
            if (spawn0 > 5) then spawn0 = 1 end
        else
            pos = self:LocalToWorld(boat_soccer_config.team1_spawns[spawn1])
            ang = self:LocalToWorldAngles(Angle(0, 0, 0))

            spawn1 = spawn1 + 1
            if (spawn1 > 5) then spawn1 = 1 end
        end

        ang.p = 0
        ang.r = 0

        v:SetPos(pos)
        v:SetAngles(ang)
        v:GetPhysicsObject():EnableMotion(false)
    end

    IntroScene(self, self:LocalToWorld(Vector(0, 0, 150)), self:LocalToWorldAngles(Angle(0, 0, 0)), introRiders)

    timer.Simple(boat_soccer_config.setupLength, function()
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
    if (!self:GetNWBool("overtime", false)) then
        if (self:GetNWInt("score0", 0) >= self:GetSettings().winningScore) then
            -- Team 0 has won
            self:SetNWInt("winner", 0)
            self:EndGame()

            return true
        elseif (self:GetNWInt("score1", 0) >= self:GetSettings().winningScore) then
            -- Team 1 has won
            self:SetNWInt("winner", 1)
            self:EndGame()

            return true
        end
    else
        if (self:GetNWInt("score0", 0) > self:GetNWInt("score1", 0)) then
            -- Team 0 has won
            self:SetNWInt("winner", 0)
            self:EndGame()

            return true
        else
            -- Team 1 has won
            self:SetNWInt("winner", 1)
            self:EndGame()

            return true
        end
    end

    return false
end

function ENT:CalcWinnerForced()
    if (self:GetNWInt("score0", 0) == self:GetNWInt("score1", 0)) then
        -- Tie
        return -1
    elseif (self:GetNWInt("score0", 0) > self:GetNWInt("score1", 0)) then
        self:SetNWInt("winner", 0)
        self:EndGame()
        return 0
    else
        self:SetNWInt("winner", 1)
        self:EndGame()
        return 1
    end
end

function ENT:EndGame()
    -- Ends the game without actually removing the entity
    boat_soccer.controllers[self:EntIndex()].counting = false
    boat_soccer.controllers[self:EntIndex()].gameStarted = false
    self:SetNWBool("overtime", false)
    self.resetting = false
    timer.Remove("roundTime")
    timer.Remove("ballCheck")

    -- Delete every boat
    for k, v in pairs(self.spawnedBoats) do
        v:Remove()
    end

    self.spawnedBoats = {}

    -- Remove goals and ball
    if (self.goal0 and self.goal0:IsValid()) then self.goal0:Remove() end
    if (self.goal1 and self.goal1:IsValid()) then self.goal1:Remove() end
    if (self.bs_ball and self.bs_ball:IsValid()) then self.bs_ball:Remove() end

    -- Reset winner
    timer.Simple(5, function()
        if boat_soccer.controllers[self:EntIndex()] != nil then
            self:SetNWInt("winner", -1)

            -- Force every player to leave
            for k, v in pairs(boat_soccer.controllers[self:EntIndex()].players) do
                if (!player.GetBySteamID64(k)) then continue end

                boat_soccer.ForceLeave(player.GetBySteamID64(k))
                boat_soccer.CloseDerma(player.GetBySteamID64(k))
            end

            -- Reset game
            self:Initialize()
            self:GetPhysicsObject():EnableMotion(false)
        end
    end )
end