import os
from datetime import timedelta

from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.operators.empty import EmptyOperator
from airflow.models import Variable
from airflow.utils.dates import days_ago

target_conn_id = Variable.get('target_conn_id', 'target_postgres_ods')
dag_folder = os.path.dirname(__file__)

dag = DAG(
    'dag_dm_layer',
    start_date=days_ago(1),
    description='Transfer data from dds layer to dm layer',
    schedule_interval='0 21 * * *',
    default_args={
                    'retries': 5,
                    'retry_delay': timedelta(minutes=5),
                },
)

with open(os.path.join(dag_folder, "sql_scripts/create_dm_tables.sql"), 'r', encoding='utf-8') as f:
    create_dm_tables = f.read()

with open(os.path.join(dag_folder, "sql_scripts/dm_data_func.sql"), 'r', encoding='utf-8') as f:
    dm_data_func = f.read()

with open(os.path.join(dag_folder, "sql_scripts/run_dm_data_func.sql"), 'r', encoding='utf-8') as f:
    run_dm_data_func = f.read().split('\n')

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

run_сотрудники_дар_task = PostgresOperator(
    task_id='run_function_сотрудники_дар',
    postgres_conn_id=target_conn_id,
    sql='SELECT сотрудники_дар_dm();',
    dag=dag,
)
run_уровни_знаний_task = PostgresOperator(
    task_id='run_function_уровни_знаний',
    postgres_conn_id=target_conn_id,
    sql='SELECT уровни_знаний_dm();',
    dag=dag,
)
run_группы_навыков_task = PostgresOperator(
    task_id='run_function_группы_навыков',
    postgres_conn_id=target_conn_id,
    sql='SELECT группы_навыков_dm();',
    dag=dag,
)
run_навыки_task = PostgresOperator(
    task_id='run_function_навыки',
    postgres_conn_id=target_conn_id,
    sql='SELECT навыки_dm();',
    dag=dag,
)

intermediate_task = EmptyOperator(task_id="intermediate_task", dag=dag)

for idx, task in enumerate(run_dm_data_func):
    run_functions_par_task = PostgresOperator(
        task_id=f'run_functions_par_{idx + 1}',
        postgres_conn_id=target_conn_id,
        sql=task,
        dag=dag,
    )
    (create_schemes_and_tables_task
     >> create_functions_task
     >> [run_сотрудники_дар_task, run_навыки_task, run_группы_навыков_task, run_уровни_знаний_task]
     >> intermediate_task
     >> run_functions_par_task)