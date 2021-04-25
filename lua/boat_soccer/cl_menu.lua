-- Menu derma handler
include("sh_init.lua")

-- Local functions
local function RefreshList(players, playerList0, playerList1)
    playerList0:Clear()
    playerList1:Clear()

    local label = Label("Team 1")
    label:SetTextColor(Color(0, 0, 0))
    playerList0:Add(label)

    label = Label("Team 2")
    label:SetTextColor(Color(0, 0, 0))
    playerList1:Add(label)

    for k, v in pairs(players) do
        label = Label(v.name)
        label:SetTextColor(Color(0, 0, 0))

        if (v.team == 0) then
            playerList0:Add(label)
        else
            playerList1:Add(label)
        end
    end
end

-- API functions
function boat_soccer_client.OpenMenu(id, matchAdmin)
    -- Variables
    local selectedModel = 1

    -- Derma
    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 300)
    frame:Center()
    frame:SetTitle("Boat Soccer")
    frame:SetDraggable(true)
    frame:MakePopup()
    function frame:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, boat_soccer_config.neutral)
    end

    -- Player list derma
    local playerList0 = vgui.Create("DListLayout", frame)
    playerList0:SetSize(145, 270)
    playerList0:SetPos(5, 25)
    playerList0:SetPaintBackground(true)
    playerList0:SetBackgroundColor(boat_soccer_config.team0)

    local playerList1 = vgui.Create("DListLayout", frame)
    playerList1:SetSize(145, 270)
    playerList1:SetPos(155, 25)
    playerList1:SetPaintBackground(true)
    playerList1:SetBackgroundColor(boat_soccer_config.team1)

    RefreshList(boat_soccer_client.controllers[id].players, playerList0, playerList1)

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
            boat_soccer_client.Join(id)
            joinLeaveButton:SetText("Leave game")
        end
    end

    local switchTeamButton = vgui.Create("DButton", frame)
    switchTeamButton:SetSize(190, 20)
    switchTeamButton:SetPos(305, 45)
    switchTeamButton:SetText("Switch team")
    switchTeamButton.DoClick = function()
        boat_soccer_client.SwitchTeam(id)
    end

    local startGameButton = vgui.Create("DButton", frame)
    startGameButton:SetSize(190, 20)
    startGameButton:SetPos(305, 65)
    startGameButton:SetText("Start Game")
    startGameButton.DoClick = function()
        boat_soccer_client.StartGame(id)
    end

    local selectedBoatModel = vgui.Create("DModelPanel", frame)
    selectedBoatModel:SetSize(190, 180)
    selectedBoatModel:SetPos(305, 85)
    selectedBoatModel:SetModel(boat_soccer_config.boats[selectedModel].mdl)

    local prevMdlButton = vgui.Create("DButton", frame)
    prevMdlButton:SetSize(95, 20)
    prevMdlButton:SetPos(305, 265)
    prevMdlButton:SetText("<--")
    prevMdlButton.DoClick = function()
        selectedModel = math.max(selectedModel - 1, 1)
        selectedBoatModel:SetModel(boat_soccer_config.boats[selectedModel].mdl)
    end

    local nextMdlButton = vgui.Create("DButton", frame)
    nextMdlButton:SetSize(95, 20)
    nextMdlButton:SetPos(400, 265)
    nextMdlButton:SetText("-->")
    nextMdlButton.DoClick = function()
        selectedModel = math.min(selectedModel + 1, #boat_soccer_config.boats)
        selectedBoatModel:SetModel(boat_soccer_config.boats[selectedModel].mdl)
    end

    -- Admin settings
    local adminPanel = vgui.Create("DPanel", frame)
    adminPanel:SetSize(500, 200)
    adminPanel:SetPos(0, 290)

    local timeLabel = vgui.Create("DLabel", adminPanel)
    timeLabel:SetPos(10, 10)
    timeLabel:SetText("Match length in seconds: ")
    timeLabel:SetTextColor(Color(0, 0, 0))
    timeLabel:SizeToContents()

    local tlw = timeLabel:GetSize()
    local timeValue = vgui.Create("DNumberWang", adminPanel)
    timeValue:SetSize(50, 20)
    timeValue:SetPos(10 + tlw, 7)
    timeValue:SetMinMax(10, 1800)
    timeValue:SetValue(boat_soccer_client.controllers[id].settings.matchLength)
    timeValue.OnValueChanged = function(val)
        boat_soccer_client.UpdateGameSettings(id, val:GetValue(), nil, nil, nil)
    end

    local scoreLabel = vgui.Create("DLabel", adminPanel)
    scoreLabel:SetPos(10, 35)
    scoreLabel:SetText("Number of scores to win: ")
    scoreLabel:SetTextColor(Color(0, 0, 0))
    scoreLabel:SizeToContents()

    local scoreValue = vgui.Create("DNumberWang", adminPanel)
    scoreValue:SetSize(50, 20)
    scoreValue:SetPos(10 + tlw, 32)
    scoreValue:SetMinMax(1, 20)
    scoreValue:SetValue(boat_soccer_client.controllers[id].settings.winningScore)
    scoreValue.OnValueChanged = function(val)
        boat_soccer_client.UpdateGameSettings(id, nil, val:GetValue(), nil, nil)
    end

    local drainLabel = vgui.Create("DLabel", adminPanel)
    drainLabel:SetPos(10, 60)
    drainLabel:SetText("Boost drain speed: ")
    drainLabel:SetTextColor(Color(0, 0, 0))
    drainLabel:SizeToContents()

    local drainValue = vgui.Create("DNumberWang", adminPanel)
    drainValue:SetSize(50, 20)
    drainValue:SetPos(10 + tlw, 57)
    drainValue:SetMinMax(0, 20)
    drainValue:SetValue(boat_soccer_client.controllers[id].settings.boostDrain)
    drainValue.OnValueChanged = function(val)
        boat_soccer_client.UpdateGameSettings(id, nil, nil, val:GetValue(), nil)
    end

    local regenLabel = vgui.Create("DLabel", adminPanel)
    regenLabel:SetPos(10, 85)
    regenLabel:SetText("Boost regen speed: ")
    regenLabel:SetTextColor(Color(0, 0, 0))
    regenLabel:SizeToContents()

    local regenValue = vgui.Create("DNumberWang", adminPanel)
    regenValue:SetSize(50, 20)
    regenValue:SetPos(10 + tlw, 82)
    regenValue:SetMinMax(0, 20)
    regenValue:SetValue(boat_soccer_client.controllers[id].settings.boostRegen)
    regenValue.OnValueChanged = function(val)
        boat_soccer_client.UpdateGameSettings(id, nil, nil, nil, val:GetValue())
    end

    local multLabel = vgui.Create("DLabel", adminPanel)
    multLabel:SetPos(10, 110)
    multLabel:SetText("Boost speed multiplier: ")
    multLabel:SetTextColor(Color(0, 0, 0))
    multLabel:SizeToContents()

    local multValue = vgui.Create("DNumberWang", adminPanel)
    multValue:SetSize(50, 20)
    multValue:SetPos(10 + tlw, 107)
    multValue:SetMinMax(-200, 200)
    multValue:SetValue(boat_soccer_client.controllers[id].settings.boostMultiply)
    multValue.OnValueChanged = function(val)
        boat_soccer_client.UpdateGameSettings(id, nil, nil, nil, nil, val:GetValue())
    end

    hook.Add("boat_soccer:reload_derma", "Reload Derma", function()
        if (!frame:IsValid()) then
            hook.Remove("boat_soccer:reload_derma", "Reload Derma")
        else
            RefreshList(boat_soccer_client.controllers[id].players, playerList0, playerList1)

            if (boat_soccer_client.joined and boat_soccer_client.controllers[id].gameStarted == false) then
                switchTeamButton:Show()
            else
                switchTeamButton:Hide()
            end

            if (boat_soccer_client.IsMatchAdmin(id)) then
                frame:SetSize(500, 490)
                frame:Center()
                adminPanel:Show()

                if (boat_soccer_client.controllers[id].gameStarted == false) then
                    startGameButton:Show()
                end
            else
                frame:SetSize(500, 300)
                frame:Center()

                adminPanel:Hide()
                startGameButton:Hide()
            end

            if (#boat_soccer_client.controllers[id].players >= 10 and !boat_soccer_client.joined) then
                joinLeaveButton:SetEnabled(false)
            else
                joinLeaveButton:SetEnabled(true)
            end

            if (boat_soccer_client.GetTeamCount(0, id) >= boat_soccer_config.maxTeamSize or boat_soccer_client.GetTeamCount(1, id) >= boat_soccer_config.maxTeamSize) then
                switchTeamButton:SetEnabled(false)
            else
                switchTeamButton:SetEnabled(true)
            end

            if (selectedModel <= 1) then
                prevMdlButton:SetEnabled(false)
            else
                prevMdlButton:SetEnabled(true)
            end

            if (selectedModel >= #boat_soccer_config.boats) then
                nextMdlButton:SetEnabled(false)
            else
                nextMdlButton:SetEnabled(true)
            end
        end
    end )

    hook.Add("boat_soccer:close_derma", "Close Derma", function()
        hook.Remove("boat_soccer:close_derma", "Close Derma")

        if (frame:IsValid()) then
            frame:Close()
        end
    end )
end