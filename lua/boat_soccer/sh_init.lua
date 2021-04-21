-- Config
boat_soccer_config = boat_soccer_config or {}

-- Team colors
boat_soccer_config.winningScore = 9
boat_soccer_config.matchLength = 300 -- 5 minutes in seconds
boat_soccer_config.throwForce = -300000

boat_soccer_config.neutral = Color(53, 53, 53, 200)
boat_soccer_config.text = Color(233, 232, 232, 200)
boat_soccer_config.team0 = Color(233, 141, 141, 200)
boat_soccer_config.team1 = Color(114, 166, 235, 200)

boat_soccer_config.team0_spawns = {
    Vector(-50, -105, 5),
    Vector(-50, 0, 5),
    Vector(-50, 105, 5),
    Vector(-140, -51, 5),
    Vector(-140, 51, 5)
}

boat_soccer_config.team1_spawns = {
    Vector(50, -105, 5),
    Vector(50, 0, 5),
    Vector(50, 105, 5),
    Vector(140, -51, 5),
    Vector(140, 51, 5)
}