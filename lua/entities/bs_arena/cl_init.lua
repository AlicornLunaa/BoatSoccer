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
                draw.DrawText(v.name, "bs_font_hud_text", -98, -68 + line, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
            else
                draw.DrawText(v.name, "bs_font_hud_text", 2, -68 + line, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
            end
            line = line + 8
        end
    cam.End3D2D()
end

local function DrawHUD(time, winner)
    local out = false
    local oldW, oldH = ScrW(), ScrH()
    render.SetViewPort(oldW / 2 - 250, 100, 500, 500)

    cam.Start2D()
        if (time != 6 and time != 0) then
            draw.RoundedBox(20, 190, 110, 112, 175, boat_soccer_config.neutral)

            surface.SetFont("bs_font_hud_large")
            surface.SetTextColor(255, 255, 255)
            surface.SetTextPos(197, 100)
            surface.DrawText(tostring(time))
        end

        if (winner != -1) then
            surface.SetFont("bs_font_hud_small")

            if (winner == 0) then
                -- Red wins
                draw.RoundedBox(20, 75, 88, 342, 75, boat_soccer_config.neutral)
                surface.SetTextPos(95, 100)
                surface.SetTextColor(boat_soccer_config.team0)
                surface.DrawText("Red team wins!")

                out = true
            else
                -- Blue wins
                draw.RoundedBox(20, 75, 88, 342, 75, boat_soccer_config.neutral)
                surface.SetTextPos(90, 100)
                surface.SetTextColor(boat_soccer_config.team1)
                surface.DrawText("Blue team wins!")

                out = true
            end
        end
    cam.End2D()

    render.SetViewPort(0, 0, oldW, oldH)
    return out
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

    if (boat_soccer_client.controllers[self:EntIndex()] != nil and boat_soccer_client.controllers[self:EntIndex()] != false) then
        DrawScoreboard(pos, ang, 0.5, boat_soccer_client.controllers[self:EntIndex()].players, self:GetNWInt("score0", 0))

        if (boat_soccer_client.joined != false) then
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

            if (DrawHUD(self.time, self:GetNWInt("winner", -1))) then
                -- Reset game
                self.lastGameStarted = false
            end
        end
    end
end