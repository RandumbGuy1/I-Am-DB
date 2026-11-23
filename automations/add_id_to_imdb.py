import pandas as pd
from pathlib import Path

def add_id(input_csv: str, output_csv: str):
    df = pd.read_csv(input_csv, dtype=str)

    # Add a id column to every movie, used as the IMDb_Metrics id
    df.insert(0, "id", range(1, len(df) + 1))

    # Apollo 13 has a released year of "PG" replace it with 1995
    df.loc[df["Released_Year"] == "PG", "Released_Year"] = "1995"

    # "142 min" -> "142"
    df["Runtime"] = df["Runtime"].str.replace(" min", "")

    # "28,341,469" -> "28341469"
    df["Gross"] = df["Gross"].str.replace(",", "")

    # Strip all stray quotes
    df = df.replace('"', "", regex=True)

    # Make sure output dir exists and convert df into csv, use cp1252 encoding to avoid special char errors
    Path(output_csv).parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output_csv, index=False, encoding="cp1252", errors="replace")

if __name__ == "__main__":
    root = Path(__file__).resolve().parent.parent
    add_id(
        input_csv=root / "raw_datasets" / "imdb_top_1000.csv",
        output_csv=root / "final_datasets" / "imdb_top_1000_final.csv",
    )
