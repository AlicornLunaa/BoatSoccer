include("shared.lua")
include("boat_soccer/sh_init.lua")

function ENT:Initialize()
    boat_soccer_client.balls[self] = true
end

function ENT:OnRemove()
    boat_soccer_client.balls[self] = nil
end

function ENT:Draw()
    self:DrawModel()
end

hook.Add("PreDrawHalos", "boat_soccer:draw_ball_halo", function()
    for k, v in pairs(boat_soccer_client.balls) do
        local color = Color(255, 255, 255)
        if (k:GetNWInt("team", -1) == 0) then
            color = boat_soccer_config.team0
        elseif (k.team == 1) then
            color = boat_soccer_config.team1
        end

        halo.Add({ k }, color, 5, 5, 2, true, false)
    end
end )