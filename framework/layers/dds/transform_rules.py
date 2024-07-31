import pandas as pd

from layers.transform_rules_manager import TransformRulesManager


class DDSTransformRules(t_manager := TransformRulesManager):
    """
    Определяет правила трансформации данных для слоя DDS.
    """

    @t_manager.register_transformation_rule(tables=['сотрудники_дар'])
    def _transform_employee_dar(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Трансформация данных для 'сотрудники_дар'.
        """
        # Удаление точек и пробелов в столбце 'подразделения'
        data['подразделения'] = data['подразделения'].str.replace('.', '').str.strip()

        # Замена пустых строк на None в указанных столбцах
        columns_to_replace = [
            'Дата рождения', 'Последняя авторизация', 'Дата регистрации', 'Дата изменения'
        ]
        data[columns_to_replace] = data[columns_to_replace].replace('', None)
        return data

    @staticmethod
    def _drop_columns(data: pd.DataFrame, columns: list) -> pd.DataFrame:
        """
        Удаление указанных столбцов из DataFrame.
        """
        data.drop(columns=columns, inplace=True, errors='ignore')
        return data

    @staticmethod
    def _replace_empty_with_none(
            data: pd.DataFrame, columns: list
    ) -> pd.DataFrame:
        """
        Замена пустых строк на None для указанных столбцов.
        """
        data[columns] = data[columns].replace('', None)
        return data

    @staticmethod
    def _extract_ids(data: pd.DataFrame, columns: list) -> pd.DataFrame:
        """
        Извлечение ID из указанных столбцов.
        """
        for column in columns:
            data[column] = data[column].str.extract(r'\[(\d+)\]')[0]
        return data

    @staticmethod
    def _rename_column(
            data: pd.DataFrame, old_name: str, new_name: str
    ) -> pd.DataFrame:
        """
        Переименование столбца.
        """
        data.rename(columns={old_name: new_name}, inplace=True, errors='ignore')
        return data

    @staticmethod
    def _filter_by_user_id(data: pd.DataFrame, valid_ids: set) -> pd.DataFrame:
        """
        Фильтрация строк по списку допустимых ID пользователей.
        """
        return data[data['User ID'].isin(valid_ids)]

    @t_manager.register_transformation_rule(tables=['базы_данных'])
    def _transform_databases(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Трансформация данных для 'базы_данных'.
        """
        # Удаление столбца 'Сорт.'
        data = self._drop_columns(data, ['Сорт.'])

        # Замена года "2123" на "2023" в столбце 'Дата изм.'
        data['Дата изм.'] = data['Дата изм.'].str.replace('2123', '2023')
        return data

    @t_manager.register_transformation_rule(tables=['базы_данных_и_уровень_знаний_сотру'])
    def _transform_employee_databases_knowlege(
            self, data: pd.DataFrame
    ) -> pd.DataFrame:
        """
        Трансформация данных для 'базы_данных_и_уровень_знаний_сотру'.
        """
        # Переименование столбца 'название' в 'User ID'
        data = self._rename_column(data, 'название', 'User ID')

        # Оставляем в столбце 'User ID' только ID пользователя
        data['User ID'] = data['User ID'].str.split(':').str[1].astype(int)

        # Удаление столбца 'Сорт.'
        data = self._drop_columns(data, ['Сорт.'])

        # Извлечение ID из столбцов 'Базы данных' и 'Уровень знаний'
        data = self._extract_ids(data, ['Базы данных', 'Уровень знаний'])

        # Замена некорректных годов в столбце 'дата'
        data['дата'] = data['дата'].replace(
            {'2221': '2021', '2123': '2023', '2119': '2019', '': None}
        )

        # Удаление строк, где 'Уровень знаний' равен NaN
        data = data[data['Уровень знаний'].notna()]

        # Получение списка действительных ID из 'сотрудники_дар'
        valid_ids = set(self.source_data['сотрудники_дар']['id'])

        # Фильтрация строк по списку допустимых ID
        return self._filter_by_user_id(data, valid_ids)

    @t_manager.register_transformation_rule(tables=['инструменты_и_уровень_знаний_сотр'])
    def _transform_tools_knowlege(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Трансформация данных для 'инструменты_и_уровень_знаний_сотр'.
        """
        # Переименование столбца 'название' в 'User ID'
        data = self._rename_column(data, 'название', 'User ID')

        # Оставляем в столбце 'User ID' только ID пользователя
        data['User ID'] = data['User ID'].str.split(':').str[1].astype(int)

        # Удаление столбца 'Сорт.'
        data = self._drop_columns(data, ['Сорт.'])

        # Извлечение ID из столбцов 'инструменты' и 'Уровень знаний'
        data = self._extract_ids(data, ['инструменты', 'Уровень знаний'])

        # Замена пустых строк на None в столбце 'дата'
        data['дата'] = data['дата'].replace('', None)

        # Удаление строк, где 'Уровень знаний' равен NaN
        data = data[data['Уровень знаний'].notna()]

        # Получение списка действительных ID из 'сотрудники_дар'
        valid_ids = set(self.source_data['сотрудники_дар']['id'])

        # Фильтрация строк по списку допустимых ID
        return self._filter_by_user_id(data, valid_ids)

    @t_manager.register_transformation_rule(tables=['образование_пользователей'])
    def _transform_user_education(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Трансформация данных для 'образование_пользователей'.
        """
        # Удаление столбца 'Сорт.'
        data = self._drop_columns(data, ['Сорт.'])

        # Извлечение ID из столбца 'Уровень образование'
        data['Уровень образование'] =\
            data['Уровень образование'].str.extract(r'\[(\d+)\]')[0]

        # Исправление опечаток в столбцах 'квалификация' и 'специальность'
        data['квалификация'] = data['квалификация'].replace("Специались", "Специалист")
        data['специальность'] = data['специальность'].replace("масгистр", "магистр")

        # Переносим значения из столбца 'специальность' в 'квалификация'
        qualification_values = [
            'бакалавр', 'магистр', 'Специалист', 'Бакалавр', 'Магистр', 'специалист'
        ]
        for qual_value in qualification_values:
            mask = data['специальность'] == qual_value
            data.loc[mask, ['квалификация', 'специальность']] = [qual_value, '']

        # Замена некорректных значений в столбце 'квалификация' на пустую строку
        valid_qualifications = {'бакалавр', 'магистр', 'Специалист'}
        data['квалификация'] =\
            data['квалификация'].where(data['квалификация'].isin(valid_qualifications), '')

        # Получение списка действительных ID из 'сотрудники_дар'
        valid_ids = set(self.source_data['сотрудники_дар']['id'])

        # Фильтрация строк по списку допустимых ID
        return self._filter_by_user_id(data, valid_ids)

    @t_manager.register_transformation_rule(tables=['опыт_сотрудника_в_отраслях'])
    def _transform_employee_experience_industries(
            self, data: pd.DataFrame
    ) -> pd.DataFrame:
        """
        Трансформация данных для 'опыт_сотрудника_в_отраслях'.
        """
        # Удаление столбца 'Сорт.'
        data = self._drop_columns(data, ['Сорт.'])

        # Извлечение ID из столбцов 'отрасли' и 'Уровень знаний в отрасли'
        data = self._extract_ids(data, ['отрасли', 'Уровень знаний в отрасли'])

        # Замена пустых строк на None в столбце 'дата'
        data['дата'] = data['дата'].replace('', None)

        # Удаление строк, где 'Уровень знаний в отрасли' равен NaN
        data = data[data['Уровень знаний в отрасли'].notna()]

        # Получение списка действительных ID из 'сотрудники_дар'
        valid_ids = set(self.source_data['сотрудники_дар']['id'])

        # Фильтрация строк по списку допустимых ID
        return self._filter_by_user_id(data, valid_ids)

    @t_manager.register_transformation_rule(tables=['опыт_сотрудника_в_предметных_обла'])
    def _transform_employee_experience_subject_area(
            self, data: pd.DataFrame
    ) -> pd.DataFrame:
        """
        Трансформация данных для 'опыт_сотрудника_в_предметных_обла'.
        """
        # Удаление столбца 'Сорт.'
        data = self._drop_columns(data, ['Сорт.'])

        # Извлечение ID из столбцов 'Предметные области' и 'Уровень знаний в предметной облас'
        data = self._extract_ids(
            data, ['Предметные области', 'Уровень знаний в предметной облас']
        )

        # Замена пустых строк на None в столбце 'дата'
        data['дата'] = data['дата'].replace('', None)

        # Удаление строк, где 'Уровень знаний в предметной облас' равен NaN
        data = data[data['Уровень знаний в предметной облас'].notna()]

        # Получение списка действительных ID из 'сотрудники_дар'
        valid_ids = set(self.source_data['сотрудники_дар']['id'])

        # Фильтрация строк по списку допустимых ID
        return self._filter_by_user_id(data, valid_ids)

    @t_manager.register_transformation_rule(tables=['платформы_и_уровень_знаний_сотруд'])
    def _transform_platforms_knowledge(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Трансформация данных для 'платформы_и_уровень_знаний_сотруд'.
        """
        # Удаление столбца 'Сорт.'
        data = self._drop_columns(data, ['Сорт.'])

        # Извлечение ID из столбцов 'платформы' и 'Уровень знаний'
        data = self._extract_ids(data, ['платформы', 'Уровень знаний'])

        # Замена пустых строк на None в столбце 'дата'
        data['дата'] = data['дата'].replace('', None)

        # Удаление строк, где 'Уровень знаний' равен NaN
        data = data[data['Уровень знаний'].notna()]

        # Получение списка действительных ID из 'сотрудники_дар'
        valid_ids = set(self.source_data['сотрудники_дар']['id'])

        # Фильтрация строк по списку допустимых ID
        return self._filter_by_user_id(data, valid_ids)

    @t_manager.register_transformation_rule(tables=['технологии_и_уровень_знаний_сотру'])
    def _transform_technologies_knowledge(
            self, data: pd.DataFrame
    ) -> pd.DataFrame:
        """
        Трансформация данных для 'технологии_и_уровень_знаний_сотру'.
        """
        # Переименование столбца 'название' в 'User ID'
        data = self._rename_column(data, 'название', 'User ID')

        # Оставляем в столбце 'User ID' только ID пользователя
        data['User ID'] = data['User ID'].str.split(':').str[1].astype(int)

        # Удаление столбца 'Сорт.'
        data = self._drop_columns(data, ['Сорт.'])

        # Извлечение ID из столбцов 'технологии' и 'Уровень знаний'
        data = self._extract_ids(data, ['технологии', 'Уровень знаний'])

        # Замена пустых строк на None в столбце 'дата'
        data['дата'] = data['дата'].replace('', None)

        # Удаление строк, где 'Уровень знаний' равен NaN
        data = data[data['Уровень знаний'].notna()]

        # Получение списка действительных ID из 'сотрудники_дар'
        valid_ids = set(self.source_data['сотрудники_дар']['id'])

        # Фильтрация строк по списку допустимых ID
        return self._filter_by_user_id(data, valid_ids)

    @t_manager.register_transformation_rule(tables=['среды_разработки_и_уровень_знаний_'])
    def _transform_development_environments_knowledge(
            self, data: pd.DataFrame
    ) -> pd.DataFrame:
        """
        Трансформация данных для 'среды_разработки_и_уровень_знаний_'.
        """
        # Переименование столбца 'название' в 'User ID'
        data = self._rename_column(data, 'название', 'User ID')

        # Оставляем в столбце 'User ID' только ID пользователя
        data['User ID'] = data['User ID'].str.split(':').str[1].astype(int)

        # Удаление столбца 'Сорт.'
        data = self._drop_columns(data, ['Сорт.'])

        # Извлечение ID из столбцов 'Среды разработки' и 'Уровень знаний'
        data = self._extract_ids(data, ['Среды разработки', 'Уровень знаний'])

        # Замена пустых строк на None в столбце 'дата'
        data['дата'] = data['дата'].replace('', None)

        # Удаление строк, где 'Уровень знаний' равен NaN
        data = data[data['Уровень знаний'].notna()]

        # Получение списка действительных ID из 'сотрудники_дар'
        valid_ids = set(self.source_data['сотрудники_дар']['id'])

        # Фильтрация строк по списку допустимых ID
        return self._filter_by_user_id(data, valid_ids)

    @t_manager.register_transformation_rule(tables=['языки_пользователей'])
    def _transform_languages_users(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Трансформация данных для 'языки_пользователей'.
        """
        # Переименование столбца 'название' в 'User ID'
        data = self._rename_column(data, 'название', 'User ID')

        # Исключение строк, где 'User ID' равен 'Адаптация Ольга Белякова'
        data = data[data['User ID'] != 'Адаптация Ольга Белякова']

        # Оставляем в столбце 'User ID' только ID пользователя
        data['User ID'] = data['User ID'].str.split(':').str[1].astype(int)

        # Удаление столбца 'Сорт.'
        data = self._drop_columns(data, ['Сорт.'])

        # Извлечение ID из столбцов 'язык' и 'Уровень знаний ин. языка'
        data = self._extract_ids(data, ['язык', 'Уровень знаний ин. языка'])

        # Удаление строк, где 'Уровень знаний ин. языка' равен NaN
        data = data[data['Уровень знаний ин. языка'].notna()]

        # Получение списка действительных ID из 'сотрудники_дар'
        valid_ids = set(self.source_data['сотрудники_дар']['id'])

        # Фильтрация строк по списку допустимых ID
        return self._filter_by_user_id(data, valid_ids)

    @t_manager.register_transformation_rule(
        tables=[
            'инструменты', 'отрасли', 'платформы', 'предметная_область', 'среды_разработки',
            'типы_систем', 'уровень_образования', 'уровни_владения_ин', 'уровни_знаний',
            'уровни_знаний_в_отрасли', 'уровни_знаний_в_предметной_област', 'фреймворки',
            'языки', 'языки_программирования', 'сертификаты_пользователей'
        ]
    )
    def _transform_data_by_drop(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Удаление столбца 'Сорт.' для указанных таблиц.
        """
        return self._drop_columns(data, ['Сорт.'])

    @t_manager.register_transformation_rule(tables=['технологии'])
    def _transform_technologies(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Трансформация данных для 'технологии'.
        """
        # Удаление столбца 'Сорт.'
        data = self._drop_columns(data, ['Сорт.'])

        # Замена символа ']' в столбце 'название'
        data['название'] = data['название'].str.replace(']', '', regex=False)
        return data
