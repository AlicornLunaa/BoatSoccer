AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self.ply = nil
    self.frames = {}
    self.running = false
    self.currentFrame = 2
    self.deltaTime = 0

    self.prevPos = Vector(0, 0, 0)
    self.prevRot = Angle(0, 0, 0)
end

function ENT:Think()
    if (self.running) then
        self.deltaTime = self.deltaTime + FrameTime()

        local thisFrame = self.frames[self.currentFrame]
        local prevFrame = self.frames[self.currentFrame - 1]
        local interpolation = self.deltaTime / thisFrame.time

        local thisPos = (thisFrame.pos * interpolation)
        local thisAng = (thisFrame.ang * interpolation)

        self:SetPos(thisPos + self.prevPos)
        self:SetAngles(thisAng + self.prevRot)

        -- Reset time
        if (self.deltaTime >= thisFrame.time) then
            self.prevPos = self.prevPos + thisPos
            self.prevRot = self.prevRot + thisAng

            self.currentFrame = self.currentFrame + 1
            self.deltaTime = 0
        end

        -- End
        if (self.currentFrame >= #self.frames) then
            self:Remove()
            return
        end
    end

    -- Faster update
    self:NextThink(CurTime())
    return true
end

function ENT:OnRemove()
    if (istable(self.ply)) then
        for k, v in pairs(self.ply) do
            if (v and v:IsValid()) then
                v:SetViewEntity(v)
            end
        end
    else
        if (self.ply and self.ply:IsValid()) then
            self.ply:SetViewEntity(self.ply)
        end
    end
end

-- Functions
function ENT:InitTransition(pos, ang)
    self.frames[#self.frames + 1] = {
        ["pos"] = pos,
        ["ang"] = ang,
        time = 0
    }

    self.prevPos = pos
    self.prevRot = ang
end

function ENT:SetTransition(pos, ang, t)
    self.frames[#self.frames + 1] = {
        ["pos"] = pos,
        ["ang"] = ang,
        time = t
    }
end

function ENT:AddTransition(pos, ang, t)
    local prevFrame = self.frames[#self.frames]

    self.frames[#self.frames + 1] = {
        ["pos"] = prevFrame.pos + pos,
        ["ang"] = prevFrame.ang + ang,
        time = t
    }
end

function ENT:StartTransition(ply)
    self.ply = ply

    self.frames[#self.frames + 1] = self.frames[#self.frames]

    self:SetPos(self.frames[1].pos)
    self:SetAngles(self.frames[1].ang)

    if (istable(self.ply)) then
        for k, v in pairs(self.ply) do
            if (v and v:IsValid()) then
                v:SetViewEntity(self)
            end
        end
    else
        if (self.ply and self.ply:IsValid()) then
            self.ply:SetViewEntity(self)
        end
    end

    self.running = true
end