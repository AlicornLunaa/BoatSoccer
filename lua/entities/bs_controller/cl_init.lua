include("shared.lua")

local function DrawScoreboard(pos, ang, scale, players)
    cam.Start3D2D(pos, ang, scale)
        -- Title
        draw.RoundedBox(1, -50, -80, 100, 15, Color(53, 53, 53, 200))
        draw.DrawText("Boat Soccer", "Trebuchet18", 0, -80, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

        -- Background
        draw.RoundedBox(1, -50, -65, 100, 85, Color(141, 141, 141, 200))

        -- Player list
        for k, v in pairs(players) do
            draw.DrawText(v.name, "Trebuchet18", 0, -68, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
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