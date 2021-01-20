-- Client file initialization
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Include entity settings
include("shared.lua")

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
    self.turnSpeed = 10

    -- Start physics
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end
end

function ENT:Use( activator )
    -- Save driver
    if (activator:IsPlayer()) then
        if (!self.driver) then
            self.driver = activator

            print("Entered the boat")
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

        -- Vehicle exit
        if(self.driver:KeyPressed(IN_USE)) then
            print("Exitted the boat")

            self.driver = nil
        end
    end
    


    -- Faster update
    self:NextThink(CurTime())
    return true
end