import inspect
import functools
import typing as t

import pandas as pd
from sqlalchemy.engine import Engine

from layers.abs_transform_ruler import TransformRules


class DDSTransformRules(TransformRules):
    """
    Класс, содержащий правила трансформации данных для различных таблиц слоя DDS.
    """

    # Словарь для хранения связей между таблицами и функциями трансформации
    comparison_tables_and_transformation_rules: t.Dict[str, t.Callable] = {}

    def __init__(self):
        # Вызов метода для инициализации словаря связей
        self.__invoke_all_transform_methods()

    def run_transform_rule_for_table(
            self,
            table: str,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """
        Запуск правила трансформации для указанной таблицы.

        :param table: Название таблицы.
        :type table: str
        :param data: Данные для трансформации.
        :type data: pd.DataFrame
        :param engine: SQLAlchemy движок для взаимодействия с базой данных.
        :type engine: Engine
        :return: Трансформированные данные.
        :rtype: pd.DataFrame
        """
        data_copy: pd.DataFrame = data.copy()
        if transform_fun := self.comparison_tables_and_transformation_rules.get(table):
            return transform_fun(self, data_copy, engine)
        else:
            return data_copy

    def __invoke_all_transform_methods(self) -> None:
        """
        Вызов методов трансформации, определенных в классе для инициализации словаря.

        Метод находит все методы, начинающиеся с 'transform_', и вызывает их.
        """
        for name, method in inspect.getmembers(self, predicate=inspect.ismethod):
            if name.startswith('transform_'):
                method(None, None)

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
    def transform_employee_dar(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'сотрудники_дар'"""
        if data is not None:
            data['подразделения'] = data['подразделения'].apply(
                lambda x: x.replace('.', '').strip()
            )
            data['Дата рождения'] = data['Дата рождения'].replace('', None)
            data['Последняя авторизация'] = data['Последняя авторизация'].replace('', None)
            data['Дата регистрации'] = data['Дата регистрации'].replace('', None)
            data['Дата изменения'] = data['Дата изменения'].replace('', None)

            return data

    @__register_transform(table='базы_данных')
    def transform_databases(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'базы_данных'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            # Заменяем год в столбце 'Дата изм.' на существующий
            data['Дата изм.'] = data['Дата изм.'].apply(
                lambda x: x.replace("2123", "2023")
            )

            return data

    @__register_transform(table='базы_данных_и_уровень_знаний_сотру')
    def transform_employee_databases_knowlege(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'базы_данных_и_уровень_знаний_сотру'"""
        if data is not None:
            # Заменяем название столбца 'название' на 'User ID'
            if 'название' in data.columns:
                data = data.rename(columns={'название': 'User ID'})

            #  В столбце 'User ID' оставляем в значении только ID пользователя
            data['User ID'] = data['User ID'].apply(lambda x: x.split(':')[1]).astype (int)

            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            #  В столбце 'Базы данных' оставляем в значении только ID Базы данных
            data['Базы данных'] = data['Базы данных'].apply(
                lambda x: x.split('[')[-1].split(']')[0]
            )

            # Заменяем год в столбце 'дата' на существующий
            data['дата'] = data['дата'].apply(lambda x: x.replace("2221", "2021"))
            data['дата'] = data['дата'].apply(lambda x: x.replace("2123", "2023"))
            data['дата'] = data['дата'].apply(lambda x: x.replace("2119", "2019"))

            data['дата'] = data['дата'].replace('', None)

            #  В столбце 'Уровень знаний' оставляем в значении только ID уровней знаний
            data['Уровень знаний'] = data['Уровень знаний'].apply(
                lambda x: x.split('[')[-1].split(']')[0]
            )

            # Удаление из data строки, где 'Уровень знаний' равен 'null'
            data = data[data['Уровень знаний'] != '']

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = pd.read_sql_query('SELECT * FROM ods_ira."сотрудники_дар"', engine)
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            return data

    @__register_transform(table='инструменты')
    def transform_tools(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'инструменты'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            return data

    @__register_transform(table='инструменты_и_уровень_знаний_сотр')
    def transform_tools_knowlege(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'инструменты_и_уровень_знаний_сотр'"""
        if data is not None:

            # Заменяем название столбца 'название' на 'User ID'
            if 'название' in data.columns:
                data = data.rename(columns={'название': 'User ID'})

            #  В столбце 'User ID' оставляем в значении только ID пользователя
            data['User ID'] = data['User ID'].apply(lambda x: x.split(':')[1]).astype (int)

            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            #  В столбце 'инструменты' оставляем в значении только ID инструменты
            data['инструменты'] = data['инструменты'].apply(
                lambda x: x.split('[')[-1].split(']')[0]
            )

            #  В столбце 'Уровень знаний' оставляем в значении только ID уровней знаний
            data['Уровень знаний'] = data['Уровень знаний'].apply(
                lambda x: x.split('[')[-1].split(']')[0]
            )

            # Удаление из data строк, где 'Уровень знаний' равен 'null'
            data = data[data['Уровень знаний'] != '']
            data['дата'] = data['дата'].replace('', None)

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = pd.read_sql_query('SELECT * FROM ods_ira."сотрудники_дар"', engine)
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            return data

    @__register_transform(table='образование_пользователей')
    def transform_user_education(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'образование_пользователей'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            #  В столбце 'Уровень образование' оставляем в значении только
            #  ID уровней образования
            data['Уровень образование'] = data['Уровень образование'].apply(
                lambda x: x.split('[')[-1].split(']')[0]
            )
            data['квалификация'] = data['квалификация'].apply(
                lambda x: x.replace("Специались", "Специалист")
            )
            data['специальность'] = data['специальность'].apply(
                lambda x: x.replace("масгистр", "магистр")
            )

            # Переносим из столбца "специальность" значения в столбец "квалификация"
            qualification_values = [
                'бакалавр', 'магистр', 'Специалист', 'Бакалавр', 'Магистр', 'специалист'
            ]
            for qual_value in qualification_values:
                mask = data['специальность'] == qual_value
                data.loc[mask, 'квалификация'] = qual_value
                data.loc[mask, 'специальность'] = ''

            # Если значение в столбце "квалификация не 'бакалавр', 'магистр', 'Специалист',
            # то заменить на NULL
            not_qualification_values = ['бакалавр', 'магистр', 'Специалист']
            mask = ~data['квалификация'].isin(not_qualification_values)
            data.loc[mask, 'квалификация'] = ''

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = pd.read_sql_query('SELECT * FROM ods_ira."сотрудники_дар"', engine)
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            return data

    @__register_transform(table='опыт_сотрудника_в_отраслях')
    def transform_employee_experience_industries(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'опыт_сотрудника_в_отраслях'"""
        if data is not None:

            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            #  В столбце 'отрасли' оставляем в значении только ID отрасли
            data['отрасли'] = data['отрасли'].apply(
                lambda x: x.split('[')[-1].split(']')[0])

            #  В столбце 'Уровень знаний в отрасли' оставляем в значении только
            #  ID Уровень знаний в отрасли
            data['Уровень знаний в отрасли'] = data['Уровень знаний в отрасли'].apply(
                lambda x: x.split('[')[-1].split(']')[0])

            # Удаление из data строк, где 'Уровень знаний в отрасли' равен 'null'
            data = data[data['Уровень знаний в отрасли'] != '']

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = pd.read_sql_query('SELECT * FROM ods_ira."сотрудники_дар"', engine)
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            data['дата'] = data['дата'].replace('', None)

            return data

    @__register_transform(table='опыт_сотрудника_в_предметных_обла')
    def transform_employee_experience_subject_area(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'опыт_сотрудника_в_предметных_обла'"""
        if data is not None:

            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            #  В столбце 'Предметные области' оставляем в значении только ID Предметные области
            data['Предментые области'] = data['Предментые области'].apply(
                lambda x: x.split('[')[-1].split(']')[0])

            #  В столбце 'Уровень знаний в предметной облас' оставляем в значении только
            #  ID Уровень знаний в предметной области
            data['Уровень знаний в предметной облас'] = data[
                'Уровень знаний в предметной облас'
            ].apply(
                lambda x: x.split('[')[-1].split(']')[0]
            )

            # Удаление из data строк, где 'Уровень знаний в предметной области' равен 'null'
            data = data[data['Уровень знаний в предметной облас'] != '']

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = pd.read_sql_query('SELECT * FROM ods_ira."сотрудники_дар"', engine)
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            data['дата'] = data['дата'].replace('', None)

            return data

    @__register_transform(table='отрасли')
    def transform_industry(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'отрасли'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            return data

    @__register_transform(table='платформы')
    def transform_platforms(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'платформы'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            return data

    @__register_transform(table='платформы_и_уровень_знаний_сотруд')
    def transform_platforms_knowledge(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'платформы_и_уровень_знаний_сотруд'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            #  В столбце 'платформы' оставляем в значении только ID пратформы
            data['платформы'] = data['платформы'].apply(
                lambda x: x.split('[')[-1].split(']')[0])

            #  В столбце 'Уровень знаний' оставляем в значении только ID Уровень знаний
            data['Уровень знаний'] = data['Уровень знаний'].apply(
                lambda x: x.split('[')[-1].split(']')[0])

            # Удаление из data строк, где 'Уровень знаний' равен 'null'
            data = data[data['Уровень знаний'] != '']

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = pd.read_sql_query('SELECT * FROM ods_ira."сотрудники_дар"', engine)
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            data['дата'] = data['дата'].replace('', None)

            return data

    @__register_transform(table='предметная_область')
    def transform_subject_area(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'предметная_область'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            return data

    @__register_transform(table='сертификаты_пользователей')
    def transform_user_certificates(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'сертификаты_пользователей'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = pd.read_sql_query('SELECT * FROM ods_ira."сотрудники_дар"', engine)
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            return data

    @__register_transform(table='среды_разработки')
    def transform_development_environments(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'среды_разработки'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            return data

    @__register_transform(table='среды_разработки_и_уровень_знаний_')
    def transform_development_environments_knowledge(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'среды_разработки_и_уровень_знаний_'"""
        if data is not None:
            # Заменяем название столбца 'название' на 'User ID'
            if 'название' in data.columns:
                data = data.rename(columns={'название': 'User ID'})

            #  В столбце 'User ID' оставляем в значении только ID пользователя
            data['User ID'] = data['User ID'].apply(lambda x: x.split(':')[1]).astype (int)

            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            #  В столбце 'среды разработки' оставляем в значении только ID среды разработки
            data['Среды разработки'] = data['Среды разработки'].apply(
                lambda x: x.split('[')[-1].split(']')[0])

            #  В столбце 'Уровень знаний' оставляем в значении только ID Уровень знаний
            data['Уровень знаний'] = data['Уровень знаний'].apply(
                lambda x: x.split('[')[-1].split(']')[0])

            # Удаление из data строк, где 'Уровень знаний' равен 'null'
            data = data[data['Уровень знаний'] != '']

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = pd.read_sql_query('SELECT * FROM ods_ira."сотрудники_дар"', engine)
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            data['дата'] = data['дата'].replace('', None)

            return data

    @__register_transform(table='технологии')
    def transform_technologies(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'технологии'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            return data

    @__register_transform(table='технологии_и_уровень_знаний_сотру')
    def transform_technologies_knowledge(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'технологии_и_уровень_знаний_сотру'"""
        if data is not None:
            # Заменяем название столбца 'название' на 'User ID'
            if 'название' in data.columns:
                data = data.rename(columns={'название': 'User ID'})

            #  В столбце 'User ID' оставляем в значении только ID пользователя
            data['User ID'] = data['User ID'].apply(lambda x: x.split(':')[1]).astype (int)

            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            #  В столбце 'среды разработки' оставляем в значении только ID среды разработки
            data['технологии'] = data['технологии'].apply(
                lambda x: x.split('[')[-1].split(']')[0])

            #  В столбце 'Уровень знаний' оставляем в значении только ID Уровень знаний
            data['Уровень знаний'] = data['Уровень знаний'].apply(
                lambda x: x.split('[')[-1].split(']')[0])

            # Удаление из data строк, где 'Уровень знаний' равен 'null'
            data = data[data['Уровень знаний'] != '']

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = pd.read_sql_query('SELECT * FROM ods_ira."сотрудники_дар"', engine)
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            data['дата'] = data['дата'].replace('', None)

            return data

    @__register_transform(table='типы_систем')
    def transform_systems(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'типы_систем'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            return data

    @__register_transform(table='типы_систем_и_уровень_знаний_сотру')
    def transform_systems_knowledge(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'типы_систем_и_уровень_знаний_сотру'"""
        if data is not None:
            # Заменяем название столбца 'название' на 'User ID'
            if 'название' in data.columns:
                data = data.rename(columns={'название': 'User ID'})

            #  В столбце 'User ID' оставляем в значении только ID пользователя
            data['User ID'] = data['User ID'].apply(lambda x: x.split(':')[1]).astype (int)

            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            #  В столбце 'Типы систем' оставляем в значении только ID Типы систем
            data['Типы систем'] = data['Типы систем'].apply(
                lambda x: x.split('[')[-1].split(']')[0])

            #  В столбце 'Уровень знаний' оставляем в значении только ID Уровень знаний
            data['Уровень знаний'] = data['Уровень знаний'].apply(
                lambda x: x.split('[')[-1].split(']')[0])

            # Удаление из data строк, где 'Уровень знаний' равен 'null'
            data = data[data['Уровень знаний'] != '']

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = pd.read_sql_query('SELECT * FROM ods_ira."сотрудники_дар"', engine)
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            data['дата'] = data['дата'].replace('', None)

            return data

    @__register_transform(table='уровень_образования')
    def transform_education_level(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'уровень_образования'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            return data

    @__register_transform(table='уровни_владения_ин')
    def transform_foreign_language_levels(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'уровни_владения_ин'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            return data

    @__register_transform(table='уровни_знаний')
    def transform_knowledge_levels(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'уровни_знаний'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            return data

    @__register_transform(table='уровни_знаний_в_отрасли')
    def transform_knowledge_levels_industry(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'уровни_знаний_в_отрасли'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            return data

    @__register_transform(table='уровни_знаний_в_предметной_област')
    def transform_levels_knowledge_subject_area(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'уровни_знаний_в_предметной_област'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            return data

    @__register_transform(table='фреймворки')
    def transform_frameworks(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'фреймворки'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            return data

    @__register_transform(table='фреймворки_и_уровень_знаний_сотру')
    def transform_frameworks_level(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'фреймворки_и_уровень_знаний_сотру'"""
        if data is not None:
            # Заменяем название столбца 'название' на 'User ID'
            if 'название' in data.columns:
                data = data.rename(columns={'название': 'User ID'})

            #  В столбце 'User ID' оставляем в значении только ID пользователя
            data['User ID'] = data['User ID'].apply(lambda x: x.split(':')[1]).astype (int)

            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            #  В столбце 'Уровень знаний' оставляем в значении только ID Уровень знаний
            data['Уровень знаний'] = data['Уровень знаний'].apply(
                lambda x: x.split('[')[-1].split(']')[0])

            #  В столбце 'Типы систем' оставляем в значении только ID Типы систем
            data['фреймворки'] = data['фреймворки'].apply(
                lambda x: x.split('[')[-1].split(']')[0])

            # Удаление из data строк, где 'Уровень знаний' равен 'null'
            data = data[data['Уровень знаний'] != '']

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = pd.read_sql_query('SELECT * FROM ods_ira."сотрудники_дар"', engine)
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            data['дата'] = data['дата'].replace('', None)

            return data

    @__register_transform(table='языки')
    def transform_languages(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'языки'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            return data

    @__register_transform(table='языки_пользователей')
    def transform_languages_users(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'языки_пользователей'"""
        if data is not None:
            # Заменяем название столбца 'название' на 'User ID'
            if 'название' in data.columns:
                data = data.rename(columns={'название': 'User ID'})
            data = data[data['User ID'] != 'Адаптация Ольга Белякова']

            # В столбце 'User ID' оставляем в значении только ID пользователя
            data['User ID'] = data['User ID'].apply(lambda x: x.split(':')[1]).astype (int)

            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            #  В столбце 'Типы систем' оставляем в значении только ID Типы систем
            data['язык'] = data['язык'].apply(
                lambda x: x.split('[')[-1].split(']')[0])

            #  В столбце 'Уровень знаний ин. языка' оставляем в значении только ID
            #  Уровень знаний ин. языка
            data['Уровень знаний ин. языка'] = data['Уровень знаний ин. языка'].apply(
                lambda x: x.split('[')[-1].split(']')[0]
            )

            # Удаление из data строк, где 'Уровень знаний ин. языка' равен 'null'
            data = data[data['Уровень знаний ин. языка'] != '']

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = pd.read_sql_query('SELECT * FROM ods_ira."сотрудники_дар"', engine)
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            return data

    @__register_transform(table='языки_программирования')
    def transform_programming_languages(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'языки_программирования'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            return data

    @__register_transform(table='языки_программирования_и_уровень')
    def transform_programming_languages_levels(
            self,
            data: pd.DataFrame,
            engine: Engine
    ) -> pd.DataFrame:
        """Трансформация данных для 'языки_программирования_и_уровень'"""
        if data is not None:
            # Удаление из data столбца 'Сорт.'
            if 'название' in data.columns:
                data = data.rename(columns={'название': 'User ID'})

            # В столбце 'User ID' оставляем в значении только ID пользователя
            data['User ID'] = data['User ID'].apply(lambda x: x.split(':')[1]).astype (int)

            # Удаление из data столбца 'Сорт.'
            if 'Сорт.' in data.columns:
                data = data.drop(columns=['Сорт.'])

            #  В столбце 'Уровень знаний' оставляем в значении только ID Уровень знаний
            data['Уровень знаний'] = data['Уровень знаний'].apply(
                lambda x: x.split('[')[-1].split(']')[0])

            #  В столбце 'Языки программирования' оставляем в значении
            #  только ID Языки программирования
            data['Языки программирования'] = data['Языки программирования'].apply(
                lambda x: x.split('[')[-1].split(']')[0])

            # Удаление из data строк, где 'Уровень знаний ин. языка' равен 'null'
            data = data[data['Уровень знаний'] != '']

            # Удаление строк из data, если id не входит в id сотрудники_дар
            table_data = pd.read_sql_query('SELECT * FROM ods_ira."сотрудники_дар"', engine)
            valid_ids = set(table_data['id'])
            data = data[data['User ID'].isin(valid_ids)]

            data['дата'] = data['дата'].replace('', None)

            return data
