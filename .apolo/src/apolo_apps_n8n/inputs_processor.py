import typing as t

from yarl import URL

from apolo_app_types import (
    ContainerImage,
    CustomDeploymentInputs,
)
from apolo_app_types.app_types import AppType
from apolo_app_types.helm.apps.base import BaseChartValueProcessor
from apolo_app_types.helm.apps.custom_deployment import (
    CustomDeploymentChartValueProcessor,
)
from apolo_app_types.helm.utils.storage import get_app_data_files_path_url
from apolo_app_types.protocols.common import (
    ApoloFilesMount,
    ApoloFilesPath,
    ApoloMountMode,
    Container,
    Env,
    MountPath,
    StorageMounts,
)
from apolo_app_types.protocols.common.health_check import (
    HealthCheck,
    HealthCheckProbesConfig,
    HTTPHealthCheckConfig,
)
from apolo_app_types.protocols.common.k8s import Port
from apolo_app_types.protocols.custom_deployment import NetworkingConfig
from apolo_app_types.protocols.shell import ShellAppInputs


class N8nAppChartValueProcessor(BaseChartValueProcessor[ShellAppInputs]):
    _port: int = 5678

    def __init__(self, *args: t.Any, **kwargs: t.Any):
        super().__init__(*args, **kwargs)
        self.custom_dep_val_processor = CustomDeploymentChartValueProcessor(
            *args, **kwargs
        )

    async def gen_extra_values(
        self,
        input_: ShellAppInputs,
        app_name: str,
        namespace: str,
        app_id: str,
        app_secrets_name: str,
        *args: t.Any,
        **kwargs: t.Any,
    ) -> dict[str, t.Any]:
        """
        Generate extra Helm values for Shell configuration.
        """

        base_app_storage_path = get_app_data_files_path_url(
            client=self.client,
            app_type_name="n8n",
            app_name=app_name,
        )
        data_storage_path = base_app_storage_path
        data_container_dir = URL("/home/node/.n8n")

        env_vars: dict[str, t.Any] = {}

        custom_deployment = CustomDeploymentInputs(
            preset=input_.preset,
            image=ContainerImage(
                repository="n8nio/n8n",
                tag="1.115.3",
            ),
            container=Container(
                env=[Env(name=k, value=v) for k, v in env_vars.items()],
            ),
            networking=NetworkingConfig(
                service_enabled=True,
                ingress_http=input_.networking.ingress_http,
                ports=[
                    Port(name="http", port=self._port),
                ],
            ),
            storage_mounts=StorageMounts(
                mounts=[
                    ApoloFilesMount(
                        storage_uri=ApoloFilesPath(
                            path=str(data_storage_path),
                        ),
                        mount_path=MountPath(path=str(data_container_dir)),
                        mode=ApoloMountMode(mode="r"),
                    ),
                ]
            ),
            health_checks=HealthCheckProbesConfig(
                liveness=HealthCheck(
                    enabled=True,
                    initial_delay=30,
                    period_seconds=5,
                    timeout=5,
                    failure_threshold=20,
                    health_check_config=HTTPHealthCheckConfig(
                        path="/",
                        port=self._port,
                    ),
                ),
                readiness=HealthCheck(
                    enabled=True,
                    initial_delay=30,
                    period_seconds=5,
                    timeout=5,
                    failure_threshold=20,
                    health_check_config=HTTPHealthCheckConfig(
                        path="/",
                        port=self._port,
                    ),
                ),
            ),
        )

        custom_app_vals = await self.custom_dep_val_processor.gen_extra_values(
            input_=custom_deployment,
            app_name=app_name,
            namespace=namespace,
            app_id=app_id,
            app_secrets_name=app_secrets_name,
            app_type=AppType.Shell,
        )

        return {**custom_app_vals, "labels": {"application": "n8n"}}
