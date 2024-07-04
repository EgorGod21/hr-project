from airflow import DAG
import datetime
from airflow.operators.empty import EmptyOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator


dag = DAG('test_connection', description='postgres',
          schedule_interval='@daily',
          start_date=datetime.datetime(2021, 11, 7), catchup=False)
start_step = EmptyOperator(task_id="start_step", dag=dag)
hello_step = SQLExecuteQueryOperator(task_id="insert_step",
                            sql='''SELECT * FROM source_data."инструменты" LIMIT 5''',
                            conn_id='db_source_postgres',
                            dag=dag)
end_step = EmptyOperator(task_id="end_step", dag=dag)

start_step >> hello_step >> end_step


