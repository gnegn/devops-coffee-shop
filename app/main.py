import random
import time
from fastapi import FastAPI, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import asyncio

app = FastAPI()

# 1. Metrics: Number of coffee orders
ORDER_COUNTER = Counter(
    'coffee_orders_total', 
    'Total number of coffee orders',
    ['type'] # coffe type
)

# 2.Metrics: Number of errors
ERROR_COUNTER = Counter(
    'app_errors_total',
    'Total number of application errors',
    ['code']
)

# 3. Metrics: Time taken to process an order (Histogram)
ORDER_LATENCY = Histogram(
    'order_processing_seconds',
    'Time spent processing an order'
)

@app.get("/")
def home():
    return {"message": "Welcome to the DevOps Coffee Shop!"}

@app.get("/order/{coffee_type}")
async def place_order(coffee_type: str):
    start_time = time.time()
    
    # Radomly simulate an error (20% chance)
    if random.random() < 0.2: 
        ERROR_COUNTER.labels(code="500").inc()
        return Response(content="Out of milk!", status_code=500)

    # Time taken to process the order (simulate with sleep)
    time.sleep(random.uniform(0.1, 0.5))
    
    await asyncio.sleep(random.uniform(0.1, 0.5))
    # Increment the order counter for the specific coffee type
    ORDER_COUNTER.labels(type=coffee_type).inc()
    
    # Time taken to process the order
    ORDER_LATENCY.observe(time.time() - start_time)
    
    return {"status": "success", "coffee": coffee_type}

@app.get("/health")
def health():
    return {"status": "ok"}

# Prometheus endpoint
@app.get("/metrics")
def metrics():
    return Response(content=generate_latest(), media_type=CONTENT_TYPE_LATEST)