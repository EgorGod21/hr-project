from abc import ABC, abstractmethod
import typing as t

import pandas as pd


class TransformRules(ABC):
    """Абстрактный метод (контракт) для определение обязательных методов
    для классов LayerTransformRules, где layer = [dds, dm]"""
    @abstractmethod
    def run_transform_rule_for_table(self, table: str) -> pd.DataFrame:
        """Метод для запуска процесса трансформации данных для одной таблицы"""
        pass

    def set_source_data(self, source_data: t.Dict[str, pd.DataFrame]) -> None:
        pass
