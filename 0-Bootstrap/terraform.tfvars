deployment_location = "eastus2"
environment = "dev"
instance_number = "01"
vnet_ip_cidr = "172.x.y.z/28"  # example 172.x.y.z/28
snet_ip_cidr = [
  "172.x.y.z/28"  # example 172.x.y.z/28
]

snet_transit = "snet-transit-org-n"
snet_adb_private = "snet-test-dev-adb-private"
snet_adb_public = "snet-test-dev-adb-public"
snet_k8s = "snet-test-dev-k8s-np"

solution_name = "template"
database_name = "database"
tenant_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
tag_creation_date = "MM/DD/YYYY"

storage_accounts = [
  {
    base_name     = "sa01"
    containers = ["sa01-c01", "sa01-c02"]
  },
  {
    base_name     = "sa02"
    containers = ["sa02-c01", "sa02-c02"]
  },
]

azure_personas = [
  {
    persona    = "project-owners"
    members = [
      #"user:username@org.org",
      #"group:groupname",
    ]
    roles = [
      "Contributor",
      "Data Factory Contributor",
      "Storage Blob Data Contributor",
      "SQL DB Contributor",
      "Azure Kubernetes Service RBAC Reader",
      "Key Vault Secrets User",
      "Key Vault Reader",
      "Key Vault Secrets Officer",
      "Managed Identity Operator",
      "Monitoring Contributor",
      "SQL DB Contributor",
      "SQL Server Contributor",
      "Website Contributor",
    ]
  },
  {
    persona    = "data-writers"
    members = [
      #"user:username@org.org",
      #"group:groupname",
    ]
    roles = [
      "Reader",
      "Data Factory Contributor",
      "Storage Blob Data Contributor",
      "SQL DB Contributor",
      "Azure Kubernetes Service RBAC Reader",
      "Key Vault Reader",
      "Key Vault Secrets User",
      "Key Vault Secrets Officer",
      "Monitoring Reader",
    ]
  },
  {
    persona    = "data-readers"
    members = [
      #"user:username@org.org",
      #"group:groupname",
    ]
    roles = [
      "Reader",
      "Data Factory Reader",
      "Storage Blob Data Reader",
      "Azure Kubernetes Service RBAC Reader",
      "Key Vault Reader",
      "Monitoring Reader",
    ]
  },
    {
    persona    = "build-Service-Account"
    members = [
      #"sa:sa1@org.org",
      #"sa:sa2a@org.org",
    ]
    roles = [
      "Reader",
      "Data Factory Contributor",
      "Storage Blob Data Contributor",
      "SQL DB Contributor",
      "Azure Kubernetes Service RBAC Reader",
      "Key Vault Reader",
      "Key Vault Secrets User",
      "Key Vault Secrets Officer",
      "Monitoring Reader",
    ]
  },
]