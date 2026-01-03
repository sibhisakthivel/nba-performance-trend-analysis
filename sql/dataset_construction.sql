WITH team_game_context AS (
    SELECT
        team_id,
        team_abbreviation,
        game_id,
        game_date,
        matchup,
        opponent,
        points,
        AVG(points) OVER (
            PARTITION BY opponent
            ORDER BY game_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS opp_pts_allowed
    FROM boxscores.league_gamelogs
),

player_context AS (
    SELECT
        p.game_id,
        t.game_date,
        p.player_id,
        p.player_name,
        p.clean_name,
        p.team_id,
        p.points AS pts,

        AVG(p.points) OVER (
            PARTITION BY p.player_id
            ORDER BY t.game_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS season_avg_pts,

        p.points
        - AVG(p.points) OVER (
            PARTITION BY p.player_id
            ORDER BY t.game_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS deviation,

        CASE
            WHEN p.points >
                 AVG(p.points) OVER (
                     PARTITION BY p.player_id
                     ORDER BY t.game_date
                     ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                 )
            THEN 1 ELSE 0
        END AS over_flag,

        t.team_abbreviation,
        t.opp_pts_allowed
    FROM boxscores.player_boxscores_traditional_v3 p
    JOIN team_game_context t
        ON p.game_id = t.game_id
       AND p.team_id <> t.team_id
)

SELECT *
FROM player_context
ORDER BY player_id, game_date;
