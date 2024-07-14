import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.models import Variable
from airflow.providers.postgres.hooks.postgres import PostgresHook

from layers.layer_manager import LayerManager


def init_dag(
        dag_id: str,
        start_date: datetime.datetime,
        description: str,
        source_config,
        target_config,
        airflow_var_name: str,
        schedule_interval=None,
):
    with DAG(
            dag_id=dag_id,
            start_date=start_date,
            description=description,
            schedule_interval=schedule_interval,
    ) as dag:
        # Получение данных из переменной Airflow
        airflow_var_data = Variable.get(airflow_var_name, deserialize_json=True)

        # Распаковка необходимых данных для работы с таблицами
        source_schema = airflow_var_data['source_schema']
        target_schema = airflow_var_data['target_schema']
        source_engine = PostgresHook(postgres_conn_id=airflow_var_data['source_conn_id']).get_sqlalchemy_engine()
        target_engine = PostgresHook(postgres_conn_id=airflow_var_data['target_conn_id']).get_sqlalchemy_engine()

        # Менеджер для управления процессами слоя
        manager = LayerManager(target_config.rules)

        # Определение задачи для создания схемы, таблиц и полей таргетного слоя
        create_layer_schema_and_tables = PythonOperator(
            task_id=f'creating_schema_{target_schema}',
            python_callable=manager.sql_query_executer_by_path,
            op_kwargs={
                'path_to_sql_query': target_config.path_to_sql_query_for_creating_layer,
                'engine': target_engine,
            }
        )

        # Определение задач для процесса ETL между слоями
        etl_process = PythonOperator(
            task_id=f'etl_proccess_for{target_schema}',
            python_callable=manager.etl_process_implementation,
            op_kwargs={
                'source_tables': source_config.tables,
                'source_engine': source_engine,
                'source_schema': source_schema,
                'target_tables': target_config.tables,
                'target_engine': target_engine,
                'target_schema': target_schema,
            },
        )
        create_layer_schema_and_tables >> etl_process
