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

## ☁️ What Gets Deployed?

-  Exoscale SKS cluster  in region `at-vie-2`
-  One node pool  with 3 `standard.small` nodes
-  ArgoCD  installed to manage app deployments via Git
-  State backend  stored securely in AWS S3
-  CI/CD automation  for provisioning and cleanup

---

## 🔐 Security

- GitHub Actions use encrypted secrets for all API keys
- Terraform state is securely stored in AWS S3
- Manual workflows require explicit typed confirmation to reduce risk
- `.gitignore` prevents committing sensitive config files like `kubeconfig`

---

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
