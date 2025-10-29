#!/bin/bash

# Azure SQL Agent Demo - Infrastructure Setup Script (MCAPS Compliant)
# This script creates all necessary Azure resources for the SQL Agent demo
# with Azure AD authentication instead of SQL authentication

set -e

# Configuration
RESOURCE_GROUP="NYP_sql_agent"
LOCATION="eastus2"
SQL_SERVER_NAME="nyp-sql-server-$(date +%s)"
SQL_DB_NAME="Northwind"
AI_HUB_NAME="NYP-AIFoundry-Hub"
AI_PROJECT_NAME="NYP_AIFoundry"
DEPLOYMENT_NAME="NYP_demo"
STORAGE_ACCOUNT="nypstorage$(date +%s | cut -c 5-10)"
KEY_VAULT_NAME="nyp-kv-$(date +%s | cut -c 5-10)"

echo "=== Azure SQL Agent Demo Setup (Azure AD Auth) ==="
echo ""
echo "This script will create the following resources:"
echo "  - Resource Group: $RESOURCE_GROUP"
echo "  - Location: $LOCATION"
echo "  - SQL Server: $SQL_SERVER_NAME (with Azure AD authentication)"
echo "  - SQL Database: $SQL_DB_NAME"
echo "  - AI Foundry Hub: $AI_HUB_NAME"
echo "  - AI Foundry Project: $AI_PROJECT_NAME"
echo "  - GPT-4o Deployment: $DEPLOYMENT_NAME"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI is not installed. Please install it first."
    echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in to Azure
echo "Checking Azure login status..."
if ! az account show &> /dev/null; then
    echo "Not logged in to Azure. Please log in..."
    az login
fi

# Get subscription ID and user info
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
USER_PRINCIPAL_ID=$(az ad signed-in-user show --query id -o tsv)
USER_EMAIL=$(az ad signed-in-user show --query userPrincipalName -o tsv)

echo "Using subscription: $SUBSCRIPTION_ID"
echo "Logged in as: $USER_EMAIL"
echo ""

# Create Resource Group (if not exists)
echo "Creating resource group..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output table

# Create SQL Server with Azure AD authentication
echo ""
echo "Creating SQL Server with Azure AD authentication..."
az sql server create \
    --name "$SQL_SERVER_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --enable-ad-only-auth \
    --external-admin-principal-type User \
    --external-admin-name "$USER_EMAIL" \
    --external-admin-sid "$USER_PRINCIPAL_ID" \
    --output table

# Configure SQL Server firewall to allow Azure services
echo ""
echo "Configuring SQL Server firewall..."
az sql server firewall-rule create \
    --resource-group "$RESOURCE_GROUP" \
    --server "$SQL_SERVER_NAME" \
    --name "AllowAzureServices" \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0 \
    --output table

# Get client IP and add firewall rule
echo ""
echo "Adding your client IP to firewall..."
CLIENT_IP=$(curl -s https://api.ipify.org)
az sql server firewall-rule create \
    --resource-group "$RESOURCE_GROUP" \
    --server "$SQL_SERVER_NAME" \
    --name "ClientIP" \
    --start-ip-address "$CLIENT_IP" \
    --end-ip-address "$CLIENT_IP" \
    --output table

# Create SQL Database
echo ""
echo "Creating SQL Database..."
az sql db create \
    --resource-group "$RESOURCE_GROUP" \
    --server "$SQL_SERVER_NAME" \
    --name "$SQL_DB_NAME" \
    --service-objective Basic \
    --backup-storage-redundancy Local \
    --output table

echo ""
echo "SQL Database created successfully with Azure AD authentication!"
echo ""

# Create Storage Account for AI Foundry
echo "Creating storage account for AI Foundry..."
az storage account create \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --output table

# Create Key Vault
echo ""
echo "Creating Key Vault..."
az keyvault create \
    --name "$KEY_VAULT_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output table

# Create AI Foundry Hub (AI Studio Hub)
echo ""
echo "Creating AI Foundry Hub..."
echo "Note: Make sure you have the Azure Machine Learning extension installed:"
echo "az extension add --name ml"
echo ""

# Check if ml extension is installed
if ! az extension show --name ml &> /dev/null; then
    echo "Installing Azure ML extension..."
    az extension add --name ml
fi

# Create AI Hub using Azure ML workspace
az ml workspace create \
    --name "$AI_HUB_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output table

echo ""
echo "=== Setup Instructions for AI Foundry Project and GPT-4o Deployment ==="
echo ""
echo "The Azure CLI doesn't fully support AI Foundry project creation yet."
echo "Please complete the following steps in the Azure Portal:"
echo ""
echo "1. Go to https://ai.azure.com"
echo "2. Sign in with your Azure account"
echo "3. Click 'New project' or navigate to your hub: $AI_HUB_NAME"
echo "4. Create a new project named: $AI_PROJECT_NAME"
echo "5. In the project, go to 'Deployments' section"
echo "6. Click '+ Create deployment'"
echo "7. Select 'GPT-4o' model"
echo "8. Set deployment name to: $DEPLOYMENT_NAME"
echo "9. Configure deployment settings and create"
echo ""
echo "After creating the deployment, get the following information:"
echo "  - Endpoint URL"
echo "  - API Key"
echo ""

# Get access token for Azure SQL with Azure AD
echo ""
echo "Getting Azure AD access token for SQL..."
echo "To connect to the database, you'll need to use Azure AD authentication."
echo ""

# Save configuration to file
CONFIG_FILE="../.env"
echo ""
echo "Creating configuration file: $CONFIG_FILE"
cat > "$CONFIG_FILE" << EOF
# Azure SQL Database Configuration (Azure AD Authentication)
SQL_SERVER=${SQL_SERVER_NAME}.database.windows.net
SQL_DATABASE=${SQL_DB_NAME}
SQL_AUTH_TYPE=azure_ad
# Note: Using Azure AD authentication - no username/password needed

# Azure AI Foundry Configuration
AZURE_OPENAI_ENDPOINT=https://YOUR_ENDPOINT.openai.azure.com/
AZURE_OPENAI_API_KEY=your-api-key-here
AZURE_OPENAI_DEPLOYMENT=${DEPLOYMENT_NAME}
AZURE_OPENAI_API_VERSION=2024-08-01-preview

# Application Configuration
FLASK_SECRET_KEY=$(openssl rand -hex 32)

# Azure AD Configuration
AZURE_TENANT_ID=$(az account show --query tenantId -o tsv)
AZURE_CLIENT_ID=your-client-id-here
AZURE_CLIENT_SECRET=your-client-secret-here
EOF

echo ""
echo "Configuration saved to: $CONFIG_FILE"
echo ""
echo "=== Summary ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "SQL Server: ${SQL_SERVER_NAME}.database.windows.net"
echo "SQL Database: $SQL_DB_NAME"
echo "Authentication: Azure AD Only"
echo "Azure AD Admin: $USER_EMAIL"
echo ""
echo "=== Important: Loading Northwind Database ==="
echo ""
echo "To load the Northwind database with Azure AD authentication:"
echo ""
echo "Option 1: Use Azure Data Studio (Recommended)"
echo "  1. Download: https://docs.microsoft.com/sql/azure-data-studio/download"
echo "  2. Connect using: Azure Active Directory - Universal with MFA"
echo "  3. Server: ${SQL_SERVER_NAME}.database.windows.net"
echo "  4. Database: ${SQL_DB_NAME}"
echo "  5. Open and execute: ../database/northwind.sql"
echo ""
echo "Option 2: Use sqlcmd with Azure AD"
echo "  sqlcmd -S ${SQL_SERVER_NAME}.database.windows.net -d ${SQL_DB_NAME} -G -i ../database/northwind.sql"
echo ""
echo "=== Application Configuration ==="
echo "The application needs to be updated to use Azure AD authentication."
echo "We'll need to modify the SQL agent to use Azure AD tokens instead of SQL authentication."
echo ""
echo "Next steps:"
echo "1. Load the Northwind database using one of the methods above"
echo "2. Create AI Foundry project and GPT-4o deployment in Azure Portal"
echo "3. Update the .env file with your Azure OpenAI endpoint and API key"
echo "4. Update sql_agent.py to use Azure AD authentication (see instructions below)"
echo "5. Run 'pip install -r requirements.txt'"
echo "6. Run 'python app.py' to start the web application"
echo ""
echo "Setup complete!"
