from apolo_apps_n8n.app_types import N8nAppInputs, N8nAppOutputs
from apolo_apps_n8n.inputs_processor import N8nAppChartValueProcessor
from apolo_apps_n8n.outputs_processor import N8nAppOutputProcessor


APOLO_APP_TYPE = "n8n"


__all__ = [
    "APOLO_APP_TYPE",
    "N8nAppOutputProcessor",
    "N8nAppChartValueProcessor",
    "N8nAppInputs",
    "N8nAppOutputs",
]
