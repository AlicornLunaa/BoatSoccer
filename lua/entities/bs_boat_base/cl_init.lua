-- Clientside boat initialization
include("shared.lua")
include("boat_soccer/cl_boat_hud.lua")

-- Create entity methods
function ENT:Initialize()
    self:SetValues()
    self.lastBoost = false
    boat_hud_spawned[self] = true
end

function ENT:OnRemove()
    boat_hud_spawned[self] = false
end

function ENT:Draw()
    self:DrawModel()

    local off = self.height or Vector(0, 3.75, 5)
    cam.Start3D2D(self:LocalToWorld(off), self:GetAngles(), 0.25)
        -- Draw name
        if (self:GetNWBool("driving") and LocalPlayer() != self:GetNWEntity("driver") and self:GetNWEntity("driver"):IsValid()) then
            draw.DrawText(self:GetNWEntity("driver"):Nick(), "bs_font_hud_name", 0, 0, self:GetColor(), TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()

    if self:GetNWBool("boosting", false) == true and self.lastBoost == false then
        self:EmitSound("boost")
        self.lastBoost = true
    elseif self:GetNWBool("boosting", false) == false and self.lastBoost == true then
        self:EmitSound("boost_end")
        self:StopSound("boost")
        self.lastBoost = false
    end
end