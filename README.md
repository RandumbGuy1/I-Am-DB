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
python automations/clean_celebrities.py
python automations/clean_rotten_tomatoes.py
python automations/clean_imdb.py
python automations/create_rt_credits.py
```

**Don't open and save the final CSVs in the editor as it can corrupt special characters**

## Create the initial schema
1. `initial-schema.sql`

## Import csv into this schema in MySQL Workbench
Some rows should stay text despite the wizard saying otherwise because of blank rows

| File | Expected Rows | Non-text columns |
|---|---|---|
| `rotten_tomatoes_final.csv` | 16,971 | `tm_id`: `int`, `tomatometer_rating`: `int`, `tomatometer_count`: `int` |
| `imdb_top_1000_final.csv` | 1,000 | `imdb_id`: `int`, `Released_Year`: `int`, `Runtime`: `int`, `IMDB_Rating`: `double`, `No_of_Votes`: `int` |
| `celebrity_data_final.csv` | 100 | `Rank`: `int` |
| `rotten_tomatoes_credits.csv` | 37,439 | `tm_id`: `int`, `is_director`: `int` |

## Load data into Schema
After importing, run the following in order:
1. `set_blank_to_null.sql`
2. `load_tables.sql`