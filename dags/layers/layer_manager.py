import typing as t

import pandas as pd
from sqlalchemy.engine import Engine

from layers.abs_transform_ruler import TransformRules


class LayerManager:
    def __init__(self, rules: TransformRules):
        self.rules = rules

    @staticmethod
    def sql_query_executer_by_path(path_to_sql_query: str, engine: Engine) -> None:
        """Выполнение SQL-скрипта по пути path_to_sql_query"""
        with engine.connect() as connection:
            with connection.begin() as transaction:
                try:
                    with open(path_to_sql_query) as sql_file:
                        sql_query = sql_file.read()
                        connection.execute(sql_query)
                        transaction.commit()  # Явное подтверждение транзакции
                except Exception as e:
                    transaction.rollback()  # Откат в случае ошибки

    def etl_process_implementation(
            self,
            source_tables: t.List[str],
            source_engine: Engine,
            source_schema: str,
            target_tables: t.List[str],
            target_engine: Engine,
            target_schema: str
    ):
        source_data: t.Dict[str, pd.DataFrame] = dict()

        # Получение данных из источника [Extract]: реализация процесса выгрузки данных
        for source_table in source_tables:
            # Извлечение данных конкретного столбца из источника
            data: pd.DataFrame = pd.read_sql_table(
                source_table, source_engine, schema=source_schema
            )
            # Сохранение данных источника в словарь
            source_data[source_table] = data

        self.rules.set_source_data(source_data)

        # Трансформация и загрузка данных в таргетную таблицу: [Transform] и [Load]
        for target_table in target_tables:
            # Реализация процесса трансформации даннных [Transform]
            transformed_data: pd.DataFrame = self.rules.run_transform_rule_for_table(
                target_table
            )

            # Реализация процесса загрузки данных [Load]
            with target_engine.begin() as connection:
                connection.execute(f'TRUNCATE TABLE {target_schema}.{target_table} RESTART IDENTITY CASCADE')
            transformed_data.to_sql(
                target_table, target_engine, if_exists='append', index=False, schema=target_schema
            )
