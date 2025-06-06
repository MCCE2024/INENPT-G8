# INENPT-G8

This project provisions and manages a  Kubernetes cluster  on the [Exoscale](https://www.exoscale.com/) cloud using  [OpenTofu](https://opentofu.org/) . It also installs  [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)  to enable GitOps workflows. State management is centralized in  AWS S3 , with authentication via a dedicated  IAM user . The infrastructure lifecycle is automated using  GitHub Actions .

---

## 🌟 Key Features

-  Provisioning of Exoscale SKS (Kubernetes) clusters 
-  Infrastructure as Code  via OpenTofu (Terraform-compatible)
-  Centralized state management in AWS S3 
-  CI/CD automation  through GitHub Actions
-  GitOps with ArgoCD  on the managed cluster

---

## 📋 Requirements

### ✅ Local Tools
- [OpenTofu CLI](https://opentofu.org/download/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Exoscale CLI](https://github.com/exoscale/cli)

### ☁️ Accounts & Access
-  Exoscale Account  with:
  - API key and secret
  - Uploaded SSH key
-  AWS Account  with:
  - An IAM user with S3 access
  - An S3 bucket configured for OpenTofu state storage
-  GitHub Access  with repo write permissions

---

## 🔐 GitHub Secrets

These secrets must be added to your repository for GitHub Actions to work:

| Secret Name              | Description                            |
|--------------------------|----------------------------------------|
| `EXOSCALE_API_KEY`       | Exoscale API key                       |
| `EXOSCALE_API_SECRET`    | Exoscale API secret                    |
| `AWS_ACCESS_KEY_ID`      | AWS IAM user's access key              |
| `AWS_SECRET_ACCESS_KEY`  | AWS IAM user's secret key              |
| `TF_VAR_PGDB_PW`         | Database user's secret key              |

---

## ⚙️ Configuration Overview

All customizable parameters are defined in `variables.tf`. Override them via a `terraform.tfvars` file like this:

```hcl
exoscale_api_key         = "your-api-key"
exoscale_api_secret      = "your-api-secret"
exoscale_zone            = "at-vie-2"
ssh_key                  = "your-ssh-key-name"
nodepool_instance_type   = "standard.small"
nodepool_size            = 3
```

Your `.gitignore` excludes files like `kubeconfig` and `.terraform/`, so they won’t be committed.

---

## 🪣 State Management with AWS S3

The OpenTofu state is stored remotely in  Amazon S3 , ensuring shared access and safe locking across team environments.  
The backend is configured in the project (`main.tf` or equivalent), and requires:

- An AWS S3 bucket (e.g., `my-opentofu-state`)
- An IAM user with `s3:PutObject`, `s3:GetObject`, `s3:DeleteObject`, and `s3:ListBucket` permissions

---

## 🗄️ Database Resources

The `db.tf` file provisions a managed PostgreSQL 15 instance in Exoscale using the `startup-4` plan. It configures daily backups at 04:00, applies a timezone setting of Europe/Berlin, and creates a dedicated database and application user. All resource parameters are customizable via `variables.tf` and `terraform.tfvars`, ensuring seamless integration with the Kubernetes infrastructure.
Note: The password is stored in a GitHub Secret (TF_VAR_PGDB_PW) and used as a Terraform variable.

---

## 📦 Project Structure

```
.
├── argocd.tf                 # ArgoCD deployment
├── sks.tf                    # SKS cluster and node pool
├── variables.tf              # Input variables
├── versions.tf               # Provider & OpenTofu version config
├── .gitignore                # Excludes kubeconfig and .terraform
├── pipeline.yaml             # CI pipeline for plan & apply
├── tofu-apply-manually.yaml # Manual apply trigger with confirmation
├── tofu-destroy-manually.yaml # Manual destroy trigger with confirmation
```

---

## 🚀 How to Deploy

### 1. Clone and Prepare

```bash
git clone https://github.com/MCCE2024/INENPT-G8.git
cd INENPT-G8
tofu init
```

### 2. Deploy Infrastructure (Local)

```bash
tofu apply
```

---

## ⚙️ GitHub Actions: CI/CD Pipelines

This project uses GitHub Actions for infrastructure automation:

### 🔁 Auto Plan & Apply on Commit to `main`
When you  push or merge to the `main` branch , this workflow is triggered:

- Validates the OpenTofu configuration
- Runs `tofu plan` for pull requests
- Applies automatically with `tofu apply -auto-approve` on direct push  
→ See: `.github/workflows/pipeline.yaml`

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

## 📄 GitHub Workflow Descriptions

The project includes three automated workflows in `.github/workflows/`:

- **`pipeline.yaml`**  
  Runs automatically on every push or PR to `main`. It:
  - Installs CLI tools and validates Kubernetes access
  - Runs `tofu plan` on PRs
  - Runs `tofu apply -auto-approve` on direct pushes to `main`

- **`tofu-apply-manually.yaml`**  
  A manual GitHub Action that:
  - Allows maintainers to trigger `tofu apply` from the UI
  - Requires entering `APPLY` as confirmation

- **`tofu-destroy-manually.yaml`**  
  A manual GitHub Action that:
  - Destroys all infrastructure provisioned by OpenTofu
  - Requires typing `YES` to proceed, as a safety guard

These workflows help enforce secure and predictable automation for both day-to-day updates and exceptional maintenance.

## ☁️ What Gets Deployed?

-  Exoscale SKS cluster  in region `at-vie-2`
-  One node pool  with 3 `standard.small` nodes
-  ArgoCD  installed to manage app deployments via Git
-  State backend  stored securely in AWS S3
-  CI/CD automation  for provisioning and cleanup

---

## 🛠️ Troubleshooting

If a GitHub Action fails:

- Check the **Actions** tab in GitHub to view full logs
- Ensure required secrets are configured in the repository
- Make sure your AWS and Exoscale accounts are active and properly scoped
- Re-run workflows manually via GitHub UI if needed

For local issues:

- Run `tofu validate` to check configuration syntax
- Use `kubectl get nodes` to test cluster connectivity
- Re-run `tofu init` if working directory errors occur

## 🔐 Security

- GitHub Actions use encrypted secrets for all API keys
- Terraform state is securely stored in AWS S3
- Manual workflows require explicit typed confirmation to reduce risk
- `.gitignore` prevents committing sensitive config files like `kubeconfig`

---

## K8s Bootstrap

Get initial Admin Password:
```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
---

Install NGINX:
```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
```

Install SealedSecrets:
TODO

Install ExternalDNS:
Create Values file for configuration:
```sh
provider: 
  name: cloudflare
env:
  - name: CF_API_TOKEN
    valueFrom:
      secretKeyRef:
        name: cloudflare-api-key
        key: apiKey
```

Create secret:
```sh
kubectl create secret generic cloudflare-api-key --from-literal=apiKey=<API-KEY> --from-literal=email=<EMAIL> -n external-dns
```

```sh
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update

helm upgrade --install external-dns external-dns/external-dns --values values.yaml
```

## 🤝 Contributing

We welcome contributions from the team.  
Please follow this workflow:

1. Fork the repo and clone your fork
2. Create a feature branch:  
   `git checkout -b feature/my-change`
3. Make your changes and commit
4. Push to your fork and open a Pull Request

Guidelines:
- Use clean, modular infra code
- Validate configs with `tofu validate`
- Document any major changes

---

## 📚 References

- [OpenTofu Docs](https://opentofu.org/docs/)
- [Exoscale SKS](https://community.exoscale.com/documentation/sks/)
- [ArgoCD](https://argo-cd.readthedocs.io/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Terraform Remote State in S3](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
