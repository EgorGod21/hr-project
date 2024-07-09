import logging
from typing import Optional, List, Dict

from airflow.providers.postgres.hooks.postgres import PostgresHook
from sqlalchemy import MetaData
from sqlalchemy.engine import Engine


def get_engine(conn_id: str) -> Engine:
    """Подключние к общей базе данных"""
    hook = PostgresHook(postgres_conn_id=conn_id)
    return hook.get_sqlalchemy_engine()


def _execute_sql(engine: Engine, sql_query: str) -> None:
    """Выполнение запроса к базе данных"""
    try:
        with engine.connect() as connection:
            connection.execute(sql_query)
            logging.info(f"Executed SQL query: {sql_query}")
    except Exception as e:
        logging.error(f"Error executing SQL query: {e.args}")


def manage_schema(engine: Engine, action: str, schema_name: str, new_schema_name: Optional[str]=None) -> None:
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


def create_tables(source_engine: Engine, target_engine: Engine, schema_name: str) -> None:
    """Создание таблиц в собственной базе данных"""
    meta = MetaData(schema=schema_name)
    meta.reflect(bind=source_engine)

    logging.info("Creating tables in the destination database...")
    for table in meta.tables.values():
        logging.info(f"Table: {table.name}")
    meta.create_all(bind=target_engine)
    logging.info("Tables created successfully.")


def get_table_names(source_engine: Engine, schema_name: Engine) -> List[Dict[str, str]]:
    """Возвращает список таблиц в общей базе данных"""
    meta = MetaData(schema=schema_name)
    meta.reflect(bind=source_engine)
    array = []
    for table in meta.tables.values():
        logging.info(f"Creating transfer task for table: {table.name}")
        array.append({'table': table.name})
        logging.info(f"Task transfer_{table.name} created.")

    return array
