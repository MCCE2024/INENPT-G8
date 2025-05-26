## 🗄️ Database

This project provisions a PostgreSQL database using Exoscale's Database as a Service (DBaaS), managed through the `db.tf` Terraform configuration file.

- **Provisioning**: The PostgreSQL instance is created and configured on Exoscale DBaaS via Terraform resources defined in `db.tf`.
- **Integration**: Connection details and credentials are securely retrieved and injected into the Kubernetes cluster as Secrets, enabling seamless access by applications.
- **Configuration**: Database parameters such as version, storage size, and user credentials are managed through Terraform variables and outputs.
- **Password Handling**: The database password is managed via a Terraform variable, ensuring secure storage and controlled usage. This password is then injected into Kubernetes Secrets to maintain confidentiality and facilitate secure access by authorized pods.  
  *Note: The password is stored in a GitHub Secret (`TF_VAR_PGDB_PW`) and used as a Terraform variable.*
- **Access**: The database is accessible to the Kubernetes cluster over the network, with appropriate security groups and firewall rules configured.
- **Backup & Restore**: Backup policies and maintenance are handled by Exoscale DBaaS, with options configurable in the Terraform setup.
- **Security**: Credentials are stored securely and access is restricted via network policies and Kubernetes RBAC, ensuring only authorized pods can connect.
