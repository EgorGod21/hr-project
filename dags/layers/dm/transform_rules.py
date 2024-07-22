import logging
import random
import re
import typing as t

from faker import Faker
import pandas as pd


# Инициализация экземпляра Faker для генерации фамилий и имен
fake = Faker('ru_RU')


def etl_knowledge_levels(
        dds_ira_knowledge_levels: pd.DataFrame
) -> pd.DataFrame:
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

def etl_dar_employees(
        dds_ira_employees: pd.DataFrame
) -> pd.DataFrame:
    """
    Функция для преобразования данных из dds_ira.employees в dm_ira.employees
    с фильтрацией и изменением должностей.

    :param dds_ira_employees: DataFrame с данными из таблицы dds_ira.employees
    :return: DataFrame с преобразованными и отфильтрованными данными
    """
    # Словарь сопоставления должностей и соответствующих шаблонов регулярных выражений
    role_mapping = {
        'Системный аналитик': r'системный аналитик',
        'Бизнес-аналитик': r'бизнес-аналитик(?!и)',
        'Инженер данных': r'инженер данных',
        'Руководитель проектов': r'руководитель проектов',
        'Тестировщик': r'тестировщик|инженер по тестированию',
        'Архитектор': r'архитектор',
        'Разработчик': r'разработчик'
    }

    # Преобразование должностей в соответствии с заданными шаблонами
    for role, pattern in role_mapping.items():
        dds_ira_employees['должность'] = dds_ira_employees['должность'].apply(
            lambda x: role if re.search(pattern, x, re.IGNORECASE) else x
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
    names_list = generate_unique_full_names(max(len(na_first), len(na_last)))

    # Замена отсутствующих фамилий и имен на сгенерированные значения
    for idx, full_name in zip(na_first, names_list):
        first_name, last_name = full_name.split()
        result_df.at[idx, 'Фамилия'] = last_name

    for idx, full_name in zip(na_last, names_list):
        first_name, last_name = full_name.split()
        result_df.at[idx, 'Имя'] = first_name

    return result_df


def etl_skill_groups(
) -> pd.DataFrame:
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


def etl_skills(
        *data_frames: t.Tuple[pd.DataFrame]
) -> pd.DataFrame:
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

    # Переименование и выбор нужных столбцов
    result_df = consolidated_skills_df.rename(columns={
        'id': 'id_навыка',
        'название': 'Название'
    })[['id_навыка', 'Название']]

    # Логирование завершения выполнения функции
    logging.info(
        "Loading skills completed, %d skills loaded", len(consolidated_skills_df)
    )

    return result_df


def etl_skills_knowledge(
        knowledge_levels_by_category: dict,
        employees_df: pd.DataFrame,
        skills_df: pd.DataFrame
) -> pd.DataFrame:
    """
    Загрузка, трансформация данных и фильтрация для получения наивысшего уровня знаний.

    :param knowledge_levels_by_category: Словарь с данными по уровням знаний для различных категорий.
                                         Формат: {'имя_таблицы': {'column_name': 'имя_столбца', 'df': dataframe}}
    :param employees_df: DataFrame с данными сотрудников.
    :param skills_df: DataFrame с данными навыков.
    :return: DataFrame с объединенными и отфильтрованными данными.
    """
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

    # Определение строк с наименьшим значением уровня знаний
    combined_df.sort_values(['user_id', 'id_навыка', 'дата', 'уровень_знаний'],
                            ascending=[True, True, True, True], inplace=True)
    filtered_data = combined_df.drop_duplicates(subset=['user_id', 'дата', 'id_навыка'], keep='first')

    # Удаление строк с меньшей датой и большим уровнем знаний
    filtered_data.sort_values(['user_id', 'id_навыка', 'дата'],
                              ascending=[True, True, True], inplace=True)
    filtered_data['уровень_diff'] = filtered_data.groupby(
        ['user_id', 'id_навыка'])['уровень_знаний'].diff(-1)
    filtered_data = filtered_data[
        (filtered_data['уровень_diff'].isna()) | (filtered_data['уровень_diff'] <= 0)
    ]
    filtered_data.drop(columns=['уровень_diff'], inplace=True)

    # Удаление дублей с одинаковыми user_id, id_навыка и уровень_знаний
    filtered_data.sort_values(['user_id', 'id_навыка', 'уровень_знаний', 'дата'],
                              ascending=[True, True, False, True], inplace=True)
    filtered_data = filtered_data.drop_duplicates(subset=['user_id', 'id_навыка', 'уровень_знаний'],
                                                  keep='first')

    # Итоговая подготовка данных для вставки
    filtered_data['Дата прошлого грейда'] = pd.NaT
    filtered_data['Дата следующего грейда'] = pd.NaT

    # Сортировка для заполнения двусвязного списка
    filtered_data.sort_values(['user_id', 'id_навыка', 'дата'], inplace=True)

    # Заполнение двусвязного списка
    for (user_id, skill_id), group in filtered_data.groupby(['user_id', 'id_навыка']):
        group = group.sort_values('дата')
        prev_idx = None
        for idx in group.index:
            if prev_idx is not None:
                filtered_data.at[prev_idx, 'Дата следующего грейда'] = filtered_data.at[idx, 'дата']
                filtered_data.at[idx, 'Дата прошлого грейда'] = filtered_data.at[prev_idx, 'дата']
            prev_idx = idx

    # Подготовка итогового DataFrame
    final_data = filtered_data[
        ['id', 'user_id', 'дата', 'id_группы_навыков', 'id_навыка',
         'уровень_знаний', 'Дата прошлого грейда', 'Дата следующего грейда']]
    final_data.sort_values(['id_группы_навыков', 'user_id', 'дата'], inplace=True)

    # Переименование столбцов
    final_data.rename(columns={
        'user_id': 'User ID',
        'дата': 'Дата',
        'id_группы_навыков': 'Группы навыков',
        'id_навыка': 'Навыки',
        'уровень_знаний': 'Уровень знаний'
    }, inplace=True)

    return final_data
