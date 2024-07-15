import typing as t

import pandas as pd
from sqlalchemy.engine import Engine
from sqlalchemy.exc import SQLAlchemyError

from layers.transform_rules_manager import TransformRulesManager


class LayerManager:
    def __init__(self, rules: TransformRulesManager) -> None:
        """
        Инициализация менеджера для управления ETL-процессами и создания целевого слоя.

        :param rules: Экземпляр класса TransformRules для трансформаций данных.
        :type rules: TransformRules
        """
        self.rules: TransformRulesManager = rules

    @staticmethod
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

    def etl_process_implementation(
        self,
        source_tables: t.List[str],
        source_engine: Engine,
        source_schema: str,
        target_tables: t.List[str],
        target_engine: Engine,
        target_schema: str
    ) -> None:
        """
        Выполнение процесса ETL (Extract, Transform, Load).

        :param source_tables: Список таблиц источника.
        :type source_tables: List[str]
        :param source_engine: SQLAlchemy engine для источника данных.
        :type source_engine: Engine
        :param source_schema: Схема источника данных.
        :type source_schema: str
        :param target_tables: Список таблиц назначения.
        :type target_tables: List[str]
        :param target_engine: SQLAlchemy engine для назначения данных.
        :type target_engine: Engine
        :param target_schema: Схема назначения данных.
        :type target_schema: str
        """
        # Словарь для хранения данных источника
        source_data: t.Dict[str, pd.DataFrame] = {}

        # [Extract] Извлечение данных из источника
        for source_table in source_tables:
            try:
                # Чтение данных из таблицы источника и сохранение в DataFrame
                data: pd.DataFrame = pd.read_sql_table(
                    source_table, source_engine, schema=source_schema
                )
                # Сохранение данных в словарь source_data
                source_data[source_table] = data
            except SQLAlchemyError as e:
                # Обработка ошибок при извлечении данных из источника
                raise RuntimeError(f"Error extracting data from table {source_table}: {e}")

        # Кэширование данных источника для уменьения SELECT запросов
        self.rules.set_source_data(source_data)

        # [Transform] & [Load] Трансформация и загрузка данных в целевые таблицы
        for target_table in target_tables:
            try:
                # Трансформация данных для целевой таблицы
                transformed_data: pd.DataFrame = self.rules.run_transform_rule_for_table(
                    target_table
                )

                with target_engine.begin() as connection:
                    # Очистка целевой таблицы перед загрузкой новых данных
                    connection.execute(
                        f'TRUNCATE TABLE {target_schema}.{target_table} RESTART IDENTITY CASCADE'
                    )
                    # Загрузка преобразованных данных в целевую таблицу
                    transformed_data.to_sql(
                        target_table, connection, if_exists='append', index=False, schema=target_schema
                    )
            except SQLAlchemyError as e:
                # Обработка ошибок при загрузке данных в целевую таблицу
                raise RuntimeError(f"Error loading data into table {target_table}: {e}")
