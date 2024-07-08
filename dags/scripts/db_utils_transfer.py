import logging
from airflow.providers.postgres.hooks.postgres import PostgresHook
from sqlalchemy import MetaData

source_conn_id = 'source_postgres_stage'
target_conn_id = 'target_postgres_ods'
schema_name = 'source_data'
new_schema_name = 'ods'


def get_source_engine():
    """Подключние к общей базе данных"""
    source_hook = PostgresHook(postgres_conn_id=source_conn_id)
    return source_hook.get_sqlalchemy_engine()


def get_destination_engine():
    """Подключние к собственной базе данных"""
    dest_hook = PostgresHook(postgres_conn_id=target_conn_id)
    return dest_hook.get_sqlalchemy_engine()


def _execute_sql(engine, sql_query):
    """Выполнение запроса к базе данных"""
    try:
        with engine.connect() as connection:
            connection.execute(sql_query)
            logging.info(f"Executed SQL query: {sql_query}")
    except Exception as e:
        logging.error(f"Error executing SQL query: {e.args}")


def _manage_schema(engine, action, schema_name, new_schema_name=None):
    """Управление схемой базы данных"""
    if action == 'create':
        sql_query = f"CREATE SCHEMA IF NOT EXISTS {schema_name};"
    elif action == 'rename' and new_schema_name:
        drop_sql_query = f"DROP SCHEMA IF EXISTS {new_schema_name} CASCADE;"
        _execute_sql(engine, drop_sql_query)
        sql_query = f"ALTER SCHEMA {schema_name} RENAME TO {new_schema_name};"
    else:
        logging.error("Invalid action or missing new schema name for rename operation")
        return

    _execute_sql(engine, sql_query)


def create_tables():
    """Создание таблиц в собственной базе данных"""
    source_engine = get_source_engine()
    destination_engine = get_destination_engine()

    meta = MetaData(schema=schema_name)
    meta.reflect(bind=source_engine)

    logging.info("Creating tables in the destination database...")
    for table in meta.tables.values():
        logging.info(f"Table: {table.name}")
    meta.create_all(bind=destination_engine)
    logging.info("Tables created successfully.")


def get_table_names():
    """Возвращает список таблиц в общей базе данных"""
    source_engine = get_source_engine()
    meta = MetaData(schema=schema_name)
    meta.reflect(bind=source_engine)
    array = []
    for table in meta.tables.values():
        logging.info(f"Creating transfer task for table: {table.name}")
        array.append({'table': table.name})
        logging.info(f"Task transfer_{table.name} created.")

    return array
