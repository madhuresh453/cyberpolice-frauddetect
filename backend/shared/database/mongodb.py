from motor.motor_asyncio import AsyncIOMotorClient
from beanie import init_beanie

from .database import get_settings
from .documents import DOCUMENT_MODELS

_client: AsyncIOMotorClient | None = None


async def connect_mongodb() -> AsyncIOMotorClient:
    global _client
    settings = get_settings()
    if _client is None:
        _client = AsyncIOMotorClient(
            settings.mongodb_uri,
            serverSelectionTimeoutMS=10000,
            connectTimeoutMS=10000,
            socketTimeoutMS=45000,
            maxPoolSize=100,
            minPoolSize=5,
            retryWrites=True,
        )
        await _client.admin.command("ping")
        await init_beanie(
            database=_client[settings.db_name],
            document_models=DOCUMENT_MODELS,
            allow_index_dropping=True,
        )
    return _client


async def close_mongodb() -> None:
    global _client
    if _client is not None:
        _client.close()
        _client = None


def get_mongodb_client() -> AsyncIOMotorClient:
    if _client is None:
        raise RuntimeError("MongoDB client is not initialized")
    return _client


async def get_database_status() -> dict:
    settings = get_settings()
    client = get_mongodb_client()
    collections = await client[settings.db_name].list_collection_names()
    return {"database": settings.db_name, "collections": sorted(collections), "connected": True}
