import random
import re
import typing as t
from typing import List

from faker import Faker
import pandas as pd

from layers.transform_rules_manager import TransformRulesManager

# Инициализация экземпляра Faker для генерации фамилий и имен
fake = Faker('ru_RU')


class DMTransformRules(t_manager := TransformRulesManager):
    """
    Определяет правила трансформации данных для слоя DM.
    """

    @t_manager.register_transformation_rule(tables=['сотрудники_дар'])
    def _transform_employee_dar(self, data=None) -> pd.DataFrame:
        """
        Трансформация данных для 'сотрудники_дар'.
        """
        role_mapping = {
            'Системный аналитик': r'системный аналитик',
            'Бизнес-аналитик': r'бизнес-аналитик(?!и)',
            'Инженер данных': r'инженер данных',
            'Руководитель проектов': r'руководитель проектов',
            'Тестировщик': r'тестировщик|инженер по тестированию',
            'Архитектор': r'архитектор',
            'Разработчик': r'разработчик'
        }
        dds_ira_employees = self.source_data.get('сотрудники_дар')

        # Преобразование должностей в соответствии с заданными шаблонами
        for role, pattern in role_mapping.items():
            dds_ira_employees['должность'] = dds_ira_employees['должность'].apply(
                lambda x: role if x is not None and re.search(pattern, x, re.IGNORECASE) else x
            )

        # Фильтрация данных по условиям
        filtered_df = dds_ira_employees[
            (dds_ira_employees['цфо'] == 'DAR') &
            (dds_ira_employees['активность'] == 'Да') &
            (dds_ira_employees['должность'].isin(role_mapping.keys()))
            ]

        # Переименование и выбор нужных столбцов
        result_df = filtered_df.rename(columns={
            'id': 'id_сотрудника',
            'фамилия': 'Фамилия',
            'имя': 'Имя',
            'должность': 'Роль'
        })[['id_сотрудника', 'Фамилия', 'Имя', 'Роль']]

        # Замена пустых строк на None
        result_df['Фамилия'] = result_df['Фамилия'].replace('', None)
        result_df['Имя'] = result_df['Имя'].replace('', None)

        # Получение индексов строк с отсутствующими фамилиями и именами
        na_first = result_df[result_df['Фамилия'].isna()].index
        na_last = result_df[result_df['Имя'].isna()].index

        # Генерация списка уникальных полных имен
        names_list = self.generate_unique_full_names(max(len(na_first), len(na_last)))

        # Замена отсутствующих фамилий и имен на сгенерированные значения
        for idx, full_name in zip(na_first, names_list):
            first_name, last_name = full_name.split()
            result_df.at[idx, 'Фамилия'] = last_name

        for idx, full_name in zip(na_last, names_list):
            first_name, last_name = full_name.split()
            result_df.at[idx, 'Имя'] = first_name

        return result_df


    @staticmethod
    def generate_unique_full_names(count: int) -> t.List[str]:
        """
        Функция генерации списка уникальных полных имен для случайного пола.

        :param count: Количество уникальных имен для генерации
        :return: Список уникальных полных имен
        """
        names = set()
        attempts = 0
        # Максимальное количество попыток для предотвращения бесконечного цикла
        max_attempts = count * 10

        # Генерация уникальных имен до достижения нужного количества или превышения максимума
        while len(names) < count and attempts < max_attempts:
            gender = random.choice(['male', 'female'])
            if gender == 'male':
                full_name = f"{fake.first_name_male()} {fake.last_name_male()}"
            else:
                full_name = f"{fake.first_name_female()} {fake.last_name_female()}"
            names.add(full_name)
            attempts += 1

        # Выброс ошибки, если невозможно сгенерировать достаточное количество уникальных имен
        if len(names) < count:
            raise ValueError("Невозможно сгенерировать достаточное количество уникальных имен.")

        return list(names)

    @t_manager.register_transformation_rule(tables=['уровни_знаний'])
    def _transform_knowledge_levels(self, data=None) -> pd.DataFrame:
        """
        Трансформация данных для 'уровни_знаний'.
        """
        dds_ira_knowledge_levels = self.source_data.get('уровни_знаний')
        # Фильтрация данных, исключая записи с названием 'Использовал на проекте'
        # и переименование столбцов
        result_df = dds_ira_knowledge_levels[
                dds_ira_knowledge_levels['название'] != 'Использовал на проекте'
        ][['id', 'название']].rename(columns={'id': 'id_уровня', 'название': 'Название'})

        return result_df

    @t_manager.register_transformation_rule(tables=['группы_навыков'])
    def _transform_skill_groups(self, data=None) -> pd.DataFrame:
        """
        Трансформация данных для 'группы_навыков'.
        """
        # Предопределенные группы навыков
        skill_groups = [
            'Инструменты', 'Базы данных', 'Платформы', 'Среды разработки',
            'Типы систем', 'Фреймворки', 'Языки программирования', 'Технологии'
        ]

        # Создание DataFrame из списка
        result_df = pd.DataFrame({
            'id_группы': list(range(1, len(skill_groups) + 1)),
            'Группа_навыков': skill_groups,
        })

        return result_df

    @t_manager.register_transformation_rule(tables=['навыки'])
    def _transform_skill(self, data=None) -> pd.DataFrame:
        """
        Трансформация данных для 'навыки'.
        """
        data_frames = [
                self.source_data.get('инструменты'),
                self.source_data.get('базы_данных'),
                self.source_data.get('платформы'),
                self.source_data.get('среды_разработки'),
                self.source_data.get('типы_систем'),
                self.source_data.get('фреймворки'),
                self.source_data.get('языки_программирования'),
                self.source_data.get('технологии'),
            ]

        # Фильтрация и объединение данных
        filtered_dfs = [
            df[df['название'] != 'Другое'][['id', 'название']] for df in data_frames
        ]

        # Объединение всех отфильтрованных DataFrame в один
        consolidated_skills_df = pd.concat(filtered_dfs, ignore_index=True)

        # Переименование и выбор нужных столбцов
        result_df = consolidated_skills_df.rename(columns={
            'id': 'id_навыка',
            'название': 'Название'
        })[['id_навыка', 'Название']]

        return result_df

    @t_manager.register_transformation_rule(tables=['группы_навыков_и_уровень_знаний_со'])
    def _transform_skills_knowledge(self, data=None) -> pd.DataFrame:
        """
        Трансформация данных для 'группы_навыков_и_уровень_знаний_со'.
        """

        knowledge_levels_by_category = {
                'инструменты_и_уровень_знаний_сотр': {
                    'column_name': 'инструменты',
                    'df': self.source_data.get('инструменты_и_уровень_знаний_сотр'),
                },
                'базы_данных_и_уровень_знаний_сотру': {
                    'column_name': 'Базы данных',
                    'df': self.source_data.get('базы_данных_и_уровень_знаний_сотру'),
                },
                'платформы_и_уровень_знаний_сотруд': {
                    'column_name': 'платформы',
                    'df': self.source_data.get('платформы_и_уровень_знаний_сотруд'),
                },
                'среды_разработки_и_уровень_знаний_': {
                    'column_name': 'Среды разработки',
                    'df': self.source_data.get('среды_разработки_и_уровень_знаний_'),
                },
                'типы_систем_и_уровень_знаний_сотру': {
                    'column_name': 'Типы систем',
                    'df': self.source_data.get('типы_систем_и_уровень_знаний_сотру'),
                },
                'фреймворки_и_уровень_знаний_сотру': {
                    'column_name': 'фреймворки',
                    'df': self.source_data.get('фреймворки_и_уровень_знаний_сотру'),
                },
                'языки_программирования_и_уровень': {
                    'column_name': 'Языки программирования',
                    'df': self.source_data.get('языки_программирования_и_уровень'),
                },
                'технологии_и_уровень_знаний_сотру': {
                    'column_name': 'технологии',
                    'df': self.source_data.get('технологии_и_уровень_знаний_сотру'),
                },
            }
        employees_df = pd.read_sql_table('сотрудники_дар', self.target_engine, self.target_schema)
        skills_df = pd.read_sql_table('навыки', self.target_engine, self.target_schema)
        temp_transformed_data = []
        group_id = 1

        for table_name, column_name_and_df in knowledge_levels_by_category.items():
            column_name: str = column_name_and_df['column_name']
            df: pd.DataFrame = column_name_and_df['df']

            # Трансформация данных столбцов 'user_id', 'дата', 'id_навыка', 'уровень_знаний'
            transformed_df = df.copy()
            transformed_df['user_id'] = transformed_df['User ID']
            transformed_df['дата'] = pd.to_datetime(transformed_df['дата']).combine_first(
                pd.to_datetime(transformed_df['Дата изм.']).dt.date)
            transformed_df['id_группы_навыков'] = group_id
            transformed_df['id_навыка'] = transformed_df[column_name].astype(int)
            transformed_df['уровень_знаний'] = transformed_df['Уровень знаний'].replace(283045, 115637)

            # Объединение с таблицами "сотрудники_дар" и "навыки"
            transformed_df = transformed_df.merge(employees_df, left_on='user_id', right_on='id_сотрудника')
            transformed_df = transformed_df.merge(skills_df, left_on='id_навыка', right_on='id_навыка')

            temp_transformed_data.append(transformed_df)
            group_id += 1

        # Объединение всех данных
        combined_df = pd.concat(temp_transformed_data, ignore_index=True)

        # Удаление дубликатор при одинаковых значениях:
        # 'user_id', 'id_навыка', 'дата' и 'уровень_знаний'
        combined_df.sort_values(['user_id', 'id_навыка', 'дата', 'уровень_знаний'],
                                ascending=[True, True, True, True], inplace=True)
        filtered_data = combined_df.drop_duplicates(
            subset=['user_id', 'id_навыка', 'дата', 'уровень_знаний'], keep='first'
        )

        # Определение строк с меньшим значением 'уровень_знаний' и  большим значением 'дата'
        filtered_data.sort_values(['user_id', 'id_навыка', 'дата'],
                                  ascending=[True, True, True], inplace=True)
        filtered_data['уровень_diff'] = filtered_data.groupby(
            ['user_id', 'id_навыка'])['уровень_знаний'].diff(-1)
        filtered_data = filtered_data[
            (filtered_data['уровень_diff'].isna()) | (filtered_data['уровень_diff'] <= 0)
            ]
        filtered_data.drop(columns=['уровень_diff'], inplace=True)

        # Определение строк с большим значением 'уровень_знаний'
        # при одинаковых 'user_id', 'id_навыка', 'дата'
        filtered_data.sort_values(['user_id', 'id_навыка', 'дата', 'уровень_знаний'],
                                  ascending=[True, True, True, False], inplace=True)
        filtered_data = filtered_data.drop_duplicates(subset=['user_id', 'дата', 'id_навыка'],
                                                      keep='first')

        # Определение строк с меньшим значением 'дата'
        # при одинаковых 'user_id', 'id_навыка', 'уровень_знаний'
        filtered_data.sort_values(['user_id', 'id_навыка', 'уровень_знаний', 'дата'],
                                  ascending=[True, True, False, True], inplace=True)
        filtered_data = filtered_data.drop_duplicates(subset=['user_id', 'id_навыка', 'уровень_знаний'],
                                                      keep='first')

        # Итоговая подготовка данных для вставки
        filtered_data['Дата_предыдущего_грейда'] = pd.NaT
        filtered_data['Дата_следующего_грейда'] = pd.NaT

        # Сортировка для заполнения двусвязного списка
        filtered_data.sort_values(['user_id', 'id_навыка', 'дата'], inplace=True)

        # Заполнение двусвязного списка
        for (user_id, skill_id), group in filtered_data.groupby(['user_id', 'id_навыка']):
            group = group.sort_values('дата')
            prev_idx = None
            for idx in group.index:
                if prev_idx is not None:
                    filtered_data.at[prev_idx, 'Дата_следующего_грейда'] = filtered_data.at[idx, 'дата']
                    filtered_data.at[idx, 'Дата_предыдущего_грейда'] = filtered_data.at[prev_idx, 'дата']
                prev_idx = idx

        # Подготовка итогового DataFrame
        final_data = filtered_data[
            ['id', 'user_id', 'дата', 'id_группы_навыков', 'id_навыка',
             'уровень_знаний', 'Дата_предыдущего_грейда', 'Дата_следующего_грейда']]
        final_data.sort_values(['id_группы_навыков', 'user_id', 'дата'], inplace=True)

        # Переименование столбцов
        final_data.rename(columns={
            'user_id': 'User ID',
            'дата': 'Дата',
            'id_группы_навыков': 'Группа_навыков',
            'id_навыка': 'Навыки',
            'уровень_знаний': 'Уровень_знаний'
        }, inplace=True)

        return final_data
