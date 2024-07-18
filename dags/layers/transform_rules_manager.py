import pandas as pd
from airflow.models import Variable
from airflow.providers.postgres.hooks.postgres import PostgresHook
from sqlalchemy.engine import Engine
import logging

import layers.dm.transform_rules as t_rules


def get_data_from_airflow_var(airflow_var_name: str) -> dict:
    """
    Получение данных из переменной Airflow и настройка соединений с Postgres.

    :param airflow_var_name: Имя переменной Airflow, содержащей необходимые данные.
    :return: Словарь с данными схем и соединениями SQLAlchemy.
    """
    try:
        # Получение и десериализация переменной Airflow
        airflow_var_data: dict = Variable.get(airflow_var_name, deserialize_json=True)
        logging.info(
            "Successfully retrieved data from Airflow variable: %s", airflow_var_name
        )

        # Распаковка названий схем и подключений
        source_schema: str = airflow_var_data['source_schema']
        target_schema: str = airflow_var_data['target_schema']
        source_conn_id: str = airflow_var_data['source_conn_id']
        target_conn_id: str = airflow_var_data['target_conn_id']

    except KeyError as e:
        logging.error("Key error unpacking data from Airflow var %s: %s", airflow_var_name, e)
        raise
    except Exception as e:
        logging.error("Error unpacking data from the Airflow var %s: %s", airflow_var_name, e)
        raise

    try:
        # Получение engine для распакованных идентификаторов соединений Postgres
        source_engine: Engine = PostgresHook(source_conn_id).get_sqlalchemy_engine()
        target_engine: Engine = PostgresHook(target_conn_id).get_sqlalchemy_engine()
        logging.info(
            "Successfully created SQLAlchemy engines for connections: %s, %s",
            source_conn_id,
            target_conn_id
        )

    except Exception as e:
        logging.error(
            "Error creating SQLAlchemy engines for connections: %s, %s",
            source_conn_id,
            target_conn_id
        )
        raise

    return {
        'source_schema': source_schema,
        'source_engine': source_engine,
        'target_schema': target_schema,
        'target_engine': target_engine,
    }


def sql_query_executer_by_path(path_to_sql_query: str, engine: Engine) -> None:
    """
    Выполнение SQL-скрипта по указанному пути.

    :param path_to_sql_query: Путь к файлу с SQL-скриптом.
    :type path_to_sql_query: str
    :param engine: SQLAlchemy engine для выполнения запроса.
    :type engine: Engine
    """
    try:
        with engine.connect() as connection:
            with connection.begin() as transaction:
                # Открытие и чтение SQL-скрипта из файла
                with open(path_to_sql_query) as sql_file:
                    sql_query = sql_file.read()
                # Выполнение SQL-скрипта
                connection.execute(sql_query)
                # Коммит транзакции
                transaction.commit()
    except Exception as e:
        # Откат транзакции в случае ошибки
        transaction.rollback()
        raise RuntimeError(f"Error executing SQL script: {e}")


def load_data_to_target_table(
    target_schema: str,
    target_table: str,
    target_engine: Engine,
    transformed_data: pd.DataFrame,
):
    try:
        with target_engine.begin() as connection:
            # Очистка целевой таблицы перед загрузкой новых данных
            connection.execute(
                f'TRUNCATE TABLE {target_schema}.{target_table} RESTART IDENTITY CASCADE'
            )
            # Загрузка преобразованных данных в целевую таблицу
            transformed_data.to_sql(
                target_table, connection, if_exists='append', index=False, schema=target_schema
            )
    except Exception as e:
        # Обработка ошибок при загрузке данных в целевую таблицу
        raise RuntimeError(f"Error loading data into table {target_table}: {e}")


def etl_for_dm(
    source_schema: str,
    source_engine: Engine,
    target_schema: str,
    target_engine: Engine,
):
    # ETL процесс для таблицы 'knowledge_levels'
    source_data = pd.read_sql_table('уровни_знаний', source_engine, schema=source_schema)
    target_table = 'уровни_знаний'
    transformed_data: pd.DataFrame = t_rules.etl_knowledge_levels(
        dds_ira_knowledge_levels=source_data
    )
    load_data_to_target_table(
        target_schema=target_schema,
        target_table=target_table,
        target_engine=target_engine,
        transformed_data=transformed_data,
    )

    # ETL процесс для таблицы 'dar_employees'
    target_table = 'сотрудники_дар'
    transformed_data: pd.DataFrame = t_rules.etl_dar_employees(
        dds_ira_employees=pd.read_sql_table(
            'сотрудники_дар', source_engine, schema=source_schema
        )
    )
    load_data_to_target_table(
        target_schema=target_schema,
        target_table=target_table,
        target_engine=target_engine,
        transformed_data=transformed_data,
    )

    # ETL процесс для таблицы 'skill_groups'
    target_table = 'группы_навыков'
    transformed_data: pd.DataFrame = t_rules.etl_skill_groups()
    load_data_to_target_table(
        target_schema=target_schema,
        target_table=target_table,
        target_engine=target_engine,
        transformed_data=transformed_data,
    )

    # ETL процесс для таблицы 'skills'
    target_table = 'навыки'
    transformed_data: pd.DataFrame = t_rules.etl_skills(
        [
            pd.read_sql_table('базы_данных', source_engine, schema=source_schema),
            pd.read_sql_table('инструменты', source_engine, schema=source_schema),
            pd.read_sql_table('платформы', source_engine, schema=source_schema),
            pd.read_sql_table('среды_разработки', source_engine, schema=source_schema),
            pd.read_sql_table('технологии', source_engine, schema=source_schema),
            pd.read_sql_table('типы_систем', source_engine, schema=source_schema),
            pd.read_sql_table('фреймворки', source_engine, schema=source_schema),
            pd.read_sql_table('языки_программирования', source_engine, schema=source_schema),
        ]
    )
    load_data_to_target_table(
        target_schema=target_schema,
        target_table=target_table,
        target_engine=target_engine,
        transformed_data=transformed_data,
    )

    # ETL процесс для таблицы 'transformed_data'
    target_table = 'группы_навыков_и_уровень_знаний_со'
    transformed_data: pd.DataFrame = t_rules.etl_skills_knowledge(
        [
            'базы_данных_и_уровень_знаний_сотру,Базы данных',
            'инструменты_и_уровень_знаний_сотр,инструменты',
            'платформы_и_уровень_знаний_сотруд,платформы',
            'среды_разработки_и_уровень_знаний_,Среды разработки',
            'технологии_и_уровень_знаний_сотру,технологии',
            'типы_систем_и_уровень_знаний_сотру,Типы систем',
            'фреймворки_и_уровень_знаний_сотру,фреймворки',
            'языки_программирования_и_уровень,Языки программирования'
        ],{'базы_данных_и_уровень_знаний_сотру':
                       pd.read_sql_table('базы_данных_и_уровень_знаний_сотру', source_engine, schema=source_schema),
           'инструменты_и_уровень_знаний_сотр':
               pd.read_sql_table('инструменты_и_уровень_знаний_сотр', source_engine, schema=source_schema),
           'платформы_и_уровень_знаний_сотруд':
                       pd.read_sql_table('платформы_и_уровень_знаний_сотруд', source_engine, schema=source_schema),
           'среды_разработки_и_уровень_знаний_':
                       pd.read_sql_table('среды_разработки_и_уровень_знаний_', source_engine, schema=source_schema),
           'технологии_и_уровень_знаний_сотру':
                       pd.read_sql_table('технологии_и_уровень_знаний_сотру', source_engine, schema=source_schema),
           'типы_систем_и_уровень_знаний_сотру':
                       pd.read_sql_table('типы_систем_и_уровень_знаний_сотру', source_engine, schema=source_schema),
           'фреймворки_и_уровень_знаний_сотру':
                       pd.read_sql_table('фреймворки_и_уровень_знаний_сотру', source_engine, schema=source_schema),
           'языки_программирования_и_уровень':
                       pd.read_sql_table('языки_программирования_и_уровень', source_engine, schema=source_schema)
        }, pd.read_sql_table('сотрудники_дар', target_engine, schema=target_schema),
        pd.read_sql_table('навыки', target_engine, schema=target_schema)
    )
    load_data_to_target_table(
        target_schema=target_schema,
        target_table=target_table,
        target_engine=target_engine,
        transformed_data=transformed_data,
    )
