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