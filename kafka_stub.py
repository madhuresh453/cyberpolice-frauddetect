import json
import logging
from typing import Any, Dict

logger = logging.getLogger(__name__)

class KafkaProducerStub:
    """
    Production-ready stub for Kafka Producer. 
    Will be replaced with aiokafka in Phase 8.
    """
    async def publish(self, topic: str, message: Dict[str, Any]):
        # Simulate network latency
        logger.info(f"[KAFKA STUB] Publishing to {topic}: {json.dumps(message)}")
        return {"status": "sent", "topic": topic}

class KafkaConsumerStub:
    """
    Production-ready stub for Kafka Consumer.
    """
    def __init__(self, topic: str):
        self.topic = topic

    async def listen(self):
        logger.info(f"[KAFKA STUB] Listening on {self.topic}...")
        yield {"event": "startup_sync", "data": {}}

event_producer = KafkaProducerStub()