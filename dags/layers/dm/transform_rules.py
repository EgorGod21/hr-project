import inspect
import functools
import logging
import re
import typing as t

import pandas as pd

from layers.abs_transform_ruler import TransformRules


class DMTransformRules(TransformRules):
    """
    Класс, содержащий правила трансформации данных для различных таблиц слоя DDS.
    """

    # Словарь для хранения связей между таблицами и функциями трансформации
    comparison_tables_and_transformation_rules: t.Dict[str, t.Callable] = {}

    def __init__(self) -> None:
        # Информация из источника данных
        self.source_data: t.Dict[str, pd.DataFrame] = {}

        # Вызов метода для инициализации словаря связей
        self.__invoke_all_transform_methods()

    def run_transform_rule_for_table(
            self,
            table: str
    ) -> pd.DataFrame:
        """
        Запуск правила трансформации для указанной таблицы.

        :param table: Название таблицы.
        :type table: str
        :return: Трансформированные данные.
        :rtype: pd.DataFrame
        """
        data_copy: pd.DataFrame = self.source_data[table].copy()
        if transform_fun := self.comparison_tables_and_transformation_rules.get(table):
            return transform_fun(self, data_copy)
        else:
            return data_copy

    def set_source_data(self, source_data: t.Dict[str, pd.DataFrame]) -> None:
        self.source_data = source_data

    def __invoke_all_transform_methods(self) -> None:
        """
        Вызов методов трансформации, определенных в классе для инициализации словаря.

        Метод находит все методы, начинающиеся с '__transform_', и вызывает их.
        """
        for name, method in inspect.getmembers(self, predicate=inspect.ismethod):
            if name.startswith('_transform_'):
                method(None)

    @staticmethod
    def __register_transform(table: str) -> t.Callable:
        """
        Декоратор для сопоставления методов трансформации и названий таблиц.

        :param table: Название таблицы, для которой предназначен метод трансформации.
        :type table: str
        :return: Декорированный метод трансформации.
        :rtype: t.Callable
        """
        def decorator(func: t.Callable) -> t.Callable:
            @functools.wraps(func)
            def wrapper(*args, **kwargs):
                self = args[0]
                self.comparison_tables_and_transformation_rules[table] = func
                return func(*args, **kwargs)
            return wrapper
        return decorator

    @__register_transform(table='сотрудники_дар')
    def _transform_employee_dar(
            self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'сотрудники_дар'"""
        if data is not None:
            # Удаление из data столбца 'Дата рождения'
            if 'Дата рождения' in data.columns:
                data = data.drop(columns=['Дата рождения'])

            # Удаление из data столбца 'пол'
            if 'пол' in data.columns:
                data = data.drop(columns=['пол'])

            # Удаление из data столбца 'Последняя авторизация'
            if 'Последняя авторизация' in data.columns:
                data = data.drop(columns=['Последняя авторизация'])

            # Удаление из data столбца 'Дата регистрации'
            if 'Дата регистрации' in data.columns:
                data = data.drop(columns=['Дата регистрации'])

            # Удаление из data столбца 'Дата изменения'
            if 'Дата изменения' in data.columns:
                data = data.drop(columns=['Дата изменения'])

            # Удаление из data столбца 'подразделения'
            if 'подразделения' in data.columns:
                data = data.drop(columns=['подразделения'])

            # Удаление из data столбца 'E-Mail'
            if 'E-Mail' in data.columns:
                data = data.drop(columns=['E-Mail'])

            # Удаление из data столбца 'логин'
            if 'логин' in data.columns:
                data = data.drop(columns=['логин'])

            # Удаление из data столбца 'компания'
            if 'компания' in data.columns:
                data = data.drop(columns=['компания'])

            # Удаление из data столбца 'Город проживания'
            if 'Город проживания' in data.columns:
                data = data.drop(columns=['Город проживания'])

            # Удаление из data строки, где 'активность' равна 'нет'
            data = data[data['активность'] != 'Нет']

            # Удаление из data строки, где 'цфо' не равно 'DAR'
            data = data[data['цфо'] == 'DAR']

            # Заменяем в столбце "должность" все вариации системного аналитика на "Системный аналитик"
            data['должность'] = data['должность'].apply(
                lambda x: 'Системный аналитик' if re.search(r'системный аналитик', x, re.IGNORECASE) else x
            )

            # Заменяем в столбце "должность" все вариации бизнес-аналитика на "Бизнес-аналитик"
            data['должность'] = data['должность'].apply(
                lambda x: 'Бизнес-аналитик' if re.search(r'бизнес-аналитик', x, re.IGNORECASE) and not re.search(
                    r'бизнес-аналитики', x, re.IGNORECASE) else x
            )

            # Заменяем в столбце "должность" все вариации инженера данных на "Инженер данных"
            data['должность'] = data['должность'].apply(
                lambda x: 'Инженер данных' if re.search(r'инженер данных', x, re.IGNORECASE) else x
            )

            # Заменяем в столбце "должность" все вариации руководителя проектов на "Руководитель проектов"
            data['должность'] = data['должность'].apply(
                lambda x: 'Руководитель проектов' if re.search(r'руководитель проектов', x, re.IGNORECASE) else x
            )

            # Заменяем в столбце "должность" все вариации тестировщика на "Тестировщик"
            data['должность'] = data['должность'].apply(
                lambda x: 'Тестировщик' if re.search(r'тестировщик|инженер по тестированию', x, re.IGNORECASE) else x
            )

            # Заменяем в столбце "должность" все вариации архитектора на "Архитектор"
            data['должность'] = data['должность'].apply(
                lambda x: 'Архитектор' if re.search(r'архитектор', x, re.IGNORECASE) else x
            )

            # Удаление строк, где должность не соответствует заданным значениям
            allowed_positions = ['Системный аналитик', 'Бизнес-аналитик', 'Инженер данных', 'Тестировщик',
                                 'Руководитель проектов', 'Архитектор']
            data = data[data['должность'].isin(allowed_positions)]

            # Заменяем название столбца 'должность' на 'Роль'
            if 'должность' in data.columns:
                data = data.rename(columns={'должность': 'Роль'})

            # Удаление из data столбца 'цфо'
            if 'цфо' in data.columns:
                data = data.drop(columns=['цфо'])

            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            return data

    @__register_transform(table='базы_данных')
    def _transform_databases(self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'базы_данных'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            return data

    @__register_transform(table='инструменты')
    def _transform_tools(self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'инструменты'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            return data

    @__register_transform(table='платформы')
    def _transform_platforms(
            self,
            data: pd.DataFrame
        ) -> pd.DataFrame:
        """Трансформация данных для 'платформы'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            return data

    @__register_transform(table='среды_разработки')
    def _transform_development_environments(
            self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'среды_разработки'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            return data

    @__register_transform(table='технологии')
    def _transform_technologies(
            self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'технологии'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            return data

    @__register_transform(table='типы_систем')
    def _transform_systems(
            self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'типы_систем'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            return data

    @__register_transform(table='фреймворки')
    def _transform_frameworks(
            self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'фреймворки'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            return data

    @__register_transform(table='языки_программирования')
    def _transform_programming_languages(
            self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'языки_программирования'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            return data

    @__register_transform(table='уровни_знаний')
    def _transform_knowledge_levels(
            self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'уровни_знаний'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            return data

    @__register_transform(table='базы_данных_и_уровень_знаний_сотру')
    def _transform_employee_databases_knowlege(
            self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'базы_данных_и_уровень_знаний_сотру'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                 data = data.drop(columns=['активность'])

            data['дата'] = data['дата'].fillna(data['Дата изм.'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = self.source_data['сотрудники_дар'].copy()
            logging.info(f"сырые данные {table_data[['цфо', 'активность']]}")
            table_data=table_data[(table_data['цфо'] == 'DAR') & (table_data['активность'] == 'Да')]
            logging.info(f"обработанные данные {table_data}")
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            return data

    @__register_transform(table='инструменты_и_уровень_знаний_сотр')
    def _transform_tools_knowlege(
            self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'инструменты_и_уровень_знаний_сотр'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            data['дата'] = data['дата'].fillna(data['Дата изм.'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = self.source_data['сотрудники_дар'].copy()
            table_data = table_data[(table_data['цфо'] == 'DAR') & (table_data['активность'] == 'Да')]
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            return data

    @__register_transform(table='платформы_и_уровень_знаний_сотруд')
    def _transform_platforms_knowledge(
            self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'платформы_и_уровень_знаний_сотруд'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            data['дата'] = data['дата'].fillna(data['Дата изм.'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = self.source_data['сотрудники_дар'].copy()
            table_data = table_data[(table_data['цфо'] == 'DAR') & (table_data['активность'] == 'Да')]
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            return data

    @__register_transform(table='среды_разработки_и_уровень_знаний_')
    def _transform_development_environments_knowledge(
            self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'среды_разработки_и_уровень_знаний_'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            data['дата'] = data['дата'].fillna(data['Дата изм.'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = self.source_data['сотрудники_дар'].copy()
            table_data = table_data[(table_data['цфо'] == 'DAR') & (table_data['активность'] == 'Да')]
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            return data

    @__register_transform(table='технологии_и_уровень_знаний_сотру')
    def _transform_technologies_knowledge(
            self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'технологии_и_уровень_знаний_сотру'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            data['дата'] = data['дата'].fillna(data['Дата изм.'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = self.source_data['сотрудники_дар'].copy()
            table_data = table_data[(table_data['цфо'] == 'DAR') & (table_data['активность'] == 'Да')]
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            return data

    @__register_transform(table='типы_систем_и_уровень_знаний_сотру')
    def _transform_systems_knowledge(
            self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'типы_систем_и_уровень_знаний_сотру'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            data['дата'] = data['дата'].fillna(data['Дата изм.'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = self.source_data['сотрудники_дар'].copy()
            table_data = table_data[(table_data['цфо'] == 'DAR') & (table_data['активность'] == 'Да')]
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            return data

    @__register_transform(table='фреймворки_и_уровень_знаний_сотру')
    def _transform_frameworks_level(
            self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'фреймворки_и_уровень_знаний_сотру'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            data['дата'] = data['дата'].fillna(data['Дата изм.'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = self.source_data['сотрудники_дар'].copy()
            table_data = table_data[(table_data['цфо'] == 'DAR') & (table_data['активность'] == 'Да')]
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            return data

    @__register_transform(table='языки_программирования_и_уровень')
    def _transform_programming_languages_levels(
            self,
            data: pd.DataFrame
    ) -> pd.DataFrame:
        """Трансформация данных для 'языки_программирования_и_уровень'"""
        if data is not None:
            # Удаление из data столбца 'активность'
            if 'активность' in data.columns:
                data = data.drop(columns=['активность'])

            data['дата'] = data['дата'].fillna(data['Дата изм.'])

            # Удаление из data столбца 'Дата изм.'
            if 'Дата изм.' in data.columns:
                data = data.drop(columns=['Дата изм.'])

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = self.source_data['сотрудники_дар'].copy()
            table_data = table_data[(table_data['цфо'] == 'DAR') & (table_data['активность'] == 'Да')]
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            return data

