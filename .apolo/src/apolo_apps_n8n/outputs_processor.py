import typing as t

from apolo_app_types import ServiceAPI
from apolo_app_types.outputs.base import BaseAppOutputsProcessor
from apolo_app_types.outputs.common import (
    INSTANCE_LABEL,
    get_internal_external_web_urls,
)
from apolo_app_types.protocols.common.networking import WebApp

from .app_types import N8nAppOutputs


class N8nAppOutputProcessor(BaseAppOutputsProcessor[N8nAppOutputs]):
    async def _generate_outputs(
        self,
        helm_values: dict[str, t.Any],
        app_instance_id: str,
    ) -> N8nAppOutputs:
        labels = {"application": "n8n8", INSTANCE_LABEL: app_instance_id}
        (
            internal_web_app_url,
            external_web_app_url,
        ) = await get_internal_external_web_urls(labels)

        return N8nAppOutputs(
            app_url=ServiceAPI[WebApp](
                internal_url=internal_web_app_url,
                external_url=external_web_app_url,
            ),
        )
