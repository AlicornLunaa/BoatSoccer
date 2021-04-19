include("shared.lua")
include("boat_soccer/sh_init.lua")

local function DrawScoreboard(pos, ang, scale, players, score0)
    cam.Start3D2D(pos, ang, scale)
        -- Title
        draw.RoundedBox(1, -100, -80, 200, 15, boat_soccer_config.neutral)
        draw.DrawText("Boat Soccer " .. score0, "Trebuchet18", 0, -80, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

        -- Backgrounds
        draw.RoundedBox(0, -100, -65, 100, 85, boat_soccer_config.team0)
        draw.RoundedBox(0, 0, -65, 100, 85, boat_soccer_config.team1)
        draw.RoundedBox(0, -100, 20, 200, 15, boat_soccer_config.neutral)

        -- Player list
        line = 0
        for k, v in pairs(players) do
            if (v.team == 0) then
                draw.DrawText(v.name, "Trebuchet16", -98, -68 + line, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
            else
                draw.DrawText(v.name, "Trebuchet16", 2, -68 + line, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
            end
            line = line + 8
        end
    cam.End3D2D()
end

function ENT:Draw()
    self:DrawModel()

    local _, maxs = self:GetModelBounds()
    local pos = self:LocalToWorld(Vector(0, 0, maxs.z + 48))
    local toPlayer = pos - LocalPlayer():GetPos()
    local worldAng = self:WorldToLocalAngles(Angle(0, -math.deg(math.atan2(toPlayer.x, toPlayer.y)), 0))
    local ang = self:LocalToWorldAngles(Angle(0, worldAng.y, 90))

    if (boat_soccer_client.controllers[self:EntIndex()] != nil) then
        DrawScoreboard(pos, ang, 0.5, boat_soccer_client.controllers[self:EntIndex()].players, self:GetNWInt("score0", 0))
    end
end