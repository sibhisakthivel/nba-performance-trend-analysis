CREATE TABLE IF NOT EXISTS boxscores.player_boxscores_traditional_v3 (
    -- Identifiers
    game_id TEXT NOT NULL,
    team_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,

    -- Team metadata
    team_city TEXT,
    team_name TEXT,
    team_tricode TEXT,
    team_slug TEXT,

    -- Player metadata
    first_name TEXT,
    family_name TEXT,
    player_name TEXT,
    name_initial TEXT,
    player_slug TEXT,
    position TEXT,
    jersey_number TEXT,
    comment TEXT,

    -- Playing time
    minutes TEXT,  -- MM:SS format from NBA API

    -- Shooting
    field_goals_made INTEGER,
    field_goals_attempted INTEGER,
    field_goals_percentage REAL,

    three_pointers_made INTEGER,
    three_pointers_attempted INTEGER,
    three_pointers_percentage REAL,

    free_throws_made INTEGER,
    free_throws_attempted INTEGER,
    free_throws_percentage REAL,

    -- Rebounding
    rebounds_offensive INTEGER,
    rebounds_defensive INTEGER,
    rebounds_total INTEGER,

    -- Other box score stats
    assists INTEGER,
    steals INTEGER,
    blocks INTEGER,
    turnovers INTEGER,
    fouls_personal INTEGER,
    points INTEGER,
    plus_minus_points INTEGER,

    -- Constraints
    CONSTRAINT player_boxscores_trad_v3_pk
        PRIMARY KEY (game_id, player_id)
);
