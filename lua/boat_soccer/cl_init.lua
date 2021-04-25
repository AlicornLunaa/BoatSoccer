-- Client initialization
boat_soccer_client = boat_soccer_client or {}
boat_soccer_client.controllers = {}
boat_soccer_client.balls = {}
boat_soccer_client.joined = false

include("cl_network.lua")
include("cl_menu.lua")

-- Fonts
surface.CreateFont("bs_font_hud_large", {
    font = "Arial",
    extended = false,
    size = 200,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
})

surface.CreateFont("bs_font_hud_small", {
    font = "Arial",
    extended = false,
    size = 50,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
})

surface.CreateFont("bs_font_hud_text", {
    font = "Tahoma",
    extended = false,
    size = 16,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
})

surface.CreateFont("bs_font_hud_name", {
    font = "Tahoma",
    extended = false,
    size = 26,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
})

surface.CreateFont("bs_font_hud_score", {
    font = "Tahoma",
    extended = false,
    size = 60,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
})

-- Functions
function boat_soccer_client.GetTeamCount(team, id)
    local count = 0

    for k, v in pairs(boat_soccer_client.controllers[id].players) do
        if (v.team == team) then
            count = count + 1
        end
    end

    return count
end

function boat_soccer_client.IsMatchAdmin(id)
    if (boat_soccer_client.controllers[id].players[LocalPlayer():SteamID64()] == nil) then
        return false
    else
        return boat_soccer_client.controllers[id].players[LocalPlayer():SteamID64()].matchAdmin
    end
end

function boat_soccer_client.Join(id)
    boat_soccer_client.joined = id

    net.Start("boat_soccer:join")
        net.WriteInt(id, 32)
    net.SendToServer()
end

function boat_soccer_client.Leave(id)
    boat_soccer_client.joined = false

    net.Start("boat_soccer:leave")
        net.WriteInt(id, 32)
    net.SendToServer()
end

function boat_soccer_client.SwitchTeam(id)
    if (boat_soccer_client.joined) then
        net.Start("boat_soccer:switch_team")
            net.WriteInt(id, 32)
        net.SendToServer()
    end
end

function boat_soccer_client.StartGame(id)
    net.Start("boat_soccer:start_game")
        net.WriteInt(id, 32)
    net.SendToServer()
end

function boat_soccer_client.UpdateGameSettings(id, matchLength, winningScore, boostDrain, boostRegen, boostMult)
    net.Start("boat_soccer:update_settings")
        net.WriteInt(id, 32)
        net.WriteInt(matchLength or boat_soccer_client.controllers[id].settings.matchLength, 32)
        net.WriteInt(winningScore or boat_soccer_client.controllers[id].settings.winningScore, 32)
        net.WriteFloat(boostDrain or boat_soccer_client.controllers[id].settings.boostDrain)
        net.WriteFloat(boostRegen or boat_soccer_client.controllers[id].settings.boostRegen)
        net.WriteFloat(boostMult or boat_soccer_client.controllers[id].settings.boostMultiply)
    net.SendToServer()
end