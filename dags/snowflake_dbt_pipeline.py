import csv
import json
import os
import urllib.request
from datetime import datetime, timedelta

try:
    from airflow.sdk import DAG
except ImportError:
    from airflow import DAG

try:
    from airflow.providers.standard.operators.bash import BashOperator
    from airflow.providers.standard.operators.python import PythonOperator
except ImportError:
    from airflow.operators.bash import BashOperator
    from airflow.operators.python import PythonOperator

DBT_DIR = "/usr/local/airflow/dags/dbt_project"
DATA_DIR = "/usr/local/airflow/include/data"
KEY_FILE = "/usr/local/airflow/include/keys/rsa_key.p8"
START_DATE = "2026-09-01"


def fetch_exchange_rates():
    url = f"https://api.frankfurter.dev/v1/{START_DATE}..?from=INR&to=USD"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.load(resp)

    base = data["base"]
    with open(f"{DATA_DIR}/exchange_rates.csv", "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["rate_date", "base_currency", "target_currency", "rate"])
        for rate_date, rates in sorted(data["rates"].items()):
            for target, rate in rates.items():
                writer.writerow([rate_date, base, target, rate])


def load_raw_data():
    import snowflake.connector

    conn = snowflake.connector.connect(
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        user=os.environ["SNOWFLAKE_USER"],
        private_key_file=KEY_FILE,
        role="ACCOUNTADMIN",
        warehouse="DBT_WH",
        database="ANALYTICS_DB",
        schema="RAW",
    )
    cur = conn.cursor()
    try:
        cur.execute("CREATE STAGE IF NOT EXISTS internal_stage")
        for table in ["employee", "family", "orders", "exchange_rates"]:
            cur.execute(
                f"PUT file://{DATA_DIR}/{table}.csv @internal_stage "
                "AUTO_COMPRESS=FALSE OVERWRITE=TRUE"
            )
            cur.execute(f"TRUNCATE TABLE {table}")
            cur.execute(
                f"COPY INTO {table} FROM @internal_stage/{table}.csv "
                "FILE_FORMAT=(FORMAT_NAME=csv_format) FORCE=TRUE"
            )
    finally:
        cur.close()
        conn.close()


def dbt_cmd(command):
    return f"cd {DBT_DIR} && dbt {command} --profiles-dir ."


default_args = {"retries": 2, "retry_delay": timedelta(minutes=2)}

with DAG(
    dag_id="snowflake_dbt_pipeline",
    start_date=datetime(2026, 10, 1),
    schedule="@daily",
    catchup=False,
    max_active_runs=1,
    default_args=default_args,
    tags=["snowflake", "dbt"],
) as dag:

    fetch_rates = PythonOperator(task_id="fetch_exchange_rates", python_callable=fetch_exchange_rates)
    load_raw = PythonOperator(task_id="load_raw_data", python_callable=load_raw_data)
    dbt_deps = BashOperator(task_id="dbt_deps", bash_command=dbt_cmd("deps"))
    dbt_seed = BashOperator(task_id="dbt_seed", bash_command=dbt_cmd("seed"))
    dbt_run = BashOperator(task_id="dbt_run", bash_command=dbt_cmd("run"))
    dbt_test = BashOperator(task_id="dbt_test", bash_command=dbt_cmd("test"))
    dbt_snapshot = BashOperator(task_id="dbt_snapshot", bash_command=dbt_cmd("snapshot"))

    fetch_rates >> load_raw >> dbt_deps >> dbt_seed >> dbt_run >> dbt_test >> dbt_snapshot