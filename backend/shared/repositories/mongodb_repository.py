from typing import Any, Generic, TypeVar

from beanie import Document

DocumentType = TypeVar("DocumentType", bound=Document)


class MongoRepository(Generic[DocumentType]):
    def __init__(self, document_cls: type[DocumentType]) -> None:
        self.document_cls = document_cls

    async def create(self, data: dict[str, Any]) -> DocumentType:
        return await self.document_cls(**data).insert()

    async def update(self, document_id: str, data: dict[str, Any]) -> DocumentType | None:
        document = await self.document_cls.get(document_id)
        if not document:
            return None
        for key, value in data.items():
            setattr(document, key, value)
        await document.save()
        return document

    async def delete(self, document_id: str) -> bool:
        document = await self.document_cls.get(document_id)
        if not document:
            return False
        if hasattr(document, "soft_delete"):
            await document.soft_delete()
        else:
            await document.delete()
        return True

    async def find_one(self, filters: dict[str, Any]) -> DocumentType | None:
        return await self.document_cls.find_one(filters)

    async def find_many(self, filters: dict[str, Any], limit: int = 100, skip: int = 0) -> list[DocumentType]:
        return await self.document_cls.find(filters).skip(skip).limit(limit).to_list()

    async def paginate(self, filters: dict[str, Any], page: int = 1, limit: int = 25) -> dict[str, Any]:
        safe_limit = min(max(limit, 1), 100)
        safe_page = max(page, 1)
        skip = (safe_page - 1) * safe_limit
        items = await self.find_many(filters, safe_limit, skip)
        total = await self.document_cls.find(filters).count()
        return {"items": items, "page": safe_page, "limit": safe_limit, "total": total}

    async def aggregate(self, pipeline: list[dict[str, Any]]) -> list[dict[str, Any]]:
        return await self.document_cls.aggregate(pipeline).to_list()
