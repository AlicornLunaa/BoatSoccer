include("shared.lua")
include("boat_soccer/sh_init.lua")

local function DrawCentered(roundness, x, y, w, h, c)
    draw.RoundedBox(roundness, x - w / 2, y - h / 2, w, h, c)
end

local function DrawScoreboard(pos, ang, scale, players, score0, score1)
    cam.Start3D2D(pos, ang, scale)
        -- Title
        draw.RoundedBox(1, -100, -80, 200, 15, boat_soccer_config.neutral)
        draw.DrawText("Boat Soccer", "Trebuchet18", 0, -80, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

        -- Backgrounds
        draw.RoundedBox(0, -100, -65, 100, 85, boat_soccer_config.team0)
        draw.RoundedBox(0, 0, -65, 100, 85, boat_soccer_config.team1)
        draw.RoundedBox(0, -100, 20, 200, 15, boat_soccer_config.neutral)

        -- Player list
        line0 = 0
        line1 = 0
        for k, v in pairs(players) do
            if (v.team == 0) then
                draw.DrawText(v.name, "bs_font_hud_text", -98, -68 + line0, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
                line0 = line0 + 12
            else
                draw.DrawText(v.name, "bs_font_hud_text", 2, -68 + line1, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
                line1 = line1 + 12
            end
        end
    cam.End3D2D()
end

local function DrawHUD(time, winner, score0, score1, matchTime)
    local out = false
    local oldW, oldH = ScrW(), ScrH()
    render.SetViewPort(oldW / 2 - 250, 0, 500, 500)

    cam.Start2D()
        -- Draw 5 second counter
        if (time != boat_soccer_config.setupLength + 1 and time != 0) then
            draw.RoundedBox(20, 194, 110, 112, 175, boat_soccer_config.neutral)
            draw.DrawText(tostring(time), "bs_font_hud_large", 250, 100, boat_soccer_config.text, TEXT_ALIGN_CENTER)
        end

        -- Draw winning team
        if (winner != -1) then
            surface.SetFont("bs_font_hud_small")

            if (winner == 0) then
                -- Red wins
                DrawCentered(20, 250, 125, 342, 75, boat_soccer_config.neutral)
                draw.DrawText("Red team wins!", "bs_font_hud_small", 250, 105, boat_soccer_config.team0, TEXT_ALIGN_CENTER)
                out = true
            else
                -- Blue wins
                DrawCentered(20, 250, 125, 342, 75, boat_soccer_config.neutral)
                draw.DrawText("Blue team wins!", "bs_font_hud_small", 250, 105, boat_soccer_config.team1, TEXT_ALIGN_CENTER)

                out = true
            end
        end

        -- Draw top scoreboard
        draw.RoundedBoxEx(10, 70, 0, 360, 55, boat_soccer_config.text, false, false, true, true)
        draw.RoundedBoxEx(10, 75, 0, 350, 50, boat_soccer_config.neutral, false, false, true, true)
        draw.DrawText(tostring(score0), "bs_font_hud_score", 100, -8, boat_soccer_config.team0, TEXT_ALIGN_TOP)
        draw.DrawText(tostring(score1), "bs_font_hud_score", 370, -8, boat_soccer_config.team1, TEXT_ALIGN_TOP)
        draw.DrawText(string.format("%d:%02d", matchTime / 60, matchTime % 60), "bs_font_hud_score", 250, -9, boat_soccer_config.text, TEXT_ALIGN_CENTER)
    cam.End2D()

    render.SetViewPort(0, 0, oldW, oldH)
    return out
end

function ENT:Initialize()
    self.time = boat_soccer_config.setupLength + 1
    self.lastGameStarted = false
    self.lastRound = self:GetNWInt("round", 1)
    self.matchStartTime = SysTime() + boat_soccer_config.matchLength + 1
    self.currentTime = SysTime()
end

function ENT:Draw()
    self:DrawModel()

    local _, maxs = self:GetModelBounds()
    local pos = self:LocalToWorld(Vector(0, 0, maxs.z + 48))
    local toPlayer = pos - LocalPlayer():GetPos()
    local worldAng = self:WorldToLocalAngles(Angle(0, -math.deg(math.atan2(toPlayer.x, toPlayer.y)), 0))
    local ang = self:LocalToWorldAngles(Angle(0, worldAng.y, 90))

    if (boat_soccer_client.controllers[self:EntIndex()] != nil and boat_soccer_client.controllers[self:EntIndex()] != false) then
        if (boat_soccer_client.controllers[self:EntIndex()].counting) then
            self.currentTime = SysTime()
        end

        if (!boat_soccer_client.joined) then
            DrawScoreboard(pos, ang, 0.5, boat_soccer_client.controllers[self:EntIndex()].players, self:GetNWInt("score0", 0))
        else
            -- Check if the game started to start a countdown
            if ((boat_soccer_client.controllers[self:EntIndex()].gameStarted != self.lastGameStarted and self.lastGameStarted == false) or
                    (self:GetNWInt("round", 1) != self.lastRound and boat_soccer_client.controllers[self:EntIndex()].gameStarted == true)) then
                -- Runs once at the start of every round
                self.lastGameStarted = boat_soccer_client.controllers[self:EntIndex()].gameStarted
                self.lastRound = self:GetNWInt("round", 1)
                self.time = boat_soccer_config.setupLength
                self.matchStartTime = SysTime() + boat_soccer_config.matchLength + 1
                self.currentTime = SysTime()

                for i=1,boat_soccer_config.setupLength do
                    timer.Simple(i, function()
                        if (!self:IsValid()) then return end
                        self.time = self.time - 1
                    end )
                end

                timer.Simple(boat_soccer_config.setupLength, function()
                    if (!self:IsValid()) then return end
                    self.matchStartTime = SysTime() + boat_soccer_config.matchLength
                end )
            end

            local matchTime = math.max(self.matchStartTime - self.currentTime, 0)
            if (DrawHUD(self.time, self:GetNWInt("winner", -1), self:GetNWInt("score0", 0), self:GetNWInt("score1", 0), matchTime)) then
                -- Reset game
                self.lastGameStarted = false
                self.matchStartTime = SysTime() + boat_soccer_config.matchLength + 1
                self.currentTime = SysTime()
            end
        end
    end
end