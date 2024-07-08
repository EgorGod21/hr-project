import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.generic_transfer import GenericTransfer

from scripts import db_utils_transfer

dag = DAG(
    'db_transfer',
    start_date=datetime.datetime(2024, 7, 5),
    description='Transfer all tables from source DB to destination DB',
    schedule_interval=None,
)

create_schema_task = PythonOperator(
    task_id='create_schema',
    python_callable=db_utils_transfer._manage_schema,
    op_args=[db_utils_transfer.get_destination_engine(), 'create', db_utils_transfer.schema_name],
    dag=dag,
)

create_tables_task = PythonOperator(
    task_id='create_tables',
    python_callable=db_utils_transfer.create_tables,
    dag=dag,
)

rename_schema_task = PythonOperator(
    task_id='rename_schema',
    python_callable=db_utils_transfer._manage_schema,
    op_args=[db_utils_transfer.get_destination_engine(),
             'rename',
             db_utils_transfer.schema_name,
             db_utils_transfer.new_schema_name],
    dag=dag,
)

transfer_tasks = db_utils_transfer.get_table_names()

for task in transfer_tasks:
    table_name = task['table']
    transfer_task = GenericTransfer(
        task_id=f'transfer_{table_name}',
        sql=f'SELECT * FROM {db_utils_transfer.schema_name}."{table_name}"',
        destination_table=f'{db_utils_transfer.schema_name}."{table_name}"',
        source_conn_id=db_utils_transfer.source_conn_id,
        destination_conn_id=db_utils_transfer.target_conn_id,
        dag=dag,
    )
    create_schema_task >> create_tables_task >> transfer_task >> rename_schema_task
