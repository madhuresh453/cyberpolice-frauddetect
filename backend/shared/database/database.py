import os
from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class DatabaseSettings(BaseSettings):
    mongodb_uri: str = Field(alias="MONGODB_URI")
    db_name: str = Field(default="cyber-police", alias="DB_NAME")
    redis_url: str = Field(default="redis://localhost:6379/0", alias="REDIS_URL")
    jwt_secret: str = Field(alias="JWT_SECRET")
    jwt_algorithm: str = Field(default="HS256", alias="JWT_ALGORITHM")
    access_token_minutes: int = Field(default=15, alias="ACCESS_TOKEN_MINUTES")
    refresh_token_days: int = Field(default=30, alias="REFRESH_TOKEN_DAYS")
    node_env: str = Field(default="development", alias="NODE_ENV")
    port: int = Field(default=5000, alias="PORT")

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    def validate_database_name(self) -> None:
        if self.db_name != "cyber-police":
            raise ValueError("DB_NAME must be exactly cyber-police")


@lru_cache
def get_settings() -> DatabaseSettings:
    settings = DatabaseSettings()
    settings.validate_database_name()
    return settings


def is_test_environment() -> bool:
    return os.getenv("NODE_ENV") == "test" or os.getenv("PYTEST_CURRENT_TEST") is not None
