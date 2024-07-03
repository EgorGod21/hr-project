import datetime
from airflow import DAG
from airflow.hooks.base import BaseHook
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.postgres_operator import PostgresOperator


# Определение параметров DAG
dag = DAG(
    dag_id='test_dag',
    description='test_dag',
    schedule_interval=None,
    start_date=datetime.datetime(2024, 7, 2),
    catchup=False,
)

# Задача DummyOperator, которая служит начальной точкой
start_step = DummyOperator(task_id="start_step", dag=dag)

# Задача PostgresOperator для выполнения SQL-запроса
sql_select_step = PostgresOperator(
    task_id="sql_select_step",
    sql="SELECT * FROM source_data.отрасли",
    postgres_conn_id='1111',
    dag=dag
)

# Задача DummyOperator, которая служит конечной точкой
end_step = DummyOperator(task_id="end_step",dag=dag)

# Определение порядка выполнения задач
start_step >> sql_select_step >> end_step
