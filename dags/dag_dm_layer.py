import datetime
import os

from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.models import Variable

target_conn_id = Variable.get('target_conn_id', 'target_postgres_ods')
dag_folder = os.path.dirname(__file__)

dag = DAG(
    'dag_dm_layer',
    start_date=datetime.datetime(2024, 7, 5),
    description='Transfer data from dds layer to dm layer',
    schedule_interval=None,
)

with open(os.path.join(dag_folder, "sql_scripts/create_dm_tables.sql"), 'r', encoding='utf-8') as f:
    create_dm_tables = f.read()

with open(os.path.join(dag_folder, "sql_scripts/dm_data_func.sql"), 'r', encoding='utf-8') as f:
    dm_data_func = f.read()

with open(os.path.join(dag_folder, "sql_scripts/run_dm_data_func.sql"), 'r', encoding='utf-8') as f:
    run_dm_data_func = f.read()

create_schemes_and_tables_task = PostgresOperator(
    task_id='create_tables',
    postgres_conn_id=target_conn_id,
    sql=create_dm_tables,
    dag=dag,
)

create_functions_task = PostgresOperator(
    task_id='create_functions',
    postgres_conn_id=target_conn_id,
    sql=dm_data_func,
    dag=dag,
)

run_functions_task = PostgresOperator(
    task_id='run_functions',
    postgres_conn_id=target_conn_id,
    sql=run_dm_data_func,
    dag=dag,
)

create_schemes_and_tables_task >> create_functions_task >> run_functions_task