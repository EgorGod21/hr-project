import os
import typing as t

from layers.dm.transform_rules import DMTransformRules


tables: t.List[str] = [
    'сотрудники_дар',
    'уровни_знаний',
    'группы_навыков',
    'навыки',
    'группы_навыков_и_уровень_знаний_со'
]

path_to_sql_query_for_creating_layer: str = os.path.join(
    os.path.dirname(__file__), 'dm_create.sql'
)

rules = DMTransformRules()
