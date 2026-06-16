#!/usr/bin/env python3
"""Verify database connectivity."""
import sys

print("=" * 50)
print("DATABASE CONNECTIVITY VERIFICATION")
print("=" * 50)

# MongoDB
try:
    from pymongo import MongoClient
    client = MongoClient('mongodb://localhost:27017', serverSelectionTimeoutMS=5000)
    result = client.admin.command('ping')
    print(f"[OK] MongoDB (27017): {result}")
except Exception as e:
    print(f"[FAIL] MongoDB (27017): {e}")

# Redis
try:
    import redis
    r = redis.Redis(host='localhost', port=6379, decode_responses=True)
    result = r.ping()
    print(f"[OK] Redis (6379): ping={result}")
except Exception as e:
    print(f"[FAIL] Redis (6379): {e}")

# Neo4j
try:
    from neo4j import GraphDatabase
    driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "cybershield"))
    with driver.session() as session:
        result = session.run("RETURN 1 AS num")
        record = result.single()
        print(f"[OK] Neo4j (7687): ping={record['num']}")
    driver.close()
except Exception as e:
    print(f"[FAIL] Neo4j (7687): {e}")

print("=" * 50)