# ☸️ DevSecOps Platform — Proxmox + Kubernetes + GitOps

> Infrastructure as Code complète sur serveur dédié Hetzner.
> Pipeline DevSecOps automatisé : Terraform → Ansible → Cilium → ArgoCD.
> Zero action manuelle. Rebuild complet en une commande.

![CI](https://github.com/bhashas/k8s-proxmox-lab/actions/workflows/ci.yml/badge.svg)
![Security](https://github.com/bhashas/k8s-proxmox-lab/actions/workflows/security.yml/badge.svg)
![GitOps](https://github.com/bhashas/k8s-proxmox-lab/actions/workflows/gitops.yml/badge.svg)

---

## 🏗️ Architecture
```
Hetzner Dedicated Server (64Go RAM / 2x500Go ZFS)
└── Proxmox VE 8.x
├── VM k8s-master    (192.168.192.50) — Control Plane
├── VM k8s-worker1   (192.168.192.51) — Worker + Ceph OSD
└── VM k8s-worker2   (192.168.192.52) — Worker + Ceph OSD
```
### Pipeline GitOps
```
git push

↓
GitHub Actions (self-hosted runner)
↓
ci.yml + security.yml → lint + Checkov + Trivy
↓
terraform.yml → VMs Proxmox (si infra/** modifié)
↓
ansible.yml → K8s + Cilium + ArgoCD (si ansible/** modifié)
↓
gitops.yml → ArgoCD sync (si k8s/** modifié)
↓
✅ Apps déployées automatiquement
```

---

## 🛠️ Stack Technique

### Infrastructure & Provisioning

| Outil | Rôle |
|---|---|
| **Terraform** bpg/proxmox v0.70+ | Provisioning VMs sur Proxmox |
| **Ansible** | Bootstrap OS + Kubernetes |
| **cloud-init** | Configuration initiale des VMs |
| **Proxmox VE** | Hyperviseur bare metal |

### Kubernetes & Réseau

| Outil | Rôle |
|---|---|
| **kubeadm v1.28** | Bootstrap cluster Kubernetes |
| **Cilium 1.15** | CNI eBPF + kube-proxy replacement |
| **Hubble** | Observabilité réseau (UI + Relay) |
| **Gateway API** | Ingress nouvelle génération |

### GitOps & CI/CD

| Outil | Rôle |
|---|---|
| **ArgoCD** | GitOps — déploiement continu |
| **GitHub Actions** | CI/CD pipelines spécialisés |
| **Checkov** | Scan sécurité IaC |
| **Trivy** | Scan vulnérabilités filesystem |

### Apps déployées via ArgoCD

| Namespace | Apps |
|---|---|
| `monitoring` | Prometheus + Grafana + Loki |
| `security` | Falco + Wazuh agent + Zeek + Kyverno + Trivy Operator |
| `auth` | Keycloak (OIDC) |
| `automation` | n8n + Telegram |
| `storage` | Rook-Ceph |
| `backup` | Velero |
| `ingress` | Cert-manager + Cloudflare Tunnel |

---

## 🚀 Déploiement

### Prérequis

- Proxmox VE avec template Ubuntu 24.04 cloud-init (VM ID 9000)
- Token API Proxmox
- Terraform >= 1.7.0
- Ansible

### 1. Cloner le repo

```bash
git clone https://github.com/bhashas/k8s-proxmox-lab
cd k8s-proxmox-lab
```

### 2. Configurer les variables

```bash
cat > infra/terraform.tfvars << EOF
proxmox_api_url      = "https://PROXMOX_IP:8006"
proxmox_token_id     = "terraform-user@pam!token"
proxmox_token_secret = "SECRET"
proxmox_node         = "pve-1"
gateway              = "192.168.192.5"
ssh_public_key       = "ssh-ed25519 ..."
EOF
```

### 3. Provisionner les VMs

```bash
cd infra
terraform init
terraform apply
```

### 4. Installer Kubernetes

```bash
cd ansible
ansible-playbook -i inventory.ini site.yml
```

### 5. Vérifier le cluster

```bash
kubectl get nodes
kubectl get pods -A
```

---

## 📁 Structure du projet
```
k8s-proxmox-lab/
├── .github/workflows/
│   ├── ci.yml           # Lint + Validate (tout push)
│   ├── security.yml     # Checkov + Trivy (tout push)
│   ├── terraform.yml    # Apply si infra/** modifié
│   ├── ansible.yml      # Bootstrap si ansible/** modifié
│   └── gitops.yml       # ArgoCD sync si k8s/** modifié
├── infra/               # Terraform — VMs Proxmox
├── ansible/             # Ansible — K8s bootstrap
│   └── roles/
│       ├── common/      # OS config, swap, sysctl
│       ├── containerd/  # Container runtime
│       ├── kubernetes/  # kubeadm, kubelet, kubectl
│       ├── master/      # kubeadm init + Cilium + ArgoCD
│       └── worker/      # kubeadm join
└── k8s/                 # Manifests ArgoCD (GitOps)
├── base/
│   └── app-of-apps.yaml
└── apps/
├── monitoring/
├── security/
├── auth/
├── automation/
├── storage/
├── backup/
└── ingress/
```

---

## 🔒 Sécurité

- **CPU type host** — instructions SSE4.2 pour Ceph/eBPF
- **UEFI + TPM 2.0** — sécurité au niveau VM
- **Cilium eBPF** — NetworkPolicy L7
- **Kyverno** — Policy as Code
- **Trivy Operator** — scan continu des images
- **Falco** — détection d'anomalies runtime
- **Wazuh agents** — EDR sur les nodes K8s
- **Checkov** — scan IaC à chaque commit
- **Secrets** — jamais committés (.gitignore strict)

---

## 📊 Bonnes pratiques

- ✅ Infrastructure 100% IaC — zero action manuelle
- ✅ Pipeline CI/CD par responsabilité (1 workflow = 1 rôle)
- ✅ GitOps — Git comme source de vérité unique
- ✅ Self-hosted runner — accès réseau privé sécurisé
- ✅ Idempotence Ansible — playbooks rejouables
- ✅ cpu type host — performance optimale pour eBPF/Ceph

---

## 👤 Auteur

**Brahim HASHAS** — Cloud & SecOps Architect

[github.com/bhashas](https://github.com/bhashas)
