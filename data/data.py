import os
import time
import random
import pandas as pd
from nba_api.stats.endpoints import (
    leaguegamelog,
    boxscoretraditionalv3
)

# ======================================================
# CONFIG
# ======================================================

SEASON = "2024-25"
SEASON_LABEL = "2024_25_fixed"
SEASON_TYPE = "Regular Season"

OUTPUT_DIR = "data/raw"
SLEEP_RANGE = (1.5, 3.0)

LGL_FILE = f"league_gamelog_{SEASON_LABEL}.csv"
PBS_FILE = f"player_boxscores_{SEASON_LABEL}.csv"
TBS_FILE = f"team_boxscores_{SEASON_LABEL}.csv"

# NBA game IDs are always 10 digits
GAME_ID_LEN = 10

# ======================================================
# SAFE API CALL
# ======================================================

def safe_api_call(endpoint_fn, **kwargs):
    for attempt in range(5):
        try:
            return endpoint_fn(**kwargs)
        except Exception as e:
            wait = 2 + attempt * 2 + random.random()
            print(f"⚠️ API error: {e} — retrying in {wait:.1f}s")
            time.sleep(wait)
    raise RuntimeError("❌ API failed after retries")

# ======================================================
# UTILITIES
# ======================================================

def normalize_game_id(series):
    """
    Force game_id to string with leading zeros preserved.
    """
    return series.astype(str).str.zfill(GAME_ID_LEN)

def load_completed_game_ids(csv_path):
    """
    Load completed game_ids from an existing CSV, safely.
    """
    if not os.path.exists(csv_path):
        return set()

    df = pd.read_csv(csv_path, dtype={"game_id": str})

    if "game_id" not in df.columns:
        raise ValueError(f"`game_id` column missing from {csv_path}")

    return set(df["game_id"].str.zfill(GAME_ID_LEN).unique())

# ======================================================
# 1️⃣ LEAGUE GAME LOG (FAST)
# ======================================================

def pull_league_gamelog():
    print("🚀 Pulling LeagueGameLog")

    lg = safe_api_call(
        leaguegamelog.LeagueGameLog,
        season=SEASON,
        season_type_all_star=SEASON_TYPE
    )

    df = lg.get_data_frames()[0]

    df["GAME_ID"] = normalize_game_id(df["GAME_ID"])
    df["SEASON"] = SEASON
    df["SEASON_TYPE"] = SEASON_TYPE

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    path = os.path.join(OUTPUT_DIR, LGL_FILE)
    df.to_csv(path, index=False)

    print(f"✅ LeagueGameLog saved → {path}")
    print(f"   Rows: {len(df)} (≈ {len(df)//2} games)")

    return df

# ======================================================
# 2️⃣ PLAYER BOX SCORES (RESUME-SAFE, FAST-SKIP)
# ======================================================

def pull_player_boxscores(games):
    print("🐌 Pulling Player Box Scores")

    path = os.path.join(OUTPUT_DIR, PBS_FILE)
    completed = load_completed_game_ids(path)

    print(f"🔁 Player BS resume: {len(completed)} games already processed")

    missing_games = games[~games["GAME_ID"].isin(completed)]
    print(f"📌 Player BS missing games: {len(missing_games)}")

    for _, row in missing_games.iterrows():
        game_id = row["GAME_ID"]

        print(f"🏀 Player BS → {game_id}")

        try:
            bs = safe_api_call(
                boxscoretraditionalv3.BoxScoreTraditionalV3,
                game_id=game_id
            )

            df = bs.player_stats.get_data_frame()
            df["game_id"] = game_id

            df.to_csv(
                path,
                mode="a",
                index=False,
                header=not os.path.exists(path)
            )

            time.sleep(random.uniform(*SLEEP_RANGE))

        except Exception as e:
            print(f"❌ Failed player BS {game_id}: {e}")

    print("✅ Player box score pull complete")

# ======================================================
# 3️⃣ TEAM BOX SCORES (OPTIONAL)
# ======================================================

def pull_team_boxscores(games):
    print("🐢 Pulling Team Box Scores")

    path = os.path.join(OUTPUT_DIR, TBS_FILE)
    completed = load_completed_game_ids(path)

    print(f"🔁 Team BS resume: {len(completed)} games already processed")

    missing_games = games[~games["GAME_ID"].isin(completed)]
    print(f"📌 Team BS missing games: {len(missing_games)}")

    for _, row in missing_games.iterrows():
        game_id = row["GAME_ID"]

        print(f"🏀 Team BS → {game_id}")

        try:
            bs = safe_api_call(
                boxscoretraditionalv3.BoxScoreTraditionalV3,
                game_id=game_id
            )

            df = bs.team_stats.get_data_frame()
            df["game_id"] = game_id

            df.to_csv(
                path,
                mode="a",
                index=False,
                header=not os.path.exists(path)
            )

            time.sleep(random.uniform(*SLEEP_RANGE))

        except Exception as e:
            print(f"❌ Failed team BS {game_id}: {e}")

    print("✅ Team box score pull complete")

# ======================================================
# MAIN
# ======================================================

if __name__ == "__main__":

    # ---- STEP 1: FAST, SAFE ----
    league_df = pull_league_gamelog()

    games = (
        league_df[["GAME_ID", "GAME_DATE"]]
        .drop_duplicates()
        .sort_values("GAME_DATE")
        .reset_index(drop=True)
    )

    # ---- ENABLE ONLY WHAT YOU WANT ----
    pull_player_boxscores(games)
    pull_team_boxscores(games)
