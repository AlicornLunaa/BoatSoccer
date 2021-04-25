boat_hud_spawned = {} -- List of all spawned boats to draw the hud to

local function drawHUD(boost)
    local scale = boost / 100
    local oldW, oldH = ScrW(), ScrH()
    render.SetViewPort(oldW - 300, oldH - 300, 300, 300)
    cam.Start2D()
        surface.SetDrawColor(200, 200, 200, 200)
        surface.DrawRect(300 - 50, 300 - 200, 45, 195)

        surface.SetDrawColor(200, 50, 50, 200)
        surface.DrawRect(300 - 48, 300 - 198 + (191 * (1 - scale)), 41, 191 * scale)
    cam.End2D()
    render.SetViewPort(0, 0, oldW, oldH)
end

hook.Add("HUDPaint", "boat_soccer:hud", function()
    for boat, v in pairs(boat_hud_spawned) do
        if (v and v == true and boat:GetNWBool("driving")) then
            -- Draw name
            local pos = (boat:GetPos() + Vector(0, 0, 15)):ToScreen()
            if (pos.visible and LocalPlayer() != boat:GetNWEntity("driver")) then
                draw.DrawText(boat:GetNWEntity("driver"):Nick(), "bs_font_hud_name", pos.x, pos.y, boat:GetColor(), TEXT_ALIGN_CENTER)
            end

            -- Draw hud
            if (LocalPlayer() == boat:GetNWEntity("driver")) then
                drawHUD(boat:GetNWFloat("boost", 0))
            end
        end
    end
end )