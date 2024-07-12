import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.models import Variable
from sqlalchemy.engine import Engine

import layers.dds.config as cfg
from layers.layer_manager import LayerManager
from scripts import db_utils_transfer


source_conn_id: str = Variable.get('target_conn_id')
target_conn_id: str = Variable.get('target_conn_id')
source_schema: str = 'ods_ira'
target_schema: str = 'dds_ira'

source_engine: Engine = db_utils_transfer.get_engine(source_conn_id)
target_engine: Engine = db_utils_transfer.get_engine(target_conn_id)

with DAG(
        dag_id='dds_transfer',
        start_date=datetime.datetime(2024, 7, 11),
        description='Transfer and clean tables from ODS layer DB to DDS layer same DB',
        schedule_interval=None,
) as dag:
    # Менеджер для управления процессами слоя
    manager = LayerManager(cfg.rules)

    # Определение задачи для создания схемы, таблиц и полей таргетного слоя
    create_layer_schema_and_tables = PythonOperator(
        task_id='create_layer_schema_and_tables',
        python_callable=manager.sql_query_executer_by_path,
        op_kwargs={
            'path_to_sql_query': cfg.path_to_sql_query_for_creating_layer,
            'engine': target_engine,
        }
    )

    # Определение задач для процесса ETL между слоями
    etl_process = PythonOperator(
        task_id=f'etl_proccess_for{target_schema}',
        python_callable=manager.etl_process_implementation,
        op_kwargs={
            'source_tables': cfg.tables,
            'source_engine': source_engine,
            'source_schema': source_schema,
            'target_tables': cfg.tables,
            'target_engine': target_engine,
            'target_schema': target_schema,
        },
    )
    create_layer_schema_and_tables >> etl_process
