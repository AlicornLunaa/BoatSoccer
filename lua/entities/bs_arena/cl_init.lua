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

local function DrawHUD(time)
    local oldW, oldH = ScrW(), ScrH()
    render.SetViewPort(100, 100, 500, 500)

    cam.Start2D()
        if (time != 6 and time != 0) then
            surface.SetFont("bs_font_hud")
            surface.SetTextColor(255, 255, 255)
            surface.SetTextPos(100, 100)
            surface.DrawText(tostring(time))
        end
    cam.End2D()

    render.SetViewPort(0, 0, oldW, oldH)
end

function ENT:Initialize()
    self.time = 6
    self.lastGameStarted = false
    self.lastRound = self:GetNWInt("round", 1)
end

function ENT:Draw()
    self:DrawModel()

    local _, maxs = self:GetModelBounds()
    local pos = self:LocalToWorld(Vector(0, 0, maxs.z + 48))
    local toPlayer = pos - LocalPlayer():GetPos()
    local worldAng = self:WorldToLocalAngles(Angle(0, -math.deg(math.atan2(toPlayer.x, toPlayer.y)), 0))
    local ang = self:LocalToWorldAngles(Angle(0, worldAng.y, 90))
    print(self:GetNWInt("round", 1) .. " " .. self.lastRound)

    if (boat_soccer_client.controllers[self:EntIndex()] != nil and boat_soccer_client.controllers[self:EntIndex()] != false) then
        -- Check if the game started to start a countdown
        if ((boat_soccer_client.controllers[self:EntIndex()].gameStarted != self.lastGameStarted and self.lastGameStarted == false) or (self:GetNWInt("round", 1) != self.lastRound and boat_soccer_client.controllers[self:EntIndex()].gameStarted == true)) then
            self.lastGameStarted = boat_soccer_client.controllers[self:EntIndex()].gameStarted
            self.lastRound = self:GetNWInt("round", 1)
            self.time = 5

            for i=1,5 do
                timer.Simple(i, function()
                    self.time = self.time - 1
                end )
            end
        end

        DrawScoreboard(pos, ang, 0.5, boat_soccer_client.controllers[self:EntIndex()].players, self:GetNWInt("score0", 0))
        DrawHUD(self.time)
    end
end