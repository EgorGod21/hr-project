### [framework](https://github.com/EgorGod21/hr-project/tree/main/framework)

Каталог framework содержит каталог [`layers`](https://github.com/EgorGod21/hr-project/tree/main/framework/layers), а также файлы [`init_dags.py`](https://github.com/EgorGod21/hr-project/blob/main/framework/init_dags.py) и [`dags.py`](https://github.com/EgorGod21/hr-project/blob/main/framework/dags.py)

- **Модуль [`init_dags.py`](https://github.com/EgorGod21/hr-project/blob/main/framework/init_dags.py)**

[`init_dags.py`](https://github.com/EgorGod21/hr-project/blob/main/framework/init_dags.py) содержит функцию `init_dag`, которая принимает набор параметров, необходимых для инициализации DAGа. Один из аргументов - название переменной Airflow - `airflow_var_name`. Из переменной берутся такие параметры как, имена схем, а также названия объектов-коннекторов Airflow для подключения к источнику и приемнику. Далее в самой функции инициализируется менеджер для управления процессами слоя - `layer_manager.py` (class LayerManager), куда передаются правила трансформации, определенные в файле config.py слоя. Также определяются две задачи: создание слоя и запуск ETL-процесса между слоями. Все данные параметризованы и динамически передаются в данную функцию, благодаря чему можно легко создавать новые DAGи. Все DAGи создаются в модуле [`dags.py`](https://github.com/EgorGod21/hr-project/blob/main/framework/dags.py).

- **Модуль [`dags.py`](https://github.com/EgorGod21/hr-project/blob/main/framework/dags.py)**

[`dags.py`](https://github.com/EgorGod21/hr-project/blob/main/framework/dags.py) импортирует конфиги всех необходимых слоев и на основании этой информации динамически оркестрирует процесс загрузки данных между слоями. [`dags.py`](https://github.com/EgorGod21/hr-project/blob/main/framework/dags.py) также импортирует в себя функцию `init_dag`, в которую передаются необходимые параметры для создания DAGа, а также название переменной Airflow - `airflow_var_name`, конфиг источника и приемника. На основании переданной информации функция динамически инициализирует новый DAG.

### [layers](https://github.com/EgorGod21/hr-project/tree/main/framework/layers)

Каталог [`layers`](https://github.com/EgorGod21/hr-project/tree/main/framework/layers) содержит файлы [`layer_manager.py`](https://github.com/EgorGod21/hr-project/blob/main/framework/layers/layer_manager.py) и [`transform_rules_manager.py`](https://github.com/EgorGod21/hr-project/blob/main/framework/layers/transform_rules_manager.py), а также каталоги слоев [`ods`](https://github.com/EgorGod21/hr-project/tree/main/framework/layers/ods), [`dds`](https://github.com/EgorGod21/hr-project/tree/main/framework/layers/dds) и [`dm`](https://github.com/EgorGod21/hr-project/tree/main/framework/layers/dm).

- **Модуль [`layer_manager.py`](https://github.com/EgorGod21/hr-project/blob/main/framework/layers/layer_manager.py)**

[`layer_manager.py`](https://github.com/EgorGod21/hr-project/blob/main/framework/layers/layer_manager.py) создает структуру целевого слоя в БД, а также верхнеуровнево управляет ETL-процессом для миграции данных между слоем-источником и целевым слоем.

Класс `LayerManager` является универсальным для создания схем и реализации ETL-процессов. Он принимает на вход объект другого класса, описывающего правила трансформации (`TransformRules`), и сохраняет его. Это делает `LayerManager` параметризованным и пригодным для повторного использования в различных слоях.

Функция `etl_process_implementation` выполняет три этапа ETL-процесса: извлечение данных из исходных таблиц базы данных источника, их сохранение в виде DataFrame в словарь `source_data` (и последующее кэширование этой информации), применение правил трансформации к данным, которые определяются в директории слоя (`layers/[ods; dds; dm]`) и загрузка преобразованных данных в целевые таблицы базы данных назначения.

Статический метод `sql_query_executer_by_path` выполняет SQL-скрипт, находящийся по указанному пути.

- **Модуль [`layers/transform_rules_manager.py`](https://github.com/EgorGod21/hr-project/blob/main/framework/layers/transform_rules_manager.py)**

Управляет логикой создания связей между таблицами и методами трансформации данных.

Класс `TransformRulesManager` отвечает за сопоставление методов трансформации с таблицами, кэширование исходных данных и вызова методов для непосредственно самой трансформации данных для каждой таблицы. Декоратор `register_transformation_rule` используется для связывания методов трансформации с таблицами.

- **Директории [`layers/ods`](https://github.com/EgorGod21/hr-project/tree/main/framework/layers/ods), [`layers/dds`](https://github.com/EgorGod21/hr-project/tree/main/framework/layers/dds), [`layers/dm`](https://github.com/EgorGod21/hr-project/tree/main/framework/layers/dm)**

Каталоги `ods, dds и dm` имеют идентичную структуру, каждый содержит файлы `config.py, create.sql и transform_rules.py`, о которых будет описано ниже:

1. **config.py**

Содержит всю необходимую информацию и метаинформацию о текущем слое. `config.py` импортирует необходимые модули и определяет список таблиц `tables`, формирует путь к SQL-скрипту для создания текущего слоя - `path_to_sql_query_for_creating_layer`. Затем создается объект `rules` класса ODSTransformRules/DDSTransformRules/DMTransformRules, который будет содержать правила трансформации данных для текущего слоя.

2. **create.sql**

SQL-скрипт, описывающий создание схемы и таблиц текущего слоя, в которые затем реализуется загрузка трансформированных данных.

3. **transform_rules.py**

Реализует логику трансформации данных текущего слоя. Правила трансформации каждой таблицы текущего слоя определены в классе `ODSTransformRules/DDSTransformRules/DMTransformRules`, наследуемом от `TransformRulesManager`.
