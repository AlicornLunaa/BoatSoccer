AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube05x1x025.mdl")
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    self.collisionWall = ents.Create("prop_physics")
    self.collisionWall:SetModel("models/hunter/blocks/cube05x1x025.mdl")
    self.collisionWall:SetPos(Vector(0, 0, 0))
    self.collisionWall:SetAngles(self:LocalToWorldAngles(Angle(90, 0, 0)))
    self.collisionWall:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self.collisionWall:SetColor(Color(255, 255, 255, 0))
    self.collisionWall:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self.collisionWall:AddCallback("PhysicsCollide", function(wall, data)
        if (self.bs_ball and self.bs_ball:IsValid()) then
            local target = data.HitEntity

            if (target:EntIndex() == self.bs_ball:EntIndex()) then
                -- Goal made
            end
        end
    end )

    self.bs_ball = nil

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:SetMass(100)
        phys:EnableMotion(false)
        phys:Wake()
    end
end

function ENT:Use( activator, caller )
    return
end

function ENT:Think()
    -- Check if something is inside
    if (self.bs_ball and self.bs_ball:IsValid()) then
        if (self.collisionWall:IsValid()) then
            self.collisionWall:SetPos(self:LocalToWorld(Vector(-6, 0, 16)))
            self.collisionWall:SetAngles(self:LocalToWorldAngles(Angle(90, 0, 0)))
            self.collisionWall:SetCollisionGroup(COLLISION_GROUP_NONE)
            self.collisionWall:GetPhysicsObject():EnableMotion(false)
        else
            self:Remove()
        end
    end

    self:NextThink(CurTime())
    return true
end

function ENT:OnRemove()
    if (self.collisionWall and self.collisionWall:IsValid()) then
        self.collisionWall:Remove()
    end

    if (self.bs_ball and self.bs_ball:IsValid()) then
        self.bs_ball:Remove()
    end
end

function ENT:SetBall(entity)
    self.bs_ball = entity
    self.collisionWall:Spawn()
end