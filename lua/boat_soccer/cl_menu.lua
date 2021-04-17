-- Menu derma handler
include("sh_init.lua")

-- Local functions
local function RefreshList(players, playerList0, playerList1)
    playerList0:Clear()
    playerList1:Clear()

    playerList0:Add(Label("Team 1"))
    playerList1:Add(Label("Team 2"))

    for k, v in pairs(players) do
        local label = Label(v.name)
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
    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 300)
    frame:Center()
    frame:SetTitle("Boat Soccer")
    frame:SetDraggable(true)
    frame:MakePopup()

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

    hook.Add("boat_soccer:reload_derma", "Reload Derma", function()
        if (!frame:IsValid()) then
            hook.Remove("boat_soccer:reload_derma", "Reload Derma")
        else
            RefreshList(boat_soccer_client.controllers[id].players, playerList0, playerList1)

            if (boat_soccer_client.joined) then
                switchTeamButton:Show()
            else
                switchTeamButton:Hide()
            end

            if (boat_soccer_client.IsMatchAdmin(id)) then
                startGameButton:Show()
            else
                startGameButton:Hide()
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