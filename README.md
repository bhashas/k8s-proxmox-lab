# ☸️ Kubernetes Lab — Proxmox + Terraform + Ansible

Lab Kubernetes on-premise sur serveur dédié Hetzner sous Proxmox.
Infrastructure as Code complète : provisioning automatisé et configuration idempotente.

## 🏗️ Architecture

| Machine      | IP               | Rôle          |
|--------------|------------------|---------------|
| k8s-master   | 192.168.192.50   | Control Plane |
| k8s-worker1  | 192.168.192.51   | Worker        |
| k8s-worker2  | 192.168.192.52   | Worker        |

## 🛠️ Stack technique

- **Hyperviseur** : Proxmox VE sur serveur dédié Hetzner
- **Provisioning** : Terraform (provider bpg/proxmox) + stockage ZFS
- **Configuration** : Ansible (rôles modulaires, idempotents, tagués)
- **Kubernetes** : v1.28 via kubeadm
- **CNI** : Flannel (10.244.0.0/16)
- **Ingress** : NGINX Ingress Controller
- **Load Balancer** : MetalLB (192.168.192.100-110)
- **Runtime** : containerd

## 📦 Applications déployées

- **nginx** — 2 replicas, Ingress, ClusterIP
- **WordPress + MariaDB** — PersistentVolume, Secrets, Ingress

## 🚀 Déploiement

### Prérequis
- Proxmox VE avec template Ubuntu 22.04 cloud-init (ID 9000)
- Token API Proxmox
- Terraform >= 1.3.0
- Ansible

### 1. Provisionner les VMs
```bash
cd infra
terraform init
terraform apply
```

### 2. Installer Kubernetes
```bash
cd ansible
ansible -i inventory.ini k8s -m ping
ansible-playbook -i inventory.ini site.yml
```

### 3. Vérifier le cluster
```bash
kubectl get nodes -o wide
kubectl get pods --all-namespaces
```

## ✅ Tests de résilience effectués

- **Pod killed** → recréé automatiquement en 10 secondes
- **Worker node down** → pods migrés sur worker disponible en 5 minutes
- **Worker node up** → rejoint le cluster automatiquement

## 🔜 Prochaines étapes

- [ ] Argo CD — GitOps
- [ ] Prometheus + Grafana — Monitoring
- [ ] Longhorn — Stockage persistant distribué
