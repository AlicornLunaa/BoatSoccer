-- Client file initialization
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Include entity settings
include("shared.lua")

-- Helper functions
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

-- Entity functions
function ENT:Initialize()
    -- Initialize entity
    self:SetModel("models/props_canal/boat002b.mdl")
    self:SetModelScale(0.25, 0)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    -- Initialize members
    self.driver = nil
    self.speed = 5000
    self.turnSpeed = 1

    -- Start physics
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:SetMass(100)
        phys:Wake()
    end
end

function ENT:Use( activator )
    -- Save driver
    if (activator:IsPlayer()) then
        if (!self.driver) then
            self.driver = activator

            activator:Spectate(OBS_MODE_CHASE)
            activator:SpectateEntity(self)
            activator:SetPos(Vector(0, 0, 100))

            print("Entered the boat")
        elseif (self.driver == activator) then
            print("Exitted the boat")
            
            self.driver:UnSpectate()
            self.driver = nil
        end
    end
end

function ENT:Think()
    -- Check for exit and other controls
    if (self.driver) then
        -- Movement
        local phys = self:GetPhysicsObject()

        if(self:WaterLevel() >= 1) then
            if(self.driver:KeyDown(IN_FORWARD)) then
                phys:ApplyForceCenter(self:GetForward() * self.speed)
            end

            if(self.driver:KeyDown(IN_BACK)) then
                phys:ApplyForceCenter(self:GetForward() * -self.speed)
            end
        end
        
        -- Set angles
        local targetAngle = self.driver:EyeAngles() - self:GetAngles() - self:GetLocalAngularVelocity() * 10
        applyTorque(self, Vector(-self:GetAngles().r * 0.1, 0, targetAngle.y * 1) * phys:GetMass())

        -- Vehicle exit
        if(self.driver:KeyPressed(IN_USE)) then
            print("Exitted the boat")

            self.driver:UnSpectate()
            self.driver = nil
        end
    end
    


    -- Faster update
    self:NextThink(CurTime())
    return true
end