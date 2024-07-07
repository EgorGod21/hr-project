# hr-project
## Компоненты
### docker
Каталог docker содержит файлы docker-compose.yaml, Dockerfile и README.md.
- **docker-compose.yaml** используется для определения конфигурации Docker Compose для развертывания Airflow и связанных компонентов в Docker-контейнерах.

- **Dockerfile** содержит инструкции, которые будут применены при сборке Docker-образа и запуске контейнера.

- **README.md** является описательным и содержит инструкции по запуску и настройке Apache Airflow в Docker-контейнерах с использованием Docker Compose.

### dags
Каталог dags содержит файлы DAG, предназначенные для определения рабочих процессов, путем устанавки задач и их зависимостей, расписания и параметров выполнения.
- **dag_test.py**

Тестовый DAG для Airflow, который выполняет извлечение данных. DAG содержит три задачи. Вначале выполняется стартовая задача "start_step", затем задача "sql_select_step", осуществляющая SQL-запрос к базе данных, и завершающая задача - "end_step".

### files
Каталог files содержит файл Архитектура решения.docx.
- **Архитектура решения.docx**
- 
Файл, содержащий схему архитектуры решения, описание компонентов и сущностей.
