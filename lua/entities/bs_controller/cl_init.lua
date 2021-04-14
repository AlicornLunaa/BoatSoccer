include("shared.lua")
include("boat_soccer/sh_init.lua")

local function DrawScoreboard(pos, ang, scale, players)
    cam.Start3D2D(pos, ang, scale)
        -- Title
        draw.RoundedBox(1, -100, -80, 200, 15, Color(53, 53, 53, 200))
        draw.DrawText("Boat Soccer", "Trebuchet18", 0, -80, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

        -- Backgrounds
        draw.RoundedBox(0, -100, -65, 100, 85, boat_soccer_config.team0)
        draw.RoundedBox(0, 0, -65, 100, 85, boat_soccer_config.team1)

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
    local pos = self:LocalToWorld(Vector(0, 0, maxs.z + 4))
    local ang = self:LocalToWorldAngles(Angle(0, 90, 90))

    if (boat_soccer_client.controllers[self:EntIndex()] != nil) then
        DrawScoreboard(pos, ang, 0.5, boat_soccer_client.controllers[self:EntIndex()].players)
    end
end