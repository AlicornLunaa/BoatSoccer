-- Config
boat_soccer_config = boat_soccer_config or {}

-- Variables
boat_soccer_config.maxTeamSize = 5
boat_soccer_config.winningScore = 9
boat_soccer_config.matchLength = 300 -- 5 minutes in seconds
boat_soccer_config.setupLength = 9 -- 5 minutes in seconds
boat_soccer_config.throwForce = -300000

-- Team colors
boat_soccer_config.neutral = Color(53, 53, 53, 200)
boat_soccer_config.text = Color(233, 232, 232, 200)
boat_soccer_config.team0 = Color(233, 141, 141, 200)
boat_soccer_config.team1 = Color(114, 166, 235, 200)

boat_soccer_config.team0_spawns = {
    Vector(90, -105, 5),
    Vector(90, 0, 5),
    Vector(90, 105, 5),
    Vector(252, -51, 5),
    Vector(252, 51, 5)
}

boat_soccer_config.team1_spawns = {
    Vector(-90, -105, 5),
    Vector(-90, 0, 5),
    Vector(-90, 105, 5),
    Vector(-252, -51, 5),
    Vector(-252, 51, 5)
}