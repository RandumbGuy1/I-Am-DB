import pandas as pd
from pathlib import Path

# Convert a string of comma seperated names into a list of names
def split_names(names: str) -> list:
    if pd.isna(names):
        return []
    
    people = []
    for s in names.split(","):
        s = s.strip()
        if (s == ""):
            continue
        
        # Suffixes like "Jr." or "Jr" are seperated by commas, so append them to the previous name
        if s.lower().rstrip(".") in ["jr", "sr", "ii", "iii", "iv"] and people:
            people[-1] += f" {s}"
        else:
            people.append(s)

    return people

def export_credits(input_csv: str, output_csv: str, directors_col: str, writers_col: str):
    df = pd.read_csv(input_csv, dtype=str)
    df.insert(0, "tm_id", range(1, len(df) + 1))
    
    # Create 2 temporary dfs with only the tmid, and a name column
    directors = df[["tm_id", directors_col]].rename(columns={directors_col: "name"})
    directors.insert(2, "is_director", 1)
    writers = df[["tm_id", writers_col]].rename(columns={writers_col: "name"})
    writers.insert(2, "is_director", 0)
    credits = pd.concat([directors, writers])

    # convert all names col into lists of names
    credits["name"] = credits["name"].apply(split_names)
    # Drop duplicates only by tm_id and name so a writer and director isnt dupped
    credits = credits.explode("name").dropna().drop_duplicates(subset=["tm_id", "name"])

    # Strip all stray quotes
    credits = credits.replace('"', "", regex=True)

    Path(output_csv).parent.mkdir(parents=True, exist_ok=True)
    credits.to_csv(output_csv, index=False, encoding="cp1252", errors="replace")

if __name__ == "__main__":
    root = Path(__file__).resolve().parent.parent
    export_credits(
        input_csv=root / "raw_datasets" / "rotten_tomatoes.csv",
        output_csv=root / "final_datasets" / "rotten_tomatoes_credits.csv",
        directors_col="directors",
        writers_col="writers",
    )