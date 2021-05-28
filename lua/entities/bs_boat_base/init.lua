-- Client file initialization
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Include entity settings
include("shared.lua")
include("boat_soccer/sh_init.lua")

-- Helper functions
local function coefficient(number)
    if (number < 0) then
        return -1
    elseif (number > 0) then
        return 1
    else
        return 0
    end
end

local function applyTorque(ent, force)
    local phys = ent:GetPhysicsObject()
    local direction = phys:LocalToWorld(force) - ent:GetPos()
    local power = force:Length()

    local offset
    if (math.abs(direction.x) > power * 0.1 or math.abs(direction.z) > power * 0.1) then
        offset = Vector(-direction.z, 0, direction.x)
    else
        offset = Vector(-direction.y, direction.x, 0)
    end
    offset = offset:GetNormal() * power * 0.5
    direction = direction:Cross(offset):GetNormal()

    phys:ApplyForceOffset(direction, offset)
    phys:ApplyForceOffset(-direction, -offset)
end

function ENT:ExitBoat(activator)
    -- Runs exit sequence
    self.driver:UnSpectate()
    self.driver:Spawn()
    self.driver:SetPos(self:GetPos() + Vector(0, 0, 50))
    self.driver = nil
    self:SetNWBool("driving", false)
end

function ENT:SetValues(drain, regen, multiplier)
    self.boostDrain = drain
    self.boostRegen = regen
    self.boostMultiply = multiplier
end

function ENT:InitializeData()
    -- Phys settings
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    -- Initialize members
    self.driver = nil
    self.speed = 1000
    self.turnSpeed = 1
    self.jumpForce = 500
    self.multiplier = 1
    self.boostMultiply = 3
    self.boostDrain = 1
    self.boostRegen = 1
    self.bs_buoyancy = 1
    self.offset = Angle(0, 0, 0)
    self.team = -1
    self.camera = nil
    self.boosting = false
    self.trail = nil
    self.lastPosition = self:GetPos()

    -- Networked variables
    self:SetNWBool("driving", false)
    self:SetNWFloat("boost", 33)
end

function ENT:InitPhys()
    -- Start physics
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:SetMass(100)
        phys:SetBuoyancyRatio(self.bs_buoyancy)
        phys:Wake()
    end

    self:Activate()
end

-- Entity functions
function ENT:Initialize()
    -- Initialize entity
    self:SetModel("models/props_canal/boat002b.mdl")
    self:SetModelScale(0.25, 0)
    self:InitializeData()
    self:InitPhys()
end

function ENT:Use( activator )
    -- Save driver
    if (activator:IsPlayer()) then
        if (!self.driver) then
            self.driver = activator
            self:SetNWEntity("driver", self.driver)
            self:SetNWBool("driving", true)

            activator:Spectate(OBS_MODE_CHASE)
            activator:SpectateEntity(self)
            activator:SetPos(Vector(0, 0, 100))
            activator:StripWeapons()
        elseif (self.driver == activator) then
            self:ExitBoat(activator)
        end
    end
end

function ENT:Think()
    -- Check for exit and other controls
    if (self.driver) then
        -- Movement
        local phys = self:GetPhysicsObject()
        local forward = (self:GetAngles() - self.offset):Forward()
        local right = (self:GetAngles() - self.offset):Right()

        if (self:WaterLevel() >= 1) then
            if (self.driver:KeyDown(IN_FORWARD)) then
                phys:ApplyForceCenter(forward * self.speed * self.multiplier)
            end

            if (self.driver:KeyDown(IN_BACK)) then
                phys:ApplyForceCenter(forward * -self.speed * self.multiplier)
            end

            --[[if (self.driver:KeyDown(IN_MOVELEFT)) then
                phys:ApplyForceCenter(right * -self.speed / self.multiplier)
            end

            if (self.driver:KeyDown(IN_MOVERIGHT)) then
                phys:ApplyForceCenter(right * self.speed / self.multiplier)
            end]]

            if (self.driver:KeyDown(IN_SPEED) and self:GetNWFloat("boost", 0) > 0) then
                -- Boost
                self.multiplier = self.boostMultiply

                if (self:GetNWFloat("boost", 0) >= 1) then
                    if (self.boosting == false) then
                        self.trail = util.SpriteTrail(self, 0, self:GetColor(), false, 15, 1, 1 / 2, 1 / 32, "trails/laser")
                    end

                    self.trail:SetKeyValue("Lifetime", tostring(self:GetVelocity():Length() / 300))
                end

                self:SetNWFloat("boost", math.max(self:GetNWFloat("boost", 0) - self.boostDrain, 0))
                self.boosting = true
            else
                self.multiplier = 1

                if (self.boosting == true and self.trail and self.trail:IsValid()) then
                    self.trail:Remove()
                end

                self:SetNWFloat("boost", math.min(self:GetNWFloat("boost", 0) + self.boostRegen, 100))
                self.boosting = false
            end
        end

        -- Set angles
        local movementDirection = coefficient((self:GetPos() * forward - self.lastPosition * forward):GetNormalized().x)
        self.lastPosition = self:GetPos()

        local forwardVel = (self:GetVelocity() * forward):Length() / 8 * movementDirection
        local rotationScale = self:GetVelocity():Length() / 500
        local _, localAng = WorldToLocal(self:GetPos(), self:GetAngles(), self.driver:GetPos(), self.driver:EyeAngles() + self.offset)
        localAng.y = math.Clamp(localAng.y + (self:GetPhysicsObject():GetAngleVelocity() * 0.1).z, -45, 45) / self.multiplier
        localAng.z = math.Clamp(self:GetAngles().z + (self:GetPhysicsObject():GetAngleVelocity() * 0.1).x, -45, 45) * 5

        if (self:LocalToWorldAngles(self.offset).p <= 45 and self:LocalToWorldAngles(self.offset).p >= -45) then
            applyTorque(self, Vector(-localAng.z * 0.5, -forwardVel, localAng.y * -10 * rotationScale) * phys:GetMass())
        end

        -- Vehicle exit
        if (self.driver:KeyPressed(IN_USE)) then
            self:ExitBoat(activator)
        end
    end

    -- Faster update
    self:NextThink(CurTime())
    return true
end

function ENT:OnRemove()
    if (self.driver != nil) then
        self:ExitBoat(self.driver)
    end
end

function ENT:BSSetTeam(team)
    self.team = team
end