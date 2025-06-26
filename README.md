#  Azure Billing Archive - Cost Optimization using Cosmos DB + Blob Storage

This solution automatically archives cold (older than 90 days) billing records from Azure Cosmos DB to Azure Blob Storage using a Python-based Azure Function. It helps reduce Cosmos DB storage costs while maintaining long-term data availability.

---

##  Features

- Archives billing records from Cosmos DB older than 90 days
- Compresses and stores them in Azure Blob Storage
- Optional deletion of archived records from Cosmos DB
- Timer-triggered Azure Function (runs daily)
- Fully managed using Terraform IaC

---

## Folder Structure

azure-billing-archive/
│
├── terraform/ # Terraform infrastructure setup
│ └── main.tf
│
├── archive-function/ # Azure Function code
│ ├── init.py
│ ├── function.json
│ └── requirements.txt
│
└── README.md


---

##  Deployment Guide

### 1. Prerequisites

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads)
- Python 3.9+
- Azure CLI authenticated
- Access to:
  - Azure Cosmos DB
  - Azure Subscription
  - Azure Blob Storage
  - Function App deployment

---

### 2.  Terraform Deployment

Navigate to the Terraform directory and apply the infrastructure:

```bash
cd terraform
terraform init
terraform apply
