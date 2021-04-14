-- Menu derma handler
function boat_soccer_client.OpenMenu(id)
    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 300)
    frame:Center()
    frame:SetTitle("Boat Soccer")
    frame:SetDraggable(true)
    frame:MakePopup()

    -- Player list derma
    local playerList = vgui.Create("DListLayout", frame)
    playerList:SetSize(295, 270)
    playerList:SetPos(5, 25)
    playerList:SetPaintBackground(true)
    playerList:SetBackgroundColor(Color(200, 200, 200))

    for k, v in pairs(boat_soccer_client.controllers[id].players) do
        local label = Label(v.name)
        label:SetTextColor(Color(0, 0, 0))

        playerList:Add(label)
    end

    -- Join/leave/color buttons
    local mixer = vgui.Create("DColorMixer", frame)
    mixer:SetSize(190, 190)
    mixer:SetPos(305, 45)
    mixer:SetPalette(true)
    mixer:SetAlphaBar(false)
    mixer:SetWangs(true)
    mixer:SetColor(Color(LocalPlayer():GetWeaponColor().x * 255, LocalPlayer():GetWeaponColor().y * 255, LocalPlayer():GetWeaponColor().z * 255))

    local joinLeaveButton = vgui.Create("DButton", frame)
    joinLeaveButton:SetSize(190, 20)
    joinLeaveButton:SetPos(305, 25)

    if (boat_soccer_client.joined) then
        joinLeaveButton:SetText("Leave game")
    else
        joinLeaveButton:SetText("Join game")
    end

    joinLeaveButton.DoClick = function()
        if (boat_soccer_client.joined) then
            boat_soccer_client.Leave(id)
            joinLeaveButton:SetText("Join game")
        else
            boat_soccer_client.Join(mixer:GetColor(), id)
            joinLeaveButton:SetText("Leave game")
        end
    end
end