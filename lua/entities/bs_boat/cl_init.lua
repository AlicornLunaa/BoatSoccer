-- Clientside boat initialization
include("shared.lua")
include("boat_soccer/cl_boat_hud.lua")

-- Create entity methods
function ENT:Initialize()
    boat_hud_spawned[self] = true
end

function ENT:OnRemove()
    boat_hud_spawned[self] = false
end

function ENT:Draw()
    self:DrawModel()
end