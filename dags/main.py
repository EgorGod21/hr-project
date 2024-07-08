import ast
import os
import sys

from layers.ods import ods_manager


if __name__ == '__main__':
    # Параметры подключения к source
    source_conn_params = ast.literal_eval(sys.argv[1])

    # Параметры подключения к target
    target_conn_params = ast.literal_eval(sys.argv[2])

    # Путь к SQL-скрипту
    sql_create_file_path = os.path.join(
        os.path.dirname(__file__), 'layers', 'ods', 'ods_create.sql'
    )

    # Чтение содержимого SQL-файла
    with open(sql_create_file_path, 'r', encoding='utf-8') as file:
        sql_create = file.read()

    # Вызов функций
    ods_manager.execute_sql_creation_script(sql_create, target_conn_params)
    ods_manager.execute_sql_insert_script(source_conn_params, target_conn_params)
