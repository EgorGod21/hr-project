# hr-project
## Компоненты
### docker
Каталог docker содержит файлы docker-compose.yaml, Dockerfile и README.md.
- **docker-compose.yaml** используется для определения конфигурации Docker Compose для развертывания Airflow и связанных компонентов в Docker-контейнерах.

- **Dockerfile** содержит инструкции, которые будут применены при сборке Docker-образа и запуске контейнера.

- **README.md** является описательным и содержит инструкции по запуску и настройке Apache Airflow в Docker-контейнерах с использованием Docker Compose.

### dags
Каталог dags содержит каталог layers, а также файлы init_dags.py и dags.py

- **init_dags.py**

init_dags.py содержит функцию init_dag, которая принимает набор параметров, необходимых для инициализации DAGа. Один из аргументов - название переменной airflow - airflow_var_name. Из переменной берутся такие параметры как, имена схем, а также названия объектов-коннекторов airflow для подключения к источнику и приемнику. Далее в самой функции инициализируется менеджер для управления процессами слоя - layer_manager.py (LayerManager), куда передаются правила трансформации, определенные в config слоя. Также определяются две задачи: создание слоя и запуск ETL-процесса между слоями. Все данные параметризованы и динамически передаются в данную функцию, благодаря чему можно легко создавать новые DAGи. Все DAGи создаются в модуле dags.py.

- **dags.py**

dags.py испортирует в себя конфиги всех необходимых слоев и на основании этой информации динамически оркестрирует процесс загрузки данных между слоями. dags.py также импортирует в себя функцию init_dag, в которую передаются необходимые параметры для создания DAGа, а также название переменной airflow - airflow_var_name, config источника и приемника. На основании переданной информации функция динамически инициализирует новый DAG.

### layers

Каталог layers содержит файлы layer_manager.py и abs_transform_ruler.py, а также каталоги слоев ods, dds и dm.

- **layer_manager.py**

layer_manager.py реализует ETL-процесс для управления данными между базами данных. 

Класс LayerManager является универсальным для создания схем и реализации ETL-процессов. Он принимает на вход объект другого класса, описывающего правила трансформации (TransformRules), и сохраняет его. Это делает LayerManager параметризованным и пригодным для повторного использования в различных слоях.

Функция etl_process_implementation выполняет три этапа ETL-процесса: извлечение данных из исходных таблиц базы данных источника, их сохранение в виде DataFrame в словарь source_data, правил трансформации к данным, которые определяются в директории слоя (layers/[ods; dds; dm]) и загрузка преобразованных данных в целевые таблицы базы данных назначения.

Статический метод sql_query_executer_by_path выполняет SQL-скрипт, находящийся по указанному пути.

- **ods, dds, dm**

Каталоги ods, dds и dm имеют идентичную структуру, каждый содержит файлы config.py, create.sql и transform_rules.py

- **config.py**

Содержит всю необходимую информацию и метаинформацию о текущем слое. config.py импортирует необходимые модули и определяет список таблиц tables, формирует путь к SQL-скрипту для создания текущего слоя. Затем создается объект rules класса ODSTransformRules/DDSTransformRules/DMTransformRules, который будет содержать правила трансформации данных для текущего слоя.

- **create.sql**
SQL-скрипт, описывающий создание схемы и таблиц текущего слоя, в которые затем реализуется загрузка трансформированных данных.

- **transform_rules.py**

transform_rules.py реализует логику трансформации данных текущего слоя. Правила трансформации каждой таблицы текущего слоя определены в классе "ODSTransformRules"/"DDSTransformRules"/"DMTransformRules", наследуемом от TransformRules.

- **abs_transform_ruler.py**

abs_transform_ruler.py описывает абстрактный класс TransformRules, который задает структуру и обязательные методы для конкретных реализаций правил трансформации данных, обеспечивая совместимость с классом LayerManager для выполнения ETL-процессов.


### files
Каталог files содержит файл Архитектура решения.docx.
- **Архитектура решения.docx**

Файл, содержащий схему архитектуры решения, описание компонентов и сущностей.
