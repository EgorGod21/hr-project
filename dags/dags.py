import datetime

from init_dags import init_dag
import layers.ods.config as ods_cfg
import layers.dds.config as dds_cfg
import layers.dm.config as dm_cfg


# Создание DAGа для слоя DDS
init_dag(
    dag_id='dds_dag',
    start_date=datetime.datetime(2024, 7, 14),
    description='Transfer and clean tables from ODS layer DB to DDS layer same DB',
    schedule_interval=None,
    airflow_var_name='ods_to_dds',
    source_config=ods_cfg,
    target_config=dds_cfg,
)

# Создание DAGа для слоя DM
init_dag(
    dag_id='dm_dag',
    start_date=datetime.datetime(2024, 7, 14),
    description='Transfer and clean tables from DDS layer DB to DM layer same DB',
    schedule_interval=None,
    airflow_var_name='dds_to_dm',
    source_config=dds_cfg,
    target_config=dm_cfg,
)
