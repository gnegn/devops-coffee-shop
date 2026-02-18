FROM python:3.9-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --prefix=/install --no-cache-dir -r requirements.txt

# Using built image to create the final image to reduce size and speed up build time
FROM python:3.9-slim
WORKDIR /app
COPY --from=builder /install /usr/local
COPY main.py .
RUN useradd -m devops_user
USER devops_user
ENV PYTHONUNBUFFERED=1
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
