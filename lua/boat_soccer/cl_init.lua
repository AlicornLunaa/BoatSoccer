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

-- Functions
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
        net.WriteInt(id, 8)
    net.SendToServer()
end

function boat_soccer_client.Leave(id)
    boat_soccer_client.joined = false

    net.Start("boat_soccer:leave")
        net.WriteInt(id, 8)
    net.SendToServer()
end

function boat_soccer_client.SwitchTeam(id)
    if (boat_soccer_client.joined) then
        net.Start("boat_soccer:switch_team")
            net.WriteInt(id, 8)
        net.SendToServer()
    end
end

function boat_soccer_client.StartGame(id)
    net.Start("boat_soccer:start_game")
        net.WriteInt(id, 8)
    net.SendToServer()
end