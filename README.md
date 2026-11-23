# Movie Analysis
Utilizing public datasets to provide consumers with movie analytics to inform their next watches using MySQL relational Databases.

## Setup
1. Install python 3.14
https://www.python.org/downloads/

2. Install pandas
```py
    python -m pip install pandas
```

3. Put the raw datasets in `raw_datasets/` (CSVs are not committed):
    - `rotten_tomatoes.csv`
    - `imdb_top_1000.csv`
    - `celebrity_data.csv`

## Clean the datasets
From the project root:
```
python automations/add_studio_country.py
python automations/add_celebrity_gender.py
python automations/add_id_to_imdb.py
```

**Don't open and save the final CSVs in the editor as it can corrupt special characters**

## Import into MySQL Workbench
Some rows should stay text despite the wizard saying otherwise because of blank rows

| File | Expected Rows | Non-text columns |
|---|---|---|
| `rotten_tomatoes_final.csv` | 16,971 | `id`: `int`, `tomatometer_rating`: `int`, `tomatometer_count`: `int` |
| `imdb_top_1000_final.csv` | 1,000 | `id`: `int`, `Released_Year`: `int`, `Runtime`: `int`, `IMDB_Rating`: `double`, `No_of_Votes`: `int` |
| `celebrity_data_final.csv` | 100 | `Rank`: `int` |

## Load data into Schema
After importing, run the following in order:
1. `set_blank_to_null.sql`
2. `initial-schema.sql`
3. `load_tables.sql`