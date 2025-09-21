# app/main.py
from fastapi import FastAPI, Response
import random
import time
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from starlette.responses import PlainTextResponse
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

# Métricas de Prometheus - con esto, teoricamente capturo la latencia de las solicitudes
REQUEST_TIME = Histogram(
    "http_request_duration_seconds",
    "Duración de las solicitudes HTTP",
    ["route", "code", "method"],
    buckets=(0.01, 0.05, 0.1, 0.25, 0.5, 1, 2, 5)
)
REQUEST_COUNT = Counter( # rastreo el numero total de solicitudes, para calcular la tasa por segundo (RPS) y la de error..
    "http_requests_total",
    "Contador de solicitudes HTTP",
    ["route", "code", "method"]
)

# Configuración de OpenTelemetry
resource = Resource.create({"service.name": "payments"})
trace.set_tracer_provider(TracerProvider(resource=resource))
otlp_exporter = OTLPSpanExporter(
    endpoint="otel-collector:4317",
    insecure=True
)
trace.get_tracer_provider().add_span_processor(BatchSpanProcessor(otlp_exporter))
tracer = trace.get_tracer(__name__)

app = FastAPI()
FastAPIInstrumentor.instrument_app(app, tracer_provider=trace.get_tracer_provider())

# Handlers de la aplicación
@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/pay")
def pay(delay: int = 50, fail: int = 2, response: Response = None):
    start = time.time()
    try:
        time.sleep(delay / 1000)
        if random.randint(1, 100) <= fail:
            response.status_code = 500
            return {"status": "payment_error"}
        return {"status": "payment_ok"}
    finally:
        duration = time.time() - start
        REQUEST_TIME.labels("/pay", str(response.status_code), "GET").observe(duration)
        REQUEST_COUNT.labels("/pay", str(response.status_code), "GET").inc()

@app.get("/metrics")
def metrics():
    return PlainTextResponse(generate_latest(), media_type=CONTENT_TYPE_LATEST)