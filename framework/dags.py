from airflow.utils.dates import days_ago

from init_dags import init_dag
import layers.ods.config as ods_cfg
import layers.dds.config as dds_cfg
import layers.dm.config as dm_cfg


# Создание DAGа для миграции данных из слоя Stage в ODS
init_dag(
    dag_id='stage_to_ods_dag',
    start_date=days_ago(1),
    description='Transfer tables from Stage layer DB to ODS layer DB',
    airflow_var_name='stage_to_ods',
    source_config=ods_cfg,
    target_config=ods_cfg,
    schedule_interval='0 20 * * *',
)

# Создание DAGа для очистки/трансформации и миграции данных из слоя ODS в DDS
init_dag(
    dag_id='ods_to_dds_dag',
    start_date=days_ago(1),
    description='Transfer and clean tables from ODS layer DB to DDS layer same DB',
    airflow_var_name='ods_to_dds',
    source_config=ods_cfg,
    target_config=dds_cfg,
    schedule_interval='30 20 * * *',
)

# Создание DAGа для очистки/трансформации и миграции данных из слоя DDS в DM
init_dag(
    dag_id='dds_to_dm_dag',
    start_date=days_ago(1),
    description='Transfer and clean tables from DDS layer DB to DM layer same DB',
    airflow_var_name='dds_to_dm',
    source_config=dds_cfg,
    target_config=dm_cfg,
    schedule_interval='0 21 * * *',
)
