## Описание

Развертывание Apache Airflow с помощью Docker. Поднятие контейнера с Airflow, настройка подключения к базе данных и создание простейшего DAG, читающий данные из базы данных.


## Структура проекта

- `dags/`: Директория для хранения DAGs (Directed Acyclic Graphs).
  - `dag_test.py`: Тестовый DAG, который читает данные из базы данных.
- `logs/`: Директория для логов Airflow.
- `plugins/`: Директория для пользовательских плагинов Airflow.
- `config/`: Директория для дополнительных конфигурационных файлов.
- `docker-compose.yaml`: Файл для запуска контейнеров с помощью Docker Compose.
-  `Dockerfile`: Конфигурационный файл, в котором описаны инструкции, применяемые при сборке Docker-образа.
- `.env`: Файл с переменными окружения.
- `README.md`: Файл с описанием.

## Запуск

Для запуска ознакомьтесь с [инструкцией](https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html)

Перейдите в директорию `docker` (в ней содержится `docker-compose.yaml`):
```
cd docker
```
Помимо `dags` создайте директории `logs`, `plugins`, `config`.
Создайте файл `.env` с содержимым `AIRFLOW_UID=50000`
Далее выполните команды:
```
docker compose up airflow-init
docker compose up
```

## Создание подключения

Создайте [поключение](https://airflow.apache.org/docs/apache-airflow/stable/howto/connection.html) к базе данных.

