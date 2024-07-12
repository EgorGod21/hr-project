from abc import ABC, abstractmethod

import pandas as pd
from sqlalchemy.engine import Engine


class TransformRules(ABC):
    """Абстрактный метод (контракт) для определение обязательных методов
    для классов LayerTransformRules, где layer = [dds, dm]"""
    @abstractmethod
    def run_transform_rule_for_table(self, table: str, data: pd.DataFrame, engine: Engine) -> pd.DataFrame:
        """Метод для запуска процесса трансформации данных для одной таблицы"""
        pass
