import datetime
import os

from airflow.hooks.base import BaseHook
from airflow.operators.bash import BashOperator
from airflow import DAG


# Определение параметров DAG
dag = DAG(
    dag_id='dag_ods',
    description='dag_ods',
    schedule_interval=None,
    start_date=datetime.datetime(2024, 7, 8),
    catchup=False
)


# Определение параметров подключения к бд
def get_db_conn(conn_id):
    # Получаем объект подключения
    connection = BaseHook.get_connection(conn_id)

    # Получаем параметры подключения
    conn_params = {
        'host': connection.host,
        'dbname': connection.schema,
        'user': connection.login,
        'password': connection.password,
        'port': connection.port,
    }

    return conn_params


# Подключение к source
source_conn_params = get_db_conn('source')

# Подключение к etl_db_8
target_conn_params = get_db_conn('etl_db_8')

# Определение абсолютного пути к файлу main.py
path_to_main = os.path.join(os.path.dirname(__file__), 'main.py')

# Инициализация BashOperator
import_source_to_ods = BashOperator(
    task_id='import_source_to_ods',
    bash_command=f'python {path_to_main} "{source_conn_params}" "{target_conn_params}"',
    dag=dag
)

# Определение порядка выполнения задач
import_source_to_ods
