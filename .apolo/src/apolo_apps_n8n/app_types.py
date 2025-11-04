from pydantic import Field, ConfigDict
from typing import Literal
import typing as t
from apolo_app_types.protocols.postgres import PostgresURI
from apolo_app_types.protocols.common import (
    AppInputs,
    AppOutputs,
    BasicNetworkingConfig,
    Preset,
    SchemaExtraMetadata,
    AbstractAppFieldType,
)

class N8nDatabasePostgres(AbstractAppFieldType):
    model_config = ConfigDict(
        protected_namespaces=(),
        json_schema_extra=SchemaExtraMetadata(
            title="Postgres",
            description="Use PostgreSQL server as metadata storage for N8n.",
        ).as_json_schema_extra(),
    )

    storage_type: Literal["postgres"] = Field(
        default="postgres",
        json_schema_extra=SchemaExtraMetadata(
            title="Storage Type",
            description="Storage type for N8n metadata.",
        ).as_json_schema_extra(),
    )
    postgres_uri: t.Annotated[
        PostgresURI,
        Field(
            json_schema_extra=SchemaExtraMetadata(
                title="Postgres URI",
                description="Connection URI to the PostgreSQL metadata database.",
            ).as_json_schema_extra()
        ),
    ]


class N8nDatabaseSQLite(AbstractAppFieldType):
    model_config = ConfigDict(
        protected_namespaces=(),
        json_schema_extra=SchemaExtraMetadata(
            title="SQLite",
            description="Use SQLite on a dedicated block "
            "device as metadata store for N8n.",
        ).as_json_schema_extra(),
    )

    storage_type: Literal["sqlite"] = Field(
        default="sqlite",
        json_schema_extra=SchemaExtraMetadata(
            title="Storage Type",
            description="Storage type for N8n metadata.",
        ).as_json_schema_extra(),
    )


N8nStorage = N8nDatabaseSQLite | N8nDatabasePostgres

class N8nAppInputs(AppInputs):
    preset: Preset
    networking: BasicNetworkingConfig = Field(
        default_factory=BasicNetworkingConfig,
        json_schema_extra=SchemaExtraMetadata(
            title="Networking Settings",
            description="Configure network access, HTTP authentication,"
            " and related connectivity options.",
        ).as_json_schema_extra(),
    )
    database_type: N8nStorage = Field(default=N8nDatabaseSQLite())


class N8nAppOutputs(AppOutputs):
    pass
