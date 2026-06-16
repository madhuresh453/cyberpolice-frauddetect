from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from backend.shared.database.mongodb import close_mongodb, connect_mongodb, get_database_status
from backend.shared.security.security_headers import SecurityHeadersMiddleware
from middleware.rate_limit import rate_limit_middleware
from middleware.request_logger import request_logger_middleware
from routers.auth import router as auth_router
from routers.roles import router as roles_router
from routers.sessions import router as sessions_router
from routers.users import router as users_router



@asynccontextmanager
async def lifespan(_app: FastAPI):
    await connect_mongodb()
    yield
    await close_mongodb()


app = FastAPI(title="CyberShield AI Auth Service", version="3.0.0", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:3001",
        "http://localhost:55389",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:3001",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(SecurityHeadersMiddleware)
app.middleware("http")(request_logger_middleware)
app.middleware("http")(rate_limit_middleware)


app.include_router(auth_router)
app.include_router(users_router)
app.include_router(roles_router)
app.include_router(sessions_router)


@app.get("/health")
async def health():
    return {"status": "healthy", "database": "connected"}


@app.get("/database/status")
async def database_status():
    return await get_database_status()
