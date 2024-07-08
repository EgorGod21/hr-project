## Запуск

Для запуска ознакомьтесь с [инструкцией](https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html)

Перейдите в директорию `docker`:
```
cd docker
```
Помимо `dags` в директроии проекта создайте директории `logs`, `plugins`, `config`.
Создайте файл `.env` в директории `docker` с содержимым `AIRFLOW_UID=50000`
Далее выполните команды:
```
docker compose build
docker compose up
```

## Создание подключения

Создайте [поключение](https://airflow.apache.org/docs/apache-airflow/stable/howto/connection.html) к базе данных.