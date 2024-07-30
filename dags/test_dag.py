import datetime
from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator


# Определение параметров DAG
dag = DAG(
    dag_id='test_dag',
    description='test_dag',
    schedule_interval=None,
    start_date=datetime.datetime(2024, 7, 2),
    catchup=False
)

# Задача EmptyOperator, которая служит начальной точкой
start_step = EmptyOperator(task_id="start_step", dag=dag)

# Задача SQLExecuteQueryOperator для выполнения SQL-запроса
sql_select_step = SQLExecuteQueryOperator(
    task_id="sql_select_step",
    sql='''SELECT * FROM source_data.отрасли''',
    conn_id='source',
    dag=dag
)

# Задача EmptyOperator, которая служит конечной точкой
end_step = EmptyOperator(task_id="end_step", dag=dag)

# Определение порядка выполнения задач
start_step >> sql_select_step >> end_step
