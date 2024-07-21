import logging
import typing as t

import pandas as pd
from airflow.models import Variable
from airflow.providers.postgres.hooks.postgres import PostgresHook
from sqlalchemy.engine import Engine

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
    """
    Загружает преобразованные данные в указанную целевую таблицу.

    :param target_schema: Название схемы целевой базы данных.
    :param target_table: Название целевой таблицы.
    :param target_engine: SQLAlchemy engine для подключения к целевой базе данных.
    :param transformed_data: DataFrame с преобразованными данными для загрузки.
    """
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
    """
    Выполняет ETL процесс для Data Mart.

    :param source_schema: Название схемы источника данных.
    :param source_engine: SQLAlchemy engine для подключения к базе данных источника.
    :param target_schema: Название схемы целевой базы данных.
    :param target_engine: SQLAlchemy engine для подключения к целевой базе данных.
    """
    # Лямбда функция для получения DataFrame из таблицы базы данных
    get_df: t.Callable[[str, Engine, str], pd.DataFrame] =\
        lambda table, engine, schema: pd.read_sql_table(table, engine, schema)

    # Словарь задач ETL процесса с указанием таблиц, исходных данных и функций трансформации
    etl_tasks: t.Dict[str, t.Dict[str, t.Union[
        t.Callable[[], pd.DataFrame],
        t.List[pd.DataFrame],
        t.Callable[[pd.DataFrame], pd.DataFrame]
    ]]] = {
        'уровни_знаний': {
            'source_data': lambda: get_df('уровни_знаний', source_engine, source_schema),
            'transform_rules': t_rules.etl_knowledge_levels,
        },
        'сотрудники_дар': {
            'source_data': lambda: get_df('сотрудники_дар', source_engine, source_schema),
            'transform_rules': t_rules.etl_dar_employees,
        },
        'группы_навыков': {
            'source_data': lambda: None,
            'transform_rules': t_rules.etl_skill_groups,
        },
        'навыки': {
            'source_data': lambda: [
                get_df('базы_данных', source_engine, source_schema),
                get_df('инструменты', source_engine, source_schema),
                get_df('платформы', source_engine, source_schema),
                get_df('среды_разработки', source_engine, source_schema),
                get_df('технологии', source_engine, source_schema),
                get_df('типы_систем', source_engine, source_schema),
                get_df('фреймворки', source_engine, source_schema),
                get_df('языки_программирования', source_engine, source_schema),
            ],
            'transform_rules': t_rules.etl_skills,
        },
        'группы_навыков_и_уровень_знаний_со': {
            'source_data': lambda: [
                {
                    'базы_данных_и_уровень_знаний_сотру': {
                        'column_name': 'Базы данных',
                        'df': get_df('базы_данных_и_уровень_знаний_сотру', source_engine, source_schema),
                    },
                    'инструменты_и_уровень_знаний_сотр': {
                        'column_name': 'инструменты',
                        'df': get_df('инструменты_и_уровень_знаний_сотр', source_engine, source_schema),
                    },
                    'платформы_и_уровень_знаний_сотруд': {
                        'column_name': 'платформы',
                        'df': get_df('платформы_и_уровень_знаний_сотруд', source_engine, source_schema),
                    },
                    'среды_разработки_и_уровень_знаний_': {
                        'column_name': 'Среды разработки',
                        'df': get_df('среды_разработки_и_уровень_знаний_', source_engine, source_schema),
                    },
                    'технологии_и_уровень_знаний_сотру': {
                        'column_name': 'технологии',
                        'df': get_df('технологии_и_уровень_знаний_сотру', source_engine, source_schema),
                    },
                    'типы_систем_и_уровень_знаний_сотру': {
                        'column_name': 'Типы систем',
                        'df': get_df('типы_систем_и_уровень_знаний_сотру', source_engine, source_schema),
                    },
                    'фреймворки_и_уровень_знаний_сотру': {
                        'column_name': 'фреймворки',
                        'df': get_df('фреймворки_и_уровень_знаний_сотру', source_engine, source_schema),
                    },
                    'языки_программирования_и_уровень': {
                        'column_name': 'Языки программирования',
                        'df': get_df('языки_программирования_и_уровень', source_engine, source_schema),
                    },
                },
                get_df('сотрудники_дар', target_engine, target_schema),
                get_df('навыки', target_engine, schema=target_schema),
            ],
            'transform_rules': t_rules.etl_skills_knowledge,
        },
    }

    # Выполнение ETL процесса для каждой задачи из словаря
    target_tables = list(etl_tasks.keys())
    for target_table in target_tables:
        source_data = etl_tasks[target_table]['source_data']()
        transform_rules = etl_tasks[target_table]['transform_rules']

        # Применение правил трансформации к исходным данным
        if source_data is not None:
            if isinstance(source_data, list):
                transformed_data: pd.DataFrame = transform_rules(*source_data)
            else:
                transformed_data: pd.DataFrame = transform_rules(source_data)
        else:
            transformed_data: pd.DataFrame = transform_rules()

        # Загрузка преобразованных данных в целевую таблицу
        load_data_to_target_table(
            target_schema=target_schema,
            target_table=target_table,
            target_engine=target_engine,
            transformed_data=transformed_data,
        )

        # Очищения словаря для освобождения памяти
        del etl_tasks[target_table]
