# INENPT-G8: Infrastructure Automation & GitOps on Exoscale with OpenTofu and ArgoCD

This repository provides a complete solution for provisioning, configuring, and managing Kubernetes clusters on [Exoscale](https://www.exoscale.com/) via [OpenTofu](https://opentofu.org/), with GitOps deployments orchestrated by [ArgoCD](https://argo-cd.readthedocs.io/en/stable/). All infrastructure state is securely managed in AWS S3, and CI/CD operations are automated using GitHub Actions. The system is designed for multi-tenant cloud-native applications, such as university e-commerce webshops, with streamlined onboarding and robust security practices.

---

## 📖 Project Overview

- **Automated provisioning** of Exoscale SKS Kubernetes clusters and managed PostgreSQL databases using OpenTofu (Terraform-compatible).
- **Centralized and secure state management** in AWS S3, with access controlled by an IAM user.
- **GitOps workflows** powered by ArgoCD for continuous application delivery.
- **CI/CD pipelines** (plan, apply, destroy, tenant bootstrap) implemented in GitHub Actions.
- **Multi-tenant onboarding** with self-service pipelines for new webshops.
- **Security best practices**: secret management, state locking, and explicit workflow confirmations.

---

## 📝 Prerequisites

### Local Tools
- [OpenTofu CLI](https://opentofu.org/download/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Exoscale CLI](https://github.com/exoscale/cli)

### Cloud Accounts & Permissions
- **Exoscale**: API key/secret, SSH key uploaded to your account.
- **AWS**: IAM user with S3 bucket access (for state backend).
- **GitHub**: Write access to the repository to configure secrets and run workflows.

---

## How to use this Repo

### 🥾 K8s Bootstrap

Get initial Admin Password:
```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Get IP of argocd:
```sh
kubectl get svc -n argocd |grep argocd-server
```

1. Setup Root-App
```sh
kubectl apply -f gitops-base/root-app.yaml -n argocd
```

2. Fix known issue with CertManager
In ArgoCD-UI:
 - Terminate the Synch
 - Manually Sync Cert-Manger
Now the other services should apply automatically.

---

### How to create a new Tenant-Webshop
1. Simply run the [New Tenant Setup Pipeline](https://github.com/MCCE2024/INENPT-G8/actions/workflows/new-tenant.yaml) in GitHub.
Assign a Tenant Name without white-space and APPLY.

This should automatically create a new [Merge Request](https://github.com/MCCE2024/INENPT-G8/pulls)

2. Merge the [Merge Request](https://github.com/MCCE2024/INENPT-G8/pulls).
This will apply the new Database and Tenant Values.
ArgoCD will then Apply the new Values Yaml from the created Tenant.

3. The new tenant will be available at <tenant-name>.lzainzinger.com

⚠️ **Known Issues** ⚠️
- If the product-service pod fails to start, this could be due to the db-secret or the db not beeing deployed yet, just delete the pod after the tofu apply was OK.
- The certificate creation takes a while, if the tenant shop is not available with a certificate issue, just wait a bit.

---

## 🔐 Required GitHub Secrets

Add these repository secrets for GitHub Actions to function:

| Secret Name              | Purpose                                    |
|--------------------------|--------------------------------------------|
| `EXOSCALE_API_KEY`       | Exoscale API key                           |
| `EXOSCALE_API_SECRET`    | Exoscale API secret                        |
| `AWS_ACCESS_KEY_ID`      | AWS IAM user access key                    |
| `AWS_SECRET_ACCESS_KEY`  | AWS IAM user secret key                    |
| `TF_VAR_PGDB_PW`         | PostgreSQL database user password          |
| `TF_VAR_CLOUDFLARE_API_TOKEN`         | API Token for Cloudflare DNS          |

---

## ⚙️ Configuration & State Backend

All infrastructure parameters are defined in `variables.tf` and can be overridden in a `terraform.tfvars` file:

```hcl
exoscale_api_key         = "your-api-key"
exoscale_api_secret      = "your-api-secret"
exoscale_zone            = "at-vie-2"
ssh_key                  = "your-ssh-key-name"
nodepool_instance_type   = "standard.small"
nodepool_size            = 3
```

The OpenTofu backend is configured to use an AWS S3 bucket for remote state:
- S3 bucket (e.g., `opentofu-state-inenptg8`)
- IAM user with permissions: `s3:PutObject`, `s3:GetObject`, `s3:DeleteObject`, `s3:ListBucket`
- Credentials are injected via GitHub Secrets.

`.gitignore` ensures that sensitive files (e.g., `kubeconfig`, `.terraform/`) are never committed.

---

## 🗄️ Database Provisioning

The `db.tf` module provisions an Exoscale managed PostgreSQL 15 instance with:
- Plan: `startup-4`
- Daily backups at 04:00
- Timezone: Europe/Berlin
- Dedicated database and application user
- Password stored as `TF_VAR_PGDB_PW` in GitHub Secrets

All parameters are customizable via `variables.tf` and `terraform.tfvars`. The database is tightly integrated with the Kubernetes cluster for seamless application deployments.

---

## 📁 Project Structure

```
.
├── .github
│   └── workflows
│       ├── new-tenant.yaml
│       ├── pipeline.yaml
│       ├── tofu-apply-manually.yaml
│       └── tofu-destroy-manually.yaml
├── gitops-base
│   └── apps
│       └── webshop
│           └── tenants
│               ├── customer
|               |   └── values.yaml
│               ├── webshop
|               |   └── values.yaml
│               └── webshop-applicationset.yaml
├── k8s-setup
│   ├── cert-manager
│   ├── external-dns
│   ├── nginx-ingress
│   └── root-app.yaml
└── infra
    ├── modules/tenant-db
    ├── .terraform.lock.hcl
    ├── app-values.yaml
    ├── argocd.tf
    ├── customer.tf
    ├── db.tf
    ├── secrets.tf
    ├── sks.tf
    ├── variables.tf
    ├── versions.tf
    └── webshop.tf
```

---

## 🚀 How to Deploy

### 1. Clone and Prepare

```bash
git clone https://github.com/MCCE2024/INENPT-G8.git
cd INENPT-G8/infra
tofu init
```

### 2. Deploy Infrastructure (Local)

```bash
tofu apply
```

---

## 🚦 CI/CD Workflows

### `pipeline.yaml` (Main Pipeline)
**Trigger:** On push/PR to `main`
- Installs required tools
- Validates OpenTofu configuration
- Runs `tofu plan` on PRs
- Applies changes with `tofu apply -auto-approve` on direct pushes to `main`

### `tofu-apply-manually.yaml` (Manual Apply)
**Trigger:** Manually from GitHub Actions UI
- Prompts for confirmation (`APPLY`)
- Runs `tofu apply` if confirmed

### `tofu-destroy-manually.yaml` (Manual Destroy)
**Trigger:** Manually from GitHub Actions UI
- Prompts for confirmation (`YES`)
- Runs `tofu destroy` if confirmed

### `new-tenant.yaml` (Creation of new tenant webshop)
**Trigger:** Manually from GitHub Actions UI
- Prompts for tenant-name (`name-of-tenant`)
- Creates a MR to main with new tenant configuration

All workflows are located in `.github/workflows/` and enforce secure, auditable automation.

### 🧪 Manual Apply via GitHub Actions
You can trigger the apply step manually for extra safety:

1. Go to  GitHub > Actions > "OpenTofu Apply" 
2. Click  “Run workflow” 
3. Type `APPLY` to confirm and execute  
→ See: `tofu-apply-manually.yaml`

### 🔥 Manual Destroy (Confirmation Required)
To remove all infrastructure manually:

1. Go to  GitHub > Actions > "OpenTofu Destroy" 
2. Click  “Run workflow” 
3. Type `YES` to confirm the destruction  
→ See: `tofu-destroy-manually.yaml`

---

## 🧑‍💻 New Tenant Setup Procedure

To create a new webshop tenant:
1. **Run the [New Tenant Setup Pipeline](https://github.com/MCCE2024/INENPT-G8/actions/workflows/new-tenant.yaml):**
   - Enter a tenant name (no spaces) and start the workflow.
   - A pull request is generated with the new tenant configuration.
2. **Merge the Pull Request:**
   - Triggers provisioning of the tenant’s database and values.
   - ArgoCD detects the new values file and deploys the tenant application.
3. **Access the Tenant Shop:**
   - The webshop is available at `https://<tenant-name>.lzainzinger.com`

**Known Issues:**
- If `product-service` fails to start, the database or secret may not be ready. Delete the pod after a successful `tofu apply` to retry.
- Certificate provisioning may take a few minutes. If you see certificate errors, wait and retry.

---

## 🥾 ArgoCD Bootstrap Instructions

1. **Retrieve ArgoCD admin password:**
   ```sh
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```
2. **Get ArgoCD server IP:**
   ```sh
   kubectl get svc -n argocd | grep argocd-server
   ```
3. **Apply Root Application:**
   ```sh
   kubectl apply -f gitops-base/root-app.yaml -n argocd
   ```
4. **Fix CertManager sync issue:**
   - In the ArgoCD UI, terminate the sync and manually sync CertManager.
   - Dependent services will then apply automatically.

---

## 🛠️ Troubleshooting

**GitHub Actions failures:**
- Review logs in the Actions tab
- Ensure all required secrets are set
- Check AWS and Exoscale account status and permissions
- Re-run workflows manually if needed

**Local issues:**
- Run `tofu validate` for syntax/config errors
- Use `kubectl get nodes` to verify cluster connectivity
- Run `tofu init` to reinitialize the working directory if necessary

---

## 🔒 Security Practices

- All API keys and sensitive credentials are stored as encrypted GitHub Secrets
- State files are stored securely in AWS S3 with locking enabled; never committed
- Manual workflows require explicit confirmation to prevent accidental changes
- `.gitignore` ensures sensitive files (e.g., `kubeconfig`, `.terraform/`) are never committed

---

## 🤝 Contributing Guidelines

We welcome contributions! Please follow this workflow:
1. Fork the repository and clone your fork
2. Create a feature branch:  
   `git checkout -b feature/my-change`
3. Make and commit your changes
4. Push to your fork and open a Pull Request

**Best Practices:**
- Keep infrastructure code modular and well-documented
- Always validate changes with `tofu validate`
- Document any significant updates in the PR description

---

## 📚 References & Further Reading

- [OpenTofu Documentation](https://opentofu.org/docs/)
- [Exoscale SKS Documentation](https://community.exoscale.com/documentation/sks/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform S3 Backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
