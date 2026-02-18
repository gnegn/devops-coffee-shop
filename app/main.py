import random
import time
import asyncio
import logging
from fastapi import FastAPI, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler()]
)
logger = logging.getLogger(__name__)

app = FastAPI()

ORDER_COUNTER = Counter('coffee_orders_total', 'Total number of coffee orders', ['type'])
ERROR_COUNTER = Counter('app_errors_total', 'Total number of application errors', ['code'])
ORDER_LATENCY = Histogram('order_processing_seconds', 'Time spent processing an order')

@app.get("/")
async def home():
    logger.info("Головна сторінка відвідана")
    return {"message": "Welcome to the DevOps Coffee Shop!"}

@app.get("/order/{coffee_type}")
async def place_order(coffee_type: str):
    start_time = time.time()
    
    logger.info(f"Нове замовлення: {coffee_type}")
    
    if random.random() < 0.2: 
        ERROR_COUNTER.labels(code="500").inc()
        logger.error(f"Помилка при приготуванні {coffee_type}: Немає молока!")
        return Response(content="Out of milk!", status_code=500)

    await asyncio.sleep(random.uniform(0.1, 0.5))
    
    ORDER_COUNTER.labels(type=coffee_type).inc()
    ORDER_LATENCY.observe(time.time() - start_time)
    
    logger.info(f"Замовлення виконано успішно: {coffee_type}")
    
    return {"status": "success", "coffee": coffee_type}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/metrics")
def metrics():
    return Response(content=generate_latest(), media_type=CONTENT_TYPE_LATEST)