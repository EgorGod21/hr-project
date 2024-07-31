## Описание

Проект предназначен для автоматизации и упрощения анализа большого количества данных, связанных с профессиональными навыками сотрудников компании. Система использует Apache Airflow для управления потоками данных и Docker для контейнеризации.

## Структура проекта

### [`dags/`](https://github.com/EgorGod21/hr-project/tree/main/dags)

Директория для хранения DAGs (Directed Acyclic Graphs) Apache Airflow.

#### [`scripts/`](https://github.com/EgorGod21/hr-project/tree/main/dags/scripts)

Поддиректория для хранения вспомогательных скриптов.

- [`__init__.py`](https://github.com/EgorGod21/hr-project/blob/main/dags/scripts/__init__.py): Файл, указывающий Python на то, что [`scripts`]((https://github.com/EgorGod21/hr-project/tree/main/dags/scripts)) является пакетом.
- [`db_utils_transfer.py`](https://github.com/EgorGod21/hr-project/blob/main/dags/scripts/db_utils_transfer.py): Скрипт с утилитами для работы с базой данных, такими как создание схемы, управление таблицами и выполнение SQL-запросов.

#### [`sql_scripts/`](https://github.com/EgorGod21/hr-project/tree/main/dags/sql_scripts)

Поддиректория для хранения вспомогательных SQL-скриптов.

- [`create_dds_tables.sql`](https://github.com/EgorGod21/hr-project/blob/main/dags/sql_scripts/create_dds_tables.sql): SQL-скрипт для создания таблиц слоя DDS (Data Distribution Service).
- [`dds_data_func.sql`](https://github.com/EgorGod21/hr-project/blob/main/dags/sql_scripts/dds_data_func.sql): SQL-скрипт создания PL/pgSQL-функции для выгрузки данных из слоя ODS (Operational Data Store) в слой DDS.
- [`run_dds_data_func.sql`](https://github.com/EgorGod21/hr-project/blob/main/dags/sql_scripts/run_dds_data_func.sql): SQL-скрипт для запуска функций из файла [`dds_data_func.sql`]((https://github.com/EgorGod21/hr-project/blob/main/dags/sql_scripts/dds_data_func.sql)).

#### [`layers/`](https://github.com/EgorGod21/hr-project/tree/main/dags/layers)

Поддиректория для хранения вспомогательных файлов для dm слоя.

- [`dm`](https://github.com/EgorGod21/hr-project/tree/main/dags/layers/dm): Директория, содержащая файл [`dm_create.sql`](https://github.com/EgorGod21/hr-project/blob/main/dags/layers/dm/dm_create.sql) - SQL-скрипт для создания таблиц слоя DM (Data Mart), и файл [`transform_rules.py`](https://github.com/EgorGod21/hr-project/blob/main/dags/layers/dm/transform_rules.py), в котором описывается логика трансформации данных.
- [`dag_manager.py`](https://github.com/EgorGod21/hr-project/blob/main/dags/layers/dag_manager.py): Функция etl_for_dm выполняет ETL-процесс (Extract, Transform, Load) для слоя DM, включая извлечение данных, выполнение SQL-скриптов, загрузку в целевую таблицу и передачу для преобразований в transform_rules.py.

Файлы DAGs

- [`test_dag.py`](https://github.com/EgorGod21/hr-project/blob/main/dags/test_dag.py): Пример DAG, который читает данные из базы данных.
- [`dag_ods_layer.py`](https://github.com/EgorGod21/hr-project/blob/main/dags/dag_ods_layer.py): DAG, который загружает исходные данные в слой ODS.
- [`dag_dds_layer.py`](https://github.com/EgorGod21/hr-project/blob/main/dags/dag_dds_layer.py): DAG, который загружает данные из слоя ODS в слой DDS.
- [`dm_dag.py`](https://github.com/EgorGod21/hr-project/blob/main/dags/dm_dag.py): DAG, который загружает данные из слоя DDS в слой DM.

### [`docker/`](https://github.com/EgorGod21/hr-project/tree/main/docker)

Директория для хранения файлов, связанных с Docker.

- [`docker-compose.yaml`](https://github.com/EgorGod21/hr-project/blob/main/docker/docker-compose.yaml): Файл для запуска контейнеров с помощью Docker Compose.
- [`Dockerfile`](https://github.com/EgorGod21/hr-project/blob/main/docker/Dockerfile): Файл для загрузки дополнительных зависимостей.
- [`README.md`](https://github.com/EgorGod21/hr-project/blob/main/docker/README.md): Инструкции по настройке и запуску проекта с использованием Docker.
- [`requirements.txt`](https://github.com/EgorGod21/hr-project/blob/main/docker/requirements.txt): Дополнительные зависимости, используемые в проекте.

### [`files/`](https://github.com/EgorGod21/hr-project/tree/main/files)

Директория для хранения документации.

- [`Архитектура решения.docx`](https://github.com/EgorGod21/hr-project/blob/main/files/%D0%90%D1%80%D1%85%D0%B8%D1%82%D0%B5%D0%BA%D1%82%D1%83%D1%80%D0%B0%20%D1%80%D0%B5%D1%88%D0%B5%D0%BD%D0%B8%D1%8F.docx): Документ, описывающий архитектуру решения проекта.

### [`framework/`](https://github.com/EgorGod21/hr-project/tree/main/framework)

Директория, содержащая фреймворк для упрощения процесса управления потоками данных. Основная идея заключается в декомпозиции задач создания DAGa и реализации ETL-процесса, позволяя инициализировать DAG Airflow более высокоуровнево.

