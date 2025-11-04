import json

from apolo_app_types_fixtures.constants import (
    APP_ID,
    APP_SECRETS_NAME,
    DEFAULT_CLUSTER_NAME,
    DEFAULT_NAMESPACE,
    DEFAULT_ORG_NAME,
    DEFAULT_PROJECT_NAME,
)
from apolo_apps_n8n.inputs_processor import N8nAppChartValueProcessor

from apolo_app_types.app_types import AppType
from apolo_app_types.protocols.common import Preset
from apolo_app_types.protocols.shell import ShellAppInputs


async def test_n8n_values_generation(setup_clients):
    apolo_client = setup_clients
    input_processor = N8nAppChartValueProcessor(client=apolo_client)
    helm_params = await input_processor.gen_extra_values(
        input_=ShellAppInputs(
            preset=Preset(name="cpu-small"),
        ),
        app_type=AppType.Shell,
        app_name="n8n-app",
        namespace=DEFAULT_NAMESPACE,
        app_secrets_name=APP_SECRETS_NAME,
        app_id=APP_ID,
    )

    # Verify image configuration
    assert helm_params["image"] == {
        "repository": "n8nio/n8n",
        "tag": "1.115.3",
        "pullPolicy": "IfNotPresent",
    }

    # Verify service configuration
    assert helm_params["service"] == {
        "enabled": True,
        "ports": [{"containerPort": 5678, "name": "http"}],
    }

    # Verify labels
    assert helm_params["labels"] == {"application": "n8n"}

    # Verify pod annotations for storage
    assert "podAnnotations" in helm_params
    annotations = helm_params["podAnnotations"]
    assert "platform.apolo.us/inject-storage" in annotations

    storage_json = annotations["platform.apolo.us/inject-storage"]
    parsed_storage = json.loads(storage_json)
    assert len(parsed_storage) == 1

    # Verify storage mount configuration
    assert parsed_storage[0]["storage_uri"] == (
        f"storage://{DEFAULT_CLUSTER_NAME}/{DEFAULT_ORG_NAME}/{DEFAULT_PROJECT_NAME}/"
        f".apps/n8n/n8n-app"
    )
    assert parsed_storage[0]["mount_path"] == "/home/node/.n8n"
    assert parsed_storage[0]["mount_mode"] == "r"

    # Verify pod labels for storage
    pod_labels = helm_params.get("podLabels", {})
    assert pod_labels.get("platform.apolo.us/inject-storage") == "true"

    # Verify health check configuration
    assert "health_checks" in helm_params
    health_checks = helm_params["health_checks"]

    assert "livenessProbe" in health_checks
    assert health_checks["livenessProbe"]["httpGet"]["path"] == "/"
    assert health_checks["livenessProbe"]["httpGet"]["port"] == 5678
    assert health_checks["livenessProbe"]["initialDelaySeconds"] == 30
    assert health_checks["livenessProbe"]["failureThreshold"] == 20

    assert "readinessProbe" in health_checks
    assert health_checks["readinessProbe"]["httpGet"]["path"] == "/"
    assert health_checks["readinessProbe"]["httpGet"]["port"] == 5678
    assert health_checks["readinessProbe"]["initialDelaySeconds"] == 30
    assert health_checks["readinessProbe"]["failureThreshold"] == 20
