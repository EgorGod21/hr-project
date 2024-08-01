import os
from datetime import timedelta
import re

from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.models import Variable
from airflow.utils.dates import days_ago
from airflow.sensors.external_task import ExternalTaskSensor
from airflow.operators.empty import EmptyOperator

target_conn_id = Variable.get('target_conn_id', 'target_postgres_ods')
dag_folder = os.path.dirname(__file__)

dag = DAG(
    'dag_dds_layer',
    start_date=days_ago(0),
    description='Transfer data from ods layer to dds layer',
    schedule_interval='0 21 * * *',
    default_args={
                'retries': 5,
                'retry_delay': timedelta(minutes=5),
            },
)

with open(os.path.join(dag_folder, "sql_scripts/create_dds_tables.sql"), 'r', encoding='utf-8') as f:
    create_dds_tables = f.read()

with open(os.path.join(dag_folder, "sql_scripts/dds_data_func.sql"), 'r', encoding='utf-8') as f:
    dds_data_func = f.read()

with open(os.path.join(dag_folder, "sql_scripts/run_dds_data_func.sql"), 'r', encoding='utf-8') as f:
    run_dds_data_func = f.read().split('\n')

start_task_dds = ExternalTaskSensor(
        task_id='start_task_dds',
        external_dag_id='dag_ods_layer',
        external_task_id='rename_schema',
        mode='poke',
        dag=dag,
)

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
    task_id='run_functions_сотрудники_дар',
    postgres_conn_id=target_conn_id,
    sql='''SELECT сотрудники_дар_dds();
        SELECT insert_4_col_all_tables_dds();''',
    dag=dag,
)

end_task_dds = EmptyOperator(task_id="end_task_dds", dag=dag)

for idx, task in enumerate(run_dds_data_func):
    task_match = re.search(r"'([^']*)'", task)
    task_name = task_match.group(1) if task_match else task.split()[1].replace('();', '')
    run_functions_par_task = PostgresOperator(
        task_id=f'run_functions_{task_name}',
        postgres_conn_id=target_conn_id,
        sql=task,
        dag=dag,
    )
    (start_task_dds
     >> create_schemes_and_tables_task
     >> create_functions_task
     >> run_functions_non_par_task
     >> run_functions_par_task
     >> end_task_dds)

