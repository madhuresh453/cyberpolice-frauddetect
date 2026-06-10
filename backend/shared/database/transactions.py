from collections.abc import Awaitable, Callable
from typing import TypeVar

from .mongodb import get_mongodb_client

T = TypeVar("T")


async def run_transaction(work: Callable[[object], Awaitable[T]]) -> T:
    client = get_mongodb_client()
    async with await client.start_session() as session:
        async with session.start_transaction():
            return await work(session)
