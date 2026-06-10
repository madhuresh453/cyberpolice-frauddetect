"""CyberShield AI - Fraud Network Graph Intelligence Service (Neo4j)"""
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import graph_routes, network_routes

from backend.shared.security.security_headers import SecurityHeadersMiddleware


@asynccontextmanager
async def lifespan(_app: FastAPI):
    yield


app = FastAPI(title="CyberShield AI - Graph Intelligence Service", version="1.0.0", lifespan=lifespan)

app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])
app.add_middleware(SecurityHeadersMiddleware)

app.include_router(graph_routes.router, prefix="/api/v1/graph", tags=["Fraud Graph"])
app.include_router(network_routes.router, prefix="/api/v1/network", tags=["Network Analysis"])


@app.get("/health")
async def health():
    return {"status": "healthy", "service": "graph-intelligence", "database": "neo4j"}


@app.get("/api/v1")
async def api_root():
    return {
        "service": "Graph Intelligence Service (Neo4j)",
        "version": "1.0.0",
        "nodes": {"Phone", "UPI", "Bank", "WhatsApp", "Device", "Case", "Evidence", "Citizen", "Scammer"},
        "relationships": {"CALLED", "TRANSFERRED", "ASSOCIATED", "REPORTED", "LINKED_TO", "OWNS", "USES"},
        "endpoints": [
            "POST /api/v1/graph/nodes - Create nodes",
            "GET  /api/v1/graph/search/{value} - Search by phone, UPI, device",
            "GET  /api/v1/graph/paths/{from_value}/{to_value} - Shortest path",
            "GET  /api/v1/graph/clusters - Detect fraud rings",
            "GET  /api/v1/network/fraud-ring/{phone} - Fraud ring detection",
            "GET  /api/v1/network/associates/{phone} - Network associates",
            "GET  /api/v1/graph/visualize/{phone} - Full network visualization data",
        ],
    }