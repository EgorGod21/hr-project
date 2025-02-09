from datetime import timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.generic_transfer import GenericTransfer
from airflow.models import Variable
from airflow.utils.dates import days_ago

from scripts import db_utils_transfer

source_conn_id = Variable.get('source_conn_id', 'source_postgres_stage')
target_conn_id = Variable.get('target_conn_id', 'target_postgres_ods')
schema_name = Variable.get('source_schema_ods', 'source_data')
new_schema_name = Variable.get('target_schema_ods', 'ods')

source_engine = db_utils_transfer.get_engine(source_conn_id)
target_engine = db_utils_transfer.get_engine(target_conn_id)

dag = DAG(
    'dag_ods_layer',
    start_date=days_ago(0),
    description='Transfer data from stage layer to ods layer',
    schedule_interval='0 21 * * *',
    default_args={
            'retries': 5,
            'retry_delay': timedelta(minutes=5),
        },
)

create_schema_task = PythonOperator(
    task_id='create_schema',
    python_callable=db_utils_transfer.manage_schema,
    op_args=[target_engine, 'create', schema_name],
    dag=dag,
)

create_tables_task = PythonOperator(
    task_id='create_tables',
    python_callable=db_utils_transfer.create_tables,
    op_args=[source_engine, target_engine, schema_name],
    dag=dag,
)

rename_schema_task = PythonOperator(
    task_id='rename_schema',
    python_callable=db_utils_transfer.manage_schema,
    op_args=[target_engine,
             'rename',
             schema_name,
             new_schema_name],
    dag=dag,
)

transfer_tasks = db_utils_transfer.get_table_names(source_engine, schema_name)

for task in transfer_tasks:
    table_name = task['table']
    transfer_task = GenericTransfer(
        task_id=f'transfer_{table_name}',
        sql=f'SELECT * FROM {schema_name}."{table_name}"',
        destination_table=f'{schema_name}."{table_name}"',
        source_conn_id=source_conn_id,
        destination_conn_id=target_conn_id,
        dag=dag,
    )
    create_schema_task >> create_tables_task >> transfer_task >> rename_schema_task
