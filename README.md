# hr-project
## Компоненты
### docker
Каталог docker содержит файл docker-compose.yaml, который который используется для определения конфигурации Docker Compose для развертывания Airflow и связанных компонентов в Docker-контейнерах.

### dags
Каталог dags содержит файлы DAG, предназначенные для определения рабочих процессов, путем устанавки задач и их зависимостей, расписания и параметров выполнения.
- **dag_test.py**

Тестовый DAG для Airflow, который выполняет извлечение данных. DAG содержит три задачи. Вначале выполняется стартовая задача "start_step", затем задача "sql_select_step", осуществляющая SQL-запрос к базе данных, и завершающая задача - "end_step".
