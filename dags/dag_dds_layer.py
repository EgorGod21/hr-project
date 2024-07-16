import datetime
import os

from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.models import Variable

target_conn_id = Variable.get('target_conn_id', 'target_postgres_ods')
dag_folder = os.path.dirname(__file__)

dag = DAG(
    'dag_dds_layer',
    start_date=datetime.datetime(2024, 7, 5),
    description='Transfer data from ods layer to dds layer',
    schedule_interval=None,
)

with open(os.path.join(dag_folder, "sql_scripts/create_dds_tables.sql"), 'r', encoding='utf-8') as f:
    create_dds_tables = f.read()

with open(os.path.join(dag_folder, "sql_scripts/dds_data_func.sql"), 'r', encoding='utf-8') as f:
    dds_data_func = f.read()

with open(os.path.join(dag_folder, "sql_scripts/run_dds_data_func.sql"), 'r', encoding='utf-8') as f:
    run_dds_data_func = f.read().split('\n')

create_schemes_and_tables_task = PostgresOperator(
    task_id='create_tables',
    postgres_conn_id=target_conn_id,
    sql=create_dds_tables,
    dag=dag,
)

create_functions_task = PostgresOperator(
    task_id='create_functions',
    postgres_conn_id=target_conn_id,
    sql=dds_data_func,
    dag=dag,
)

run_functions_non_par_task = PostgresOperator(
    task_id='run_functions_non_par',
    postgres_conn_id=target_conn_id,
    sql='''SELECT сотрудники_дар_dds_egor();
        SELECT insert_4_col_all_tables_dds_egor();''',
    dag=dag,
)

for idx, task in enumerate(run_dds_data_func):
    run_functions_par_task = PostgresOperator(
        task_id=f'run_functions_par_{idx + 1}',
        postgres_conn_id=target_conn_id,
        sql=task,
        dag=dag,
    )
    create_schemes_and_tables_task >> create_functions_task >> run_functions_non_par_task >> run_functions_par_task

