-- Player boxscores
CREATE INDEX IF NOT EXISTS idx_pbs_player_id
ON boxscores.player_boxscores_traditional_v3 (player_id);

CREATE INDEX IF NOT EXISTS idx_pbs_game_id
ON boxscores.player_boxscores_traditional_v3 (game_id);

CREATE INDEX IF NOT EXISTS idx_pbs_clean_name
ON boxscores.player_boxscores_traditional_v3 (clean_name);

CREATE INDEX IF NOT EXISTS idx_pbs_player_game
ON boxscores.player_boxscores_traditional_v3 (player_id, game_id);

-- League gamelogs
CREATE INDEX IF NOT EXISTS idx_lg_game_id
ON boxscores.league_gamelogs (game_id);

CREATE INDEX IF NOT EXISTS idx_lg_team_id
ON boxscores.league_gamelogs (team_id);

CREATE INDEX IF NOT EXISTS idx_lg_game_date
ON boxscores.league_gamelogs (game_date);

CREATE INDEX IF NOT EXISTS idx_lg_team_date
ON boxscores.league_gamelogs (team_id, game_date);

CREATE INDEX IF NOT EXISTS idx_lg_home_away
ON boxscores.league_gamelogs (home_away);
