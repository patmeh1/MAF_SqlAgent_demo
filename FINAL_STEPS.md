# 🎉 Final Setup Steps - You're Almost There!

## ✅ What's Already Complete

- ✅ GitHub repository created and code pushed
- ✅ Azure resource group created
- ✅ SQL Server deployed with Azure AD authentication
- ✅ Northwind database created (empty, ready to load)
- ✅ Storage account created
- ✅ Key Vault created
- ✅ AI Foundry Hub created
- ✅ Azure CLI configured and authenticated

## 📋 Remaining Steps (30 minutes)

### Step 1: Load Northwind Database (10 minutes)

**Option A: Using Azure Data Studio (Recommended)**

1. **Download Azure Data Studio**
   - Visit: https://docs.microsoft.com/sql/azure-data-studio/download
   - Install for macOS

2. **Connect to Database**
   - Open Azure Data Studio
   - Click "New Connection"
   - **Server**: `nyp-sql-server-1761717077.database.windows.net`
   - **Authentication Type**: Azure Active Directory - Universal with MFA
   - **Database**: `Northwind`
   - Click "Connect"

3. **Load Data**
   - Click "Open File"
   - Navigate to: `/Users/patmehta/sql-agent-demo/database/northwind.sql`
   - Click "Run" button
   - Wait for completion (~1 minute)

**Option B: Using Azure Portal Query Editor**

1. Go to: https://portal.azure.com
2. Navigate to: Resource Groups → NYP_sql_agent → Northwind (database)
3. Click "Query editor" in left menu
4. Login with Azure AD
5. Copy/paste contents of `database/northwind.sql`
6. Click "Run"

---

### Step 2: Create AI Foundry Project & Deploy GPT-4o (15 minutes)

**I've already opened https://ai.azure.com for you in the Simple Browser**

1. **Sign in** (if not already)
   - Use your Azure credentials

2. **Create Project**
   - Click "All hubs" or find **NYP-AIFoundry-Hub**
   - Click "+ New project"
   - **Project name**: `NYP_AIFoundry`
   - Click "Create"

3. **Deploy GPT-4o Model**
   - In the project, go to "Deployments" (left menu)
   - Click "+ Create deployment" or "+ Deploy model"
   - Select "GPT-4o" from the model list
   - **Deployment name**: `NYP_demo`
   - **Deployment type**: Standard
   - Click "Deploy"
   - Wait for deployment (~5 minutes)

4. **Get Credentials**
   - Once deployed, click on the **NYP_demo** deployment
   - Copy the **Target URI** (endpoint)
   - Copy the **Key** (API key)

---

### Step 3: Update Configuration (2 minutes)

1. **Open the .env file**
   ```bash
   cd /Users/patmehta/sql-agent-demo
   nano .env
   ```
   (or use VS Code to edit)

2. **Update these lines** with values from Step 2:
   ```
   AZURE_OPENAI_ENDPOINT=https://YOUR-ENDPOINT.openai.azure.com/
   AZURE_OPENAI_API_KEY=your-api-key-here
   ```

3. **Save the file**

---

### Step 4: Install Python Dependencies (3 minutes)

```bash
cd /Users/patmehta/sql-agent-demo

# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate

# Install dependencies (including Azure AD auth)
pip install -r requirements.txt
pip install azure-identity
```

---

### Step 5: Update SQL Agent for Azure AD (IMPORTANT)

The `sql_agent.py` needs a small update to use Azure AD authentication. 

I'll create an updated version for you now...

---

### Step 6: Run the Demo! (1 minute)

```bash
cd /Users/patmehta/sql-agent-demo
source venv/bin/activate
python app.py
```

Then open: **http://localhost:5000**

---

## 🔧 Troubleshooting

### Database Connection Issues
- Ensure you're logged in with Azure AD
- Your IP should already be whitelisted: 107.139.5.75
- Check firewall rules in Azure Portal if needed

### AI Foundry Access Issues
- Ensure you have permissions in the subscription
- You may need "Cognitive Services Contributor" role

### Import Errors
- Make sure virtual environment is activated
- Run: `pip install azure-identity pyodbc`

---

## 📊 Current Resource URLs

| Resource | URL |
|----------|-----|
| Azure Portal | https://portal.azure.com |
| AI Foundry | https://ai.azure.com |
| SQL Server | nyp-sql-server-1761717077.database.windows.net |
| Resource Group | NYP_sql_agent |
| GitHub Repo | https://github.com/patmehta_microsoft/NYP_demo |

---

## ✨ After Setup

### Test Queries to Try:
- "Show me all products"
- "What are the top 5 most expensive products?"
- "How many customers do we have in each country?"
- "Which employees have the most orders?"

### Share Your Demo:
The GitHub repository contains all documentation for presenting this to your customer!

---

**Need Help?** Check the detailed guides in:
- `README.md` - Complete documentation
- `DEMO_GUIDE.md` - Presentation guide
- `QUICK_REFERENCE.md` - Quick reference

---

**You're doing great! Just 3 more manual steps and you'll be running the demo! 🚀**
