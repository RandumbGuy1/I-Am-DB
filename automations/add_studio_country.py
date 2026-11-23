import json
import re
import unicodedata
import pandas as pd
from pathlib import Path

# https://www.geeksforgeeks.org/pandas/python-pandas-dataframe/

def add_countries(input_csv: str, output_csv: str, studio_col: str):
    df = pd.read_csv(input_csv, dtype=str)

    # Dropped these because they broke imports and took up a ton of space
    df = df.drop(columns=["movie_info", "cast"])

    map_json = Path(__file__).resolve().parent / "studio_country_map.json"
    with open(map_json, encoding="utf-8") as f:
        studio_country_map = json.load(f)

    # This follows a couple steps: 
    # https://www.tutorialspoint.com/python/python_re_escape_method.htm
    # Escaping converts non alpha numeric characters into escape chars, ex. '+' -> '\+' so regex doesn't treat them
    # as special chars

    # https://www.geeksforgeeks.org/python/python-regex/
    # r is needed for regex, f is needed for string formatting
    # Using \b so the regex only matches whole words, ex. "warner" shouldnt match with "warnerbros"
    patterns = [(re.compile(rf"\b{re.escape(keyword)}\b"), country) for keyword, country in studio_country_map.items()]

    def name_to_country(studio_name: str) -> str:
        if pd.isna(studio_name):
            return "Unknown"  

        # Strip Accents: https://www.geeksforgeeks.org/python/how-to-remove-string-accents-using-python-3/
        lower_name = str(studio_name).strip().lower()
        lower_name = unicodedata.normalize("NFKD", lower_name)
        lower_name = "".join(c for c in lower_name if not unicodedata.combining(c))

        for pattern, country in patterns:
            if pattern.search(lower_name):
                return country

        return "Unknown"

    # Add a id column to every movie
    df.insert(0, "id", range(1, len(df) + 1))

    # Convert studio col into lists of studio names split by "/"
    df[studio_col] = df[studio_col].str.split("/")

    # https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.explode.html
    # Explode the studio col lists, meaning that each element in the list gets its own row with all other cols duplicated
    df = df.explode(studio_col)

    # Strip whitespace and trailing periods from studio names
    df[studio_col] = df[studio_col].str.strip().str.rstrip(".")

    # Inserting country col into the df next to the studio name column
    col_pos = df.columns.get_loc(studio_col) + 1
    df.insert(col_pos, "studio_country", df[studio_col].apply(name_to_country))

    # "2010-02-12" -> "2010", also rename col to be more accurate
    df["in_theaters_date"] = df["in_theaters_date"].str[:4]
    df = df.rename(columns={"in_theaters_date": "release_year"})

    # Some ratings have a trailing ")" ("PG-13)" -> "PG-13")
    df["rating"] = df["rating"].str.rstrip(")")

    # Strip all stray quotes
    df = df.replace('"', "", regex=True)

    # Make sure output dir exists and convert df into csv, use cp1252 encoding to avoid special char errors
    Path(output_csv).parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output_csv, index=False, encoding="cp1252", errors="replace")

if __name__ == "__main__":
    root = Path(__file__).resolve().parent.parent
    add_countries(
        input_csv=root / "raw_datasets" / "rotten_tomatoes.csv",
        output_csv=root / "final_datasets" / "rotten_tomatoes_final.csv",
        studio_col="studio_name",
    )