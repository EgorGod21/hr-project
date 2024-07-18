import logging
import re
import typing as t

import pandas as pd


def etl_knowledge_levels(dds_ira_knowledge_levels: pd.DataFrame) -> pd.DataFrame:
    """
    Функция для переноса данных из dds_ira.knowledge_levels в dm_ira.knowledge_levels,
    исключая записи с названием 'Использовал на проекте'.

    :param dds_ira_knowledge_levels: DataFrame с данными из таблицы dds_ira.knowledge_levels
    :return: DataFrame с отфильтрованными данными
    """
    # Логирование начала выполнения функции
    logging.info("Starting ETL process for knowledge levels")

    # Фильтрация данных, исключая записи с названием 'Использовал на проекте' и ренейм
    result_df = dds_ira_knowledge_levels[
            dds_ira_knowledge_levels['название'] != 'Использовал на проекте'
    ][['id', 'название']].rename(columns={'id': 'id_уровня', 'название': 'Название'})

    # Логирование завершения выполнения функции
    logging.info(
        "ETL process for knowledge levels completed, %d rows processed", len(result_df)
    )
    return result_df


def etl_dar_employees(dds_ira_employees: pd.DataFrame) -> pd.DataFrame:
    """
    Функция для преобразования данных из dds_ira.employees в dm_ira.employees
    с фильтрацией и изменением должностей.

    :param dds_ira_employees: DataFrame с данными из таблицы dds_ira.employees
    :return: DataFrame с преобразованными и отфильтрованными данными
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
    for role, pattern in role_mapping.items():
        dds_ira_employees['должность'] = dds_ira_employees['должность'].apply(
            lambda x: role if re.search(pattern, x, re.IGNORECASE) else x
        )

    # Фильтруем данные по условиям
    filtered_df = dds_ira_employees[
        (dds_ira_employees['цфо'] == 'DAR') &
        (dds_ira_employees['активность'] == 'Да') &
        (dds_ira_employees['должность'].isin(role_mapping.keys()))
        ]

    # Переименовываем и выбираем нужные столбцы
    result_df = filtered_df.rename(columns={
        'id': 'id_сотрудника',
        'фамилия': 'Фамилия',
        'имя': 'Имя',
        'должность': 'Роль'
    })[['id_сотрудника', 'Фамилия', 'Имя', 'Роль']]

    result_df['Фамилия'] = result_df['Фамилия'].replace('', None)
    result_df['Имя'] = result_df['Имя'].replace('', None)
    return result_df


def etl_skill_groups() -> pd.DataFrame:
    """
    Функция для загрузки предопределенных групп навыков в DataFrame.

    :return: DataFrame с предопределенными группами навыков
    """
    # Логирование начала выполнения функции
    logging.info("Starting loading skill groups")

    # Предопределенные группы навыков
    skill_groups = [
        'Базы данных', 'Инструменты', 'Платформы', 'Среды разработки',
        'Технологии', 'Типы систем', 'Фреймворки', 'Языки программирования'
    ]

    # Создание DataFrame из списка
    result_df = pd.DataFrame({
            'id_группы': list(range(1, len(skill_groups) + 1)),
            'Группа навыков': skill_groups,
    })

    # Логирование завершения выполнения функции
    logging.info("Loading skill groups completed, %d groups loaded", len(result_df))
    return result_df


def etl_skills(*data_frames: t.Tuple[pd.DataFrame]) -> pd.DataFrame:
    """
    Функция для объединения данных навыков из различных таблиц и фильтрации ненужных записей.

    :param data_frames: Несколько DataFrame с данными из различных таблиц
    :return: DataFrame с объединенными и отфильтрованными данными навыков
    """
    # Логирование начала выполнения функции
    logging.info("Starting loading skills")

    # Фильтрация и объединение данных
    filtered_dfs = [
        df[df['название'] != 'Другое'][['id', 'название']] for df in data_frames
    ]

    # Объединение всех отфильтрованных DataFrame в один
    consolidated_skills_df = pd.concat(filtered_dfs, ignore_index=True)

    result_df = consolidated_skills_df.rename(columns={
        'id': 'id_навыка',
        'название': 'Название'
    })[['id_навыка', 'Название']]

    # Логирование завершения выполнения функции
    logging.info(
        "Loading skills completed, %d skills loaded", len(consolidated_skills_df)
    )
    return result_df


def etl_skills_knowledge(knowledge_levels_by_category, employees_df, skills_df):
    """
    Загрузка и трансформация данных из нескольких источников, объединение с данными
    сотрудников и навыков, и фильтрация для получения наивысшего уровня знаний.

    :param knowledge_levels_by_category: Словарь с данными по уровням знаний для различных категорий.
                                         Ключи - имена категорий, значения - словари с ключами 'column_name' и 'df'.
    :type knowledge_levels_by_category: dict
    :param employees_df: DataFrame с данными сотрудников
    :type employees_df: pd.DataFrame
    :param skills_df: DataFrame с данными навыков
    :type skills_df: pd.DataFrame
    :return: DataFrame с объединенными и отфильтрованными данными
    :rtype: pd.DataFrame
    """
    data_frames: t.List[pd.DataFrame] = []
    group_id: int = 1

    for table_name, column_name_and_df in knowledge_levels_by_category.items():
        column_name: str = column_name_and_df['column_name']
        df: pd.DataFrame = column_name_and_df['df']

        # Преобразуем данные
        df['Группы навыков'] = group_id
        df['Навыки'] = df[column_name].astype(int)
        df['дата'] = df['дата'].combine_first(df['Дата изм.'].dt.date)
        df['Уровень знаний'] = df['Уровень знаний'].replace(283045, 115637)

        # Объединяем с сотрудниками и навыками
        merged_df = df.merge(employees_df, left_on='User ID', right_on='id_сотрудника')
        merged_df = merged_df.merge(skills_df, left_on=column_name, right_on='id_навыка')

        # Добавляем в список промежуточных DataFrame
        data_frames.append(
            merged_df[
                ['User ID', 'Группы навыков', 'дата', 'Дата изм.', 'Навыки', 'Уровень знаний']
            ]
        )

        # Увеличиваем идентификатор группы навыков для следующей итерации
        group_id += 1

    # Объединяем все данные в один DataFrame
    combined_df = pd.concat(data_frames)

    # Сортируем и оставляем строки с наивысшим уровнем знаний
    if combined_df.index.duplicated().any():
        combined_df = combined_df.reset_index(drop=True)

    combined_df['rn'] = combined_df.sort_values(
        ['User ID', 'Группы навыков', 'дата', 'Дата изм.', 'Навыки', 'Уровень знаний'],
        ascending=[True, True, True, True, True, False]
    ).groupby(
        ['User ID', 'Группы навыков', 'дата', 'Дата изм.', 'Навыки']
    ).cumcount() + 1

    final_df = combined_df[combined_df['rn'] == 1].drop(columns=['rn'])

    return final_df
