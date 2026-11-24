import ast
import pandas as pd
from pathlib import Path

def add_gender(input_csv: str, output_csv: str, name_col: str, role_col: str):
    df = pd.read_csv(input_csv, dtype=str)

    def roles_to_gender(roles: str) -> str:
        if pd.isna(roles):
            return "Unknown"

        # https://stackoverflow.com/questions/1894269/how-to-convert-string-representation-of-list-to-a-list
        # Convert a list like "['Actress', 'Soundtrack']" into a list
        role_list = ast.literal_eval(roles)

        if "Actress" in role_list:
            return "Female"
        if "Actor" in role_list:
            return "Male"

        return "Unknown"

    # Inserting gender col next to the name col
    col_pos = df.columns.get_loc(name_col) + 1
    df.insert(col_pos, "gender", df[role_col].apply(roles_to_gender))

    # https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.to_datetime.html
    # https://docs.python.org/3/library/datetime.html#strftime-and-strptime-behavior
    # Convert Date_of_birth into YYYY-MM-DD format
    # %B is the full month name, %d is the day, %Y is the year, coerce converts to NULL if invalid format
    df["Date_of_birth"] = pd.to_datetime(df["Date_of_birth"], format="%B %d, %Y", errors="coerce").dt.strftime("%Y-%m-%d")

    # Every height ends with meters at the end, so convert height to meters
    df["height"] = df["height"].str.split("(").str[-1].str.replace(" m)", "")

    # Strip all stray quotes
    df = df.replace('"', "", regex=True)

    # Make sure output dir exists and convert df into csv, use cp1252 encoding to avoid special char errors
    Path(output_csv).parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output_csv, index=False, encoding="cp1252", errors="replace")

if __name__ == "__main__":
    root = Path(__file__).resolve().parent.parent
    add_gender(
        input_csv=root / "raw_datasets" / "celebrity_data.csv",
        output_csv=root / "final_datasets" / "celebrity_data_final.csv",
        name_col="Name",
        role_col="Role",
    )
