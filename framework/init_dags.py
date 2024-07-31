from datetime import datetime
import typing as tg
import types as ts

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.models import Variable
from airflow.providers.postgres.hooks.postgres import PostgresHook
from sqlalchemy.engine import Engine

from layers.layer_manager import LayerManager


def get_postgres_engine(conn_id: str) -> Engine:
    """
    Получает SQLAlchemy engine для заданного идентификатора соединения Postgres.

    :param conn_id: Идентификатор соединения Postgres.
    :type conn_id: str
    :return: SQLAlchemy engine.
    :rtype: sqlalchemy.engine.Engine
    """
    try:
        hook = PostgresHook(postgres_conn_id=conn_id)
        return hook.get_sqlalchemy_engine()
    except Exception as e:
        print(f"Error when getting SQLAlchemy engine to connect {conn_id}: {e}")
        raise


def init_dag(
    dag_id: str,
    start_date: datetime,
    description: str,
    source_config: ts.ModuleType,
    target_config: ts.ModuleType,
    airflow_var_name: str,
    schedule_interval: tg.Optional[str] = None,
) -> DAG:
    """
    Инициализирует DAG для ETL процесса.

    :param dag_id: Идентификатор DAG.
    :type dag_id: str
    :param start_date: Дата начала.
    :type start_date: datetime
    :param description: Описание DAG.
    :type description: str
    :param source_config: Конфигурация источника данных.
    :type source_config: module
    :param target_config: Конфигурация целевого слоя.
    :type target_config: module
    :param airflow_var_name: Имя переменной Airflow, содержащей конфигурацию соединений.
    :type airflow_var_name: str
    :param schedule_interval: Интервал расписания, по умолчанию None.
    :type schedule_interval: Optional[str]
    :return: Инициализированный объект DAG.
    :rtype: airflow.DAG
    """
    try:
        # Получение данных из переменной Airflow
        airflow_var_data = Variable.get(airflow_var_name, deserialize_json=True)

        # Распаковка необходимых данных для работы с таблицами
        source_schema = airflow_var_data['source_schema']
        target_schema = airflow_var_data['target_schema']
        source_conn_id = airflow_var_data['source_conn_id']
        target_conn_id = airflow_var_data['target_conn_id']
    except Exception as e:
        print(f"Error unpacking data from the Airflow var {airflow_var_name}: {e}")
        raise

    # Получение SQLAlchemy engine для распакованных идентификаторов соединений Postgres
    source_engine = get_postgres_engine(source_conn_id)
    target_engine = get_postgres_engine(target_conn_id)

    # Менеджер для управления ETL-процессами и создания target слоя
    l_manager = LayerManager(target_config.rules)

    try:
        # Создание DAG через контекстный менеджер
        with DAG(
            dag_id=dag_id,
            start_date=start_date,
            description=description,
            schedule_interval=schedule_interval,
        ) as dag:
            # Определение задачи для создания схемы, таблиц и полей target слоя
            create_layer_schema_and_tables = PythonOperator(
                task_id=f'creating_tables_for_{target_schema}',
                python_callable=l_manager.sql_query_executer_by_path,
                op_kwargs={
                    'path_to_sql_query': target_config.path_to_sql_query_for_creating_layer,
                    'engine': target_engine,
                }
            )

            # Определение задачи для процесса ETL между source и target слоями
            etl_process = PythonOperator(
                task_id=f'etl_process_for_{target_schema}',
                python_callable=l_manager.etl_process_implementation,
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

    except Exception as e:
        print(f"Error creating the DAG {dag_id}: {e}")
        raise

    return dag
