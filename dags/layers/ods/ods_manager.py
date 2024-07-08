import logging

import psycopg2
from psycopg2 import extras

# Настройка логирования
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Таблицы слоя ods
ods_tables = [
    'базы_данных',
    'базы_данных_и_уровень_знаний_сотру',
    'инструменты', 'инструменты_и_уровень_знаний_сотр',
    'образование_пользователей', 'опыт_сотрудника_в_отраслях',
    'опыт_сотрудника_в_предметных_обла',
    'отрасли',
    'платформы',
    'платформы_и_уровень_знаний_сотруд',
    'предметная_область',
    'резюмедар',
    'сертификаты_пользователей',
    'сотрудники_дар',
    'среды_разработки',
    'среды_разработки_и_уровень_знаний_',
    'технологии',
    'технологии_и_уровень_знаний_сотру',
    'типы_систем',
    'типы_систем_и_уровень_знаний_сотру',
    'уровень_образования',
    'уровни_владения_ин',
    'уровни_знаний',
    'уровни_знаний_в_отрасли',
    'уровни_знаний_в_предметной_област',
    'фреймворки',
    'фреймворки_и_уровень_знаний_сотру',
    'языки',
    'языки_пользователей',
    'языки_программирования',
    'языки_программирования_и_уровень'
]


# Функция создания таблицы в схеме ods_ira
def execute_sql_creation_script(sql_script, target_conn_params):
    try:
        with psycopg2.connect(**target_conn_params) as target_conn:
            with target_conn.cursor() as target_cur:
                # Выполнение основного SQL-скрипта
                target_cur.execute(sql_script)

                # Проверка существования схемы
                schema_check_sql = """
                SELECT schema_name
                FROM information_schema.schemata
                WHERE schema_name = 'ods_ira';
                """

                # Выполнение SQL-скрипта и проверка существования схемы
                target_cur.execute(schema_check_sql)
                schema_exists = target_cur.fetchone() is not None

                # Вывод результата
                if schema_exists:
                    logger.info("Schema 'ods_ira' exists.")
                else:
                    logger.warning("Schema 'ods_ira' does not exist.")

            # Коммит изменений
            target_conn.commit()
            logger.info("Created successfully")

    # Откат изменений при возникновении ошибок
    except Exception as e:
        logger.error("An error occurred during creation: %s", e)
        if 'target_conn' in locals():
            target_conn.rollback()


# Функция заполнения таблиц в схеме ods_ira
def execute_sql_insert_script(source_conn_params, target_conn_params):
    try:

        # Соедниенение с базой данных source
        with psycopg2.connect(**source_conn_params) as source_conn:

            # Соедниенение с базой данных target
            with psycopg2.connect(**target_conn_params) as target_conn:
                for table in ods_tables:
                    with source_conn.cursor() as source_cur:
                        # Чтение данных из исходной базы данных
                        source_cur.execute(f"SELECT * FROM source_data.{table};")
                        data = source_cur.fetchall()

                    with target_conn.cursor() as target_cur:
                        # Вставка данных в  базу данных target
                        target_cur.execute(f'TRUNCATE TABLE ods_ira.{table};')
                        insert_sql = f"INSERT INTO ods_ira.{table} VALUES %s"
                        extras.execute_values(target_cur, insert_sql, data, page_size=10000)

                # Коммит изменений
                target_conn.commit()
                logger.info("Insert successfully")

    # Откат изменений при возникновении ошибок
    except Exception as e:
        logger.error("An error occurred during insertion: %s", e)
        if 'target_conn' in locals():
            target_conn.rollback()
