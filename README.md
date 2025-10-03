# 🚀 LLM Serving on AKS with vLLM & GPU Monitoring

This project demonstrates how to serve **open-weight LLMs (Llama-3.1-8B)** on **Azure Kubernetes Service (AKS)** with **GPU acceleration**, provisioned by **Terraform**, monitored in real time with **Prometheus + Grafana + NVIDIA DCGM Exporter**, and benchmarked under load with `hey`.

---

## 🎥 Demo

GPU temperature, utilization, memory usage, and power draw respond under load from `hey` load tests:

![LLM GPU demo](docs/img/demo.gif)

## 🚀 Features

- **Terraform Provisioning** — AKS cluster + GPU node pool (A100) built as code
- **vLLM Inference Server** — optimized inference engine for serving Llama-3.1-8B
- **Kubernetes Manifests** — Deployment + Service for exposing LLM over REST (`/v1/completions`)
- **Prometheus & Grafana** — metrics + dashboards for system and GPU observability
- **NVIDIA DCGM Exporter** — collects GPU temperature, memory, power, and utilization
- **Load Testing** — with [`hey`](https://github.com/rakyll/hey) to measure latency, throughput, and GPU behavior under stress
- **Cost Efficiency** — Infracost integration to calculate \$/request and \$/1k tokens

---

## ⚙️ Prerequisites

- Azure subscription + AKS quota for GPU VMs (tested with **Standard_ND A100 v4**)
- `terraform` installed
- `kubectl` + `helm` configured for your cluster
- `hey` for benchmarking
- [Infracost](https://www.infracost.io/docs/) (optional, for cost analysis)

---

## 🛠️ Infrastructure with Terraform

### Spin up the AKS cluster with GPU nodes:

```bash
cd infra
terraform init
terraform apply
```

### This creates:

- AKS cluster + GPU node pool
- Networking + RBAC basics

---

## 📦 Deploy vLLM on AKS

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/nvidia-device-plugin.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### Confirm service is live:

```bash
kubectl -n vllm get svc vllm-service
```

### Test endpoint:

```bash
EXTERNAL_IP=$(kubectl -n vllm get svc vllm-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -s http://$EXTERNAL_IP/v1/models | jq .
```

---

## 📊 Monitoring

### Install Prometheus & Grafana

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

### Install NVIDIA DCGM Exporter

```bash
kubectl apply -f k8s/monitoring/dcgm-exporter.yaml
```

### Dashboards - Grafana

- GPU Temperature
- GPU Utilization (%)
- GPU Power Usage
- GPU Memory Used
- SM Clocks

---

## ⚡ Load Testing

### Run a synthetic benchmark with `hey`:

```bash
hey -n 10000 -c 50 -m POST -H "Content-Type: application/json" \
-d '{"model": "meta-llama/Llama-3.1-8B-Instruct", "prompt": "Tell me a story about a robot who goes to the olympics"}' \
http://$EXTERNAL_IP/v1/completions
```

### Example output:

- p95 latency: ~250ms
- Throughput: ~40 requests/sec
- GPU Utilization: ~90%

---

## 📈 Observability in Action

### As load ramps up, watch in Grafana:

- GPU Utilization climbs towards 90%
- Power draw spikes (200–300W)
- Temperature rises from idle → ~55°C
- Memory footprint reflects the model size (~75GB for Llama-3.1-8B)

---

## 💸 Cost Efficiency & Infracost

### Running large LLMs on GPUs can be expensive. To track cost efficiency:

### **GPU Costs** - Using Infracost, estimate the hourly cost of GPU node pools:

```bash
infracost breakdown --path=infra
```

### Example:

- Standard_ND A100 v4 (1 GPU): ~$3.40/hr
- 24 cores + 220GB RAM included in node

### **Throughput vs Cost** - From load testing (hey):

- Throughput: ~40 req/sec at p95 250ms
- Cost Efficiency:

```bash
$3.40 / hr ÷ (40 req/sec * 3600 sec/hr) ≈ $0.000023 / request
```

### **Future Work**

- Automate Infracost in CI/CD to track $/tokens across cluster configs
- Compare vLLM vs Triton for efficiency trade-offs

---

## 🧹 Tear Down

### Stop resources to avoid GPU costs:

```bash
cd infra
terraform destroy
```

### If you encounter provider plugin errors, re-initialize first:

```bash
terraform init -upgrade
terraform destroy
```

(or delete manually in the Azure web app)
