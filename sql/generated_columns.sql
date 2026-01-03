-- -- Player full name
-- ALTER TABLE boxscores.player_boxscores_traditional_v3
-- ADD COLUMN IF NOT EXISTS player_name TEXT
-- GENERATED ALWAYS AS(
--     CONCAT_WS(' ', first_name, family_name)
-- ) STORED;

-- -- Opponent extraction
-- ALTER TABLE boxscores.league_gamelogs
-- ADD COLUMN IF NOT EXISTS opponent TEXT
-- GENERATED ALWAYS AS (
--     CASE
--         WHEN matchup LIKE '% vs.%' THEN split_part(matchup, ' vs. ', 2)
--         WHEN matchup LIKE '% @ %' THEN split_part(matchup, ' @ ', 2)
--         ELSE NULL
--     END
-- ) STORED;

-- -- Conver game date from text -> timestamp
-- ALTER TABLE boxscores.league_gamelogs
-- ADD COLUMN IF NOT EXISTS game_date DATE
-- GENERATED ALWAYS AS (
--     game_date_raw::date
-- ) STORED;

-- -- Convert minutes from text -> decimal
-- ALTER TABLE boxscores.player_boxscores_traditional_v3
-- ADD COLUMN IF NOT EXISTS minutes_decimal REAL
-- GENERATED ALWAYS AS (
--     split_part(minutes_raw, ':', 1)::int
--     + split_part(minutes_raw, ':', 2)::int / 60.0
-- ) STORED;

-- ALTER TABLE boxscores.league_gamelogs
-- ADD COLUMN IF NOT EXISTS minutes_decimal REAL
-- GENERATED ALWAYS AS (
--     split_part(minutes_raw, ':', 1)::int
--     + split_part(minutes_raw, ':', 2)::int / 60.0
-- ) STORED;

-- -- Normalize player names (remove accents)
-- ALTER TABLE boxscores.player_boxscores_traditional_v3
-- ADD COLUMN IF NOT EXISTS clean_name TEXT;

-- UPDATE boxscores.player_boxscores_traditional_v3
-- SET clean_name = lower(
--     regexp_replace(
--         unaccent(CONCAT_WS(' ', first_name, family_name)),
--         '[^a-z ]',
--         '',
--         'g'
--     )
-- );

-- -- Team home / away flag
-- ALTER TABLE boxscores.league_gamelogs
-- ADD COLUMN IF NOT EXISTS home_away TEXT;

-- UPDATE boxscores.league_gamelogs
-- SET home_away = CASE
--     WHEN matchup LIKE '% vs.%' THEN 'HOME'
--     WHEN matchup LIKE '% @ %' THEN 'AWAY'
--     ELSE NULL
-- END;

-- Extensions
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Player full name (generated)
ALTER TABLE boxscores.player_boxscores_traditional_v3
ADD COLUMN IF NOT EXISTS player_name TEXT
GENERATED ALWAYS AS (CONCAT_WS(' ', first_name, family_name)) STORED;

-- Opponent (generated)
ALTER TABLE boxscores.league_gamelogs
ADD COLUMN IF NOT EXISTS opponent TEXT
GENERATED ALWAYS AS (
    CASE
        WHEN matchup LIKE '% vs.%' THEN split_part(matchup, ' vs. ', 2)
        WHEN matchup LIKE '% @ %' THEN split_part(matchup, ' @ ', 2)
        ELSE NULL
    END
) STORED;

-- Game date (generated)
ALTER TABLE boxscores.league_gamelogs
ADD COLUMN IF NOT EXISTS game_date DATE
GENERATED ALWAYS AS (game_date_raw::date) STORED;

-- Minutes decimal (generated, SAFE)
-- (use the CASE version above)

-- Clean name (materialized)
ALTER TABLE boxscores.player_boxscores_traditional_v3
ADD COLUMN IF NOT EXISTS clean_name TEXT;

UPDATE boxscores.player_boxscores_traditional_v3
SET clean_name = regexp_replace(
    lower(unaccent(CONCAT_WS(' ', first_name, family_name))),
    '[^a-z ]',
    '',
    'g'
);

-- Home / away (materialized)
ALTER TABLE boxscores.league_gamelogs
ADD COLUMN IF NOT EXISTS home_away TEXT;

UPDATE boxscores.league_gamelogs
SET home_away = CASE
    WHEN matchup LIKE '% vs.%' THEN 'HOME'
    WHEN matchup LIKE '% @ %' THEN 'AWAY'
    ELSE NULL
END;
