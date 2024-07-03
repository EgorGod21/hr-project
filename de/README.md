## Описание

Развертывание Apache Airflow с помощью Docker. Поднятие контейнера с Airflow, настройка подключения к базе данных и создание простейшего DAG, читающий данные из базы данных.


## Структура проекта

- `dags/`: Директория для хранения DAGs (Directed Acyclic Graphs).
  - `example_dag.py`: Пример DAG, который читает данные из базы данных.
- `logs/`: Директория для логов Airflow.
- `plugins/`: Директория для пользовательских плагинов Airflow.
- `config/`: Директория для дополнительных конфигурационных файлов.
- `docker-compose.yaml`: Файл для запуска контейнеров с помощью Docker Compose.
- `.env`: Файл с переменными окружения.
- `README.md`: Этот файл с описанием.

## Запуск

Для запуска ознакомьтесь с [инструкцией](https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html)

Перейдите в директорию `de` (в ней содержится `docker-compose.yaml`):
```
cd de
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