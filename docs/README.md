# Reto-SRE: Estrategia de Observabilidad con IaC

Este repositorio contiene la implementación de una **estrategia de observabilidad** para un **servicio de pagos**, empleando un enfoque de **Infraestructura como Código (IaC)**.  
El proyecto integra tecnologías modernas como **Terraform, Helm, Kubernetes (Minikube), Prometheus, Grafana y OpenTelemetry**, con el objetivo de habilitar métricas, trazas, logs, alertas y objetivos de nivel de servicio (SLIs/SLOs).

---

## 🚀 Requisitos previos

Versiones mínimas probadas:

- Docker **27.2.1**  
- Minikube **1.36.0**  
- kubectl **1.34.1**  
- Helm **3.19.0**  
- Terraform **1.13.3**  
- Python **3.13.7**

---

## 📂 Estructura del repositorio

```bash
RETO-SRE/
├── app/                     # Código de la aplicación de pagos
│   ├── k8s/                 # Manifiestos Kubernetes (deployment, service, monitors, rules)
│   ├── Dockerfile           # Imagen base de la aplicación
│   ├── main.py              # Aplicación FastAPI instrumentada
│   └── requirements.txt     # Dependencias Python
│
├── docs/                    # Documentación y evidencias
│   ├── diagramas/           # Diagramas de arquitectura / flujo
│   ├── evidence/            # Capturas de monitoreo (Grafana, Jaeger, etc.)
│   ├── informe.md           # Informe técnico
│   ├── resumen.md           # Resumen del informe
│   └── slo_sli.md           # Definición de SLIs y SLOs
│
├── iac/terraform/           # Infraestructura como código
│   ├── modules/             # Módulos Terraform reutilizables
│   │   ├── monitoring/      # Prometheus, Grafana, OpenTelemetry
│   │   │   └── values/      # Archivos de valores helm
│   │   │       ├── kube-prometheus-values.yaml
│   │   │       └── otel-values.yaml
│   │   ├── app/             # Despliegue de la aplicación
│   │   ├── eks/             # Configuración para EKS (cloud)
│   │   ├── iam/             # Roles y políticas
│   │   └── network/         # Red
│   ├── backend.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── variables.tf
│
├── kube-prometheus-stack/   # Recursos generados temporalmente por helm
└── ops/                     # Scripts y pruebas (carga, dashboards, chaos testing)
```

---

## ⚙️ Variables principales (Terraform)

Archivo `iac/terraform/variables.tf`:

- `namespace`: namespace de despliegue (por defecto: `monitoring`).  
- `grafana_user`: usuario inicial de Grafana (sensible).  
- `grafana_password`: contraseña inicial de Grafana (sensible).  
- `chart_version`: versión del chart de kube-prometheus-stack (ejemplo: `65.5.0`).  

Backend configurado como **local**, inicializado con:  
```bash
terraform init -reconfigure
```

---

## 🛠️ Instalación y despliegue

1. **Iniciar Minikube**  
   ```bash
   minikube start --driver=docker --memory=6g --cpus=2
   kubectl get nodes
   ```

2. **Construir la imagen de la aplicación**  
   ```bash
   cd app
   minikube image build -t payments-demo:latest -f Dockerfile .
   ```

3. **Aplicar IaC con Terraform**  
   ```bash
   cd iac/terraform
   terraform init -reconfigure
   terraform apply -auto-approve
   ```

   Esto despliega:
   - kube-prometheus-stack (Prometheus + Grafana).  
   - OpenTelemetry Collector.  
   - Namespace `monitoring`.

4. **Desplegar la aplicación de pagos en Kubernetes**  
   ```bash
   kubectl apply -n monitoring -f app/k8s/
   ```

---

## 📊 Acceso a servicios de observabilidad

- **Grafana**:  
  ```bash
  kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring
  ```
  URL: [http://localhost:3000](http://localhost:3000)  
  Usuario/contraseña: definidos en `grafana_user` y `grafana_password`.

- **Prometheus**:  
  ```bash
  kubectl port-forward svc/kube-prometheus-stack-prometheus 9091:9090 -n monitoring
  ```
  URL: [http://localhost:9091](http://localhost:9091)

- **Jaeger (trazas)**:  
  ```bash
  kubectl port-forward svc/jaeger-query 16686:16686 -n monitoring
  ```
  URL: [http://localhost:16686](http://localhost:16686)

---

## 📈 Pruebas de validación

Se recomienda generar carga sintética para validar la captura de métricas y trazas:  

Ejemplo con `hey`:  
```bash
hey -z 2m -c 20 -q 50 "http://$(minikube service --url payments -n monitoring)/pay?delay=50&fail=2"
```

Durante la prueba se deben observar:  
- Latencia y throughput en **Grafana**.  
- Alertas en **Prometheus**.  
- Transacciones distribuidas en **Jaeger**.  

---

## 📑 SLIs, SLOs y Alertas

- **SLIs**:  
  - Tasa de éxito de peticiones (HTTP < 500).  
  - Latencia p95.  

- **SLOs**:  
  - 99.9% de éxito en 30 días.  
  - p95 < 500 ms.  

- **Alertas implementadas**:  
  - HighErrorRate: tasa de errores 5xx superior al 0.1%.  
  - HighLatencyP95: latencia p95 mayor a 500 ms.  

Más detalle en [`docs/slo_sli.md`](docs/slo_sli.md).  

---

## 📂 Documentación y evidencias

- [`docs/informe.md`](docs/informe.md): Informe técnico.  
- [`docs/resumen.md`](docs/resumen.md): Resumen del informe.  
- [`docs/slo_sli.md`](docs/slo_sli.md): Definición de SLIs y SLOs.  
- [`docs/evidence/`](docs/evidence/): Capturas de dashboards y validaciones.  
- [`docs/diagramas/`](docs/diagramas/): Diagramas de arquitectura.  

---

## ⚠️ Troubleshooting (errores comunes)

- **Node Exporter Pending**: conflicto de puerto 9100. Solución: cambiar `hostPort` en `values.yaml`.  
- **Recursos existentes bloqueando helm_release**: usar `helm uninstall kube-prometheus-stack -n monitoring` y limpiar CRDs antes de reintentar.  
- **Error en terraform init** por backend remoto: usar `terraform init -reconfigure` para trabajar localmente.  
- **Puertos ocupados** (3000, 9090, etc.): verificar procesos con `ss -tulpn | grep <puerto>` y liberarlos.  

---

## 📜 Licencia

Este proyecto es de uso académico y de referencia. Ajustar y adaptar antes de utilizar en entornos productivos.  
