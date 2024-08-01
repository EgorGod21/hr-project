import os
from datetime import timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.sensors.external_task import ExternalTaskSensor
from airflow.utils.dates import days_ago
from sqlalchemy.engine import Engine

from layers import dag_manager as manager


# Абсолютный путь к SQL-скрипту создания слоя DM
path_to_sql_query_for_creating_layer = os.path.join(
    os.path.dirname(__file__), 'layers', 'dm', 'dm_create.sql'
)

# Извлечение данных из переменной Airflow
airflow_var_data = manager.get_schemas_from_airflow_var_and_engines('dds_to_dm')
target_engine: Engine = airflow_var_data['target_engine']

# Дефолтные значения ДАГа
default_args = {
            'retries': 5,
            'retry_delay': timedelta(minutes=5),
        }

# Инициализация ДАГа
with DAG(
    dag_id='dag_dm_layer',
    default_args=default_args,
    description='ETL process from DDS to DM',
    schedule_interval='0 21 * * *',
    start_date=days_ago(0),
) as dag:
    # Инициализация задачи создания слоя и его таблиц
    create_layer_schema_and_tables = PythonOperator(
        task_id='creating_tables_for_dm',
        python_callable=manager.sql_query_executer_by_path,
        op_kwargs={
            'path_to_sql_query': path_to_sql_query_for_creating_layer,
            'engine': target_engine,
        },
    )

    # Инициализация задачи для реализации ETL-процесса данного слоя
    etl_process = PythonOperator(
        task_id='etl_process_for_dm',
        python_callable=manager.etl_for_dm,
        op_kwargs=airflow_var_data,
    )

    start_task_dds = ExternalTaskSensor(
        task_id='start_task_dm',
        external_dag_id='dag_dds_layer',
        external_task_id='end_task_dds',
        mode='poke'
    )

    start_task_dds >> create_layer_schema_and_tables >> etl_process
