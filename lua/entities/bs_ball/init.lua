AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("boat_soccer/sh_init.lua")

function ENT:Initialize()
    self:SetModel("models/props_phx/misc/soccerball.mdl")
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    self.bs_buoyancy = 2

    self:SetNWInt("team", -1)
    self.trailEnt = util.SpriteTrail(self, 0, Color(10, 10, 10), false, 15, 1, 1 / 2, 1 / 32, "trails/plasma")

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:SetMass(50)
        phys:SetBuoyancyRatio(self.bs_buoyancy)
        phys:Wake()
    end
end

function ENT:PhysicsCollide(data, obj)
    -- Set color of the ball to the last team who touched it
    if (data.HitEntity.Base == "bs_boat_base") then
        local phys = self:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:AddVelocity(data.OurNewVelocity * 1.25)
        end

        local team = data.HitEntity.team
        if (team == 0) then
            self.trailEnt:SetKeyValue("rendercolor", string.format("%d %d %d", boat_soccer_config.team0.r, boat_soccer_config.team0.g, boat_soccer_config.team0.b))
            self:SetColor(boat_soccer_config.team0)
            self:SetNWInt("team", 0)
        else
            self.trailEnt:SetKeyValue("rendercolor", string.format("%d %d %d", boat_soccer_config.team1.r, boat_soccer_config.team1.g, boat_soccer_config.team1.b))
            self:SetColor(boat_soccer_config.team1)
            self:SetNWInt("team", 1)
        end
    end
end

function ENT:Use( activator, caller )
    return
end

function ENT:ResetBall()
    self.trailEnt:SetKeyValue("rendercolor", "10 10 10")
    self:SetColor(Color(255, 255, 255))
    self:SetNWInt("team", -1)
end

function ENT:ScoreAnim()
    self:ResetBall()
    local explosion = ents.Create("env_explosion")
    explosion:SetPos(self:GetPos())
    explosion:Spawn()
    explosion:SetKeyValue("iMagnitude", "0")
    explosion:Fire("Explode", 0, 0)

    self:SetPos(Vector(0, 0, 0))
end