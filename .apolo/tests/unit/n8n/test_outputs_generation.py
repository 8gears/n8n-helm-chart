from apolo_apps_n8n.outputs_processor import N8nAppOutputProcessor


async def test_n8n_outputs_generation(setup_clients, mock_kubernetes_client, app_instance_id):
    """Test that N8n output processor generates correct outputs."""
    output_processor = N8nAppOutputProcessor()

    helm_values = {
        "image": {
            "repository": "n8nio/n8n",
            "tag": "1.115.3",
        },
        "labels": {"application": "n8n"},
    }

    outputs = await output_processor.generate_outputs(
        helm_values=helm_values,
        app_instance_id=app_instance_id,
    )

    # Verify outputs structure
    assert "app_url" in outputs
    assert "internal_url" in outputs["app_url"]
    assert "external_url" in outputs["app_url"]
