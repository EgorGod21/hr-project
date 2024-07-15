import functools
import typing as t

import pandas as pd


class TransformRulesManager:
    """
    Управляет логикой создания связей между таблицами и методами трансформации.

    :ivar comparison_tables_and_transformation_rules: Словарь для хранения связей между
                                                      названиями таблиц и соответствующими
                                                      методами трансформации данных.
    :vartype comparison_tables_and_transformation_rules: dict[str, callable]
    :ivar source_data: Словарь для хранения исходных данных, где
                       ключ - название таблицы, а значение - данные в формате DataFrame.
    :vartype source_data: dict[str, pd.DataFrame]
    """

    def __init__(self):
        # Словарь для хранения связей таблиц и методов трансформации
        self.comparison_tables_and_transformation_rules: t.Dict[str, t.Callable] = {}

        # Словарь с исходными данными
        self.source_data: t.Dict[str, pd.DataFrame] = {}

        # Регистрация всех методов трансформации
        self.register_all_transform_rules()

    def set_source_data(self, source_data: t.Dict[str, pd.DataFrame]) -> None:
        """
        Кэширует данные источника для уменьшения количества SELECT запросов.

        :param source_data: Словарь с данными источника, где ключ - название таблицы,
                            а значение - DataFrame с данными таблицы.
        :type source_data: dict[str, pd.DataFrame]
        """
        self.source_data = source_data  # Кэширование исходных данных

    def run_transform_rule_for_table(self, table: str) -> pd.DataFrame:
        """
        Запускает процесс трансформации данных для одной таблицы.

        :param table: Название таблицы, для которой будет выполнена трансформация.
        :type table: str
        :return: Преобразованные данные в виде DataFrame.
        :rtype: pd.DataFrame
        """
        # Получение копии данных из исходного словаря по названию таблицы
        if (data_copy := self.source_data.get(table)) is not None:
            data_copy = data_copy.copy()  # Создание копии данных

            # Вызов метода трансформации для таблицы, если он существует
            if transform_fun := self.comparison_tables_and_transformation_rules.get(table):
                return transform_fun(self, data_copy)  # Применение метода трансформации к данным
            return data_copy  # Возврат копии данных без трансформации, если метод не найден
        else:
            raise ValueError(f"No data found for table {table}")

    @staticmethod
    def register_transformation_rule(tables: t.List[str]) -> t.Callable:
        """
        Декоратор для сопоставления метода трансформации и названий таблиц.

        :param tables: Названия таблиц, для которых предназначен декорируемый метод трансформации.
        :type tables: List[str]
        :return: Декорированный метод трансформации.
        :rtype: t.Callable
        """
        def decorator(func: t.Callable) -> t.Callable:
            """
            Декоратор для метода трансформации.

            :param func: Метод трансформации данных.
            :type func: callable
            :return: Декорированный метод трансформации.
            :rtype: callable
            """
            # Функция для регистрации метода трансформации с таблицами через общий словарь
            def register(self):
                for table in tables:
                    self.comparison_tables_and_transformation_rules[table] = func
                return func

            func._register = register  # Добавление функции регистрации в качестве атрибута метода

            @functools.wraps(func)
            def wrapper(self, *args, **kwargs):
                # Вызов оригинального метода
                return func(self, *args, **kwargs)

            return wrapper

        return decorator

    def register_all_transform_rules(self) -> None:
        """
        Регистрирует все методы трансформации, помеченные
        декоратором register_transform_rule_for_table.
        """
        try:
            # Перебор всех атрибутов класса
            for name, method in self.__class__.__dict__.items():
                if hasattr(method, '_register'):
                    method._register(self)  # Регистрация метода трансформации
        except Exception as e:
            print(f"Error during registering transform rules: {e}")
            raise
