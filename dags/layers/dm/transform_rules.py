import re
from typing import List

import pandas as pd

from layers.transform_rules_manager import TransformRulesManager


class DMTransformRules(t_manager := TransformRulesManager):
    """
    Определяет правила трансформации данных для слоя DM.
    """

    @t_manager.register_transformation_rule(tables=['сотрудники_дар'])
    def _transform_employee_dar(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Трансформация данных для 'сотрудники_дар'.
        """

        # Удаление строк, где 'активность' равна 'Нет' или 'цфо' не равно 'DAR'
        data = data[data['цфо'] == 'DAR']


        # Удаление ненужных столбцов
        columns_to_drop = [
            'Дата рождения', 'пол', 'Последняя авторизация', 'Дата регистрации',
            'Дата изменения', 'подразделения', 'E-Mail', 'логин', 'компания',
            'Город проживания', 'цфо'
        ]
        data.drop(
            columns=[col for col in columns_to_drop if col in data.columns],
            inplace=True,
            errors='ignore'
        )

        # Замена вариаций должностей на стандартные наименования
        data['должность'] = self._standardize_positions(data['должность'])

        # Удаление строк, где должность не соответствует заданным значениям
        allowed_positions = {
            'Системный аналитик', 'Бизнес-аналитик', 'Инженер данных', 'Тестировщик',
            'Руководитель проектов', 'Архитектор'
        }
        data = data[data['должность'].isin(allowed_positions)]

        return data

    @staticmethod
    def _drop_columns(data: pd.DataFrame, columns: List[str]) -> pd.DataFrame:
        """
        Удаление указанных столбцов из DataFrame.
        """
        data.drop(columns=columns, inplace=True, errors='ignore')
        return data

    @staticmethod
    def _standardize_positions(positions: pd.Series) -> pd.Series:
        """
        Стандартизация наименований должностей.
        """
        replacements = {
            'Системный аналитик': r'системный аналитик',
            'Бизнес-аналитик': r'бизнес-аналитик(?!и)',
            'Инженер данных': r'инженер данных',
            'Руководитель проектов': r'руководитель проектов',
            'Тестировщик': r'тестировщик|инженер по тестированию',
            'Архитектор': r'архитектор'
        }
        for role, pattern in replacements.items():
            positions = positions.apply(
                lambda x: role if re.search(pattern, x, re.IGNORECASE) else x
            )
        return positions

    @t_manager.register_transformation_rule(
        tables=[
            'базы_данных', 'инструменты', 'платформы', 'среды_разработки', 'технологии',
            'типы_систем', 'фреймворки', 'языки_программирования', 'уровни_знаний'
        ]
    )
    def _transform_data_by_drop(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Трансформация данных для множества таблиц.
        """
        return self._drop_columns(data, ['активность', 'Дата изм.'])

    @t_manager.register_transformation_rule(
        tables=[
            'базы_данных_и_уровень_знаний_сотру', 'инструменты_и_уровень_знаний_сотр',
            'платформы_и_уровень_знаний_сотруд', 'среды_разработки_и_уровень_знаний_',
            'технологии_и_уровень_знаний_сотру', 'типы_систем_и_уровень_знаний_сотру',
            'фреймворки_и_уровень_знаний_сотру', 'языки_программирования_и_уровень',
        ]
    )
    def _transform_knowledge_data(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Трансформация данных для множества таблиц "*уровень_знаний*".
        """
        data = self._drop_columns(data, ['активность'])
        data['дата'].fillna(data['Дата изм.'], inplace=True)
        data = self._drop_columns(data, ['Дата изм.'])
        return self._filter_active_dar_employees(data)

    def _filter_active_dar_employees(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Фильтрует строки, оставляя только активных сотрудников из подразделения DAR.
        """
        valid_ids = set(
            self.source_data['сотрудники_дар'].loc[
                (self.source_data['сотрудники_дар']['цфо'] == 'DAR') &
                (self.source_data['сотрудники_дар']['активность'] == 'Да'), 'id'
            ]
        )
        return data[data['User ID'].isin(valid_ids)]
