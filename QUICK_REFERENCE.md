# SQL Agent Demo - Quick Reference Card

## 🚀 Quick Start Commands

```bash
# Setup Azure resources
cd scripts && ./setup_azure_resources.sh

# Load database
python scripts/load_database.py

# Start application
python app.py

# Or use quick start
./quick_start.sh
```

## 📋 Sample Questions for Demo

### Basic Queries
```
✅ "Show me all products"
✅ "List all customers"
✅ "Show me all categories"
```

### Filtering & Sorting
```
✅ "What are the top 5 most expensive products?"
✅ "Show me discontinued products"
✅ "List products under $20"
```

### Aggregation
```
✅ "How many customers do we have in each country?"
✅ "Count products by category"
✅ "What's the average product price?"
```

### Joins & Complex Queries
```
✅ "Show me orders from customers in Germany"
✅ "Which employees have the most orders?"
✅ "List orders with their customer names"
```

### Business Intelligence
```
✅ "What is the total revenue by category?"
✅ "Show me high-value orders (freight > $50)"
✅ "Which suppliers have the most products?"
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                   User Interface                     │
│              (Web Chat Interface)                    │
└────────────────────┬────────────────────────────────┘
                     │ Natural Language Query
                     ↓
┌─────────────────────────────────────────────────────┐
│                   SQL Agent                          │
│           (GPT-4o + Schema Context)                  │
└────────────────────┬────────────────────────────────┘
                     │ Generated SQL
                     ↓
┌─────────────────────────────────────────────────────┐
│              Azure SQL Database                      │
│            (Northwind Database)                      │
└────────────────────┬────────────────────────────────┘
                     │ Query Results
                     ↓
┌─────────────────────────────────────────────────────┐
│              Natural Language Response               │
│          (Formatted Results + Explanation)           │
└─────────────────────────────────────────────────────┘
```

## 📊 Database Schema (Northwind)

```
Tables:
├── Categories (8 rows)
│   ├── CategoryID (PK)
│   ├── CategoryName
│   └── Description
│
├── Customers (10 rows)
│   ├── CustomerID (PK)
│   ├── CompanyName
│   ├── ContactName
│   ├── City
│   └── Country
│
├── Employees (9 rows)
│   ├── EmployeeID (PK)
│   ├── FirstName
│   ├── LastName
│   ├── Title
│   └── HireDate
│
├── Products (10 rows)
│   ├── ProductID (PK)
│   ├── ProductName
│   ├── SupplierID (FK)
│   ├── CategoryID (FK)
│   ├── UnitPrice
│   └── UnitsInStock
│
├── Orders (5 rows)
│   ├── OrderID (PK)
│   ├── CustomerID (FK)
│   ├── EmployeeID (FK)
│   ├── OrderDate
│   └── Freight
│
└── Order Details (10 rows)
    ├── OrderID (FK)
    ├── ProductID (FK)
    ├── UnitPrice
    ├── Quantity
    └── Discount
```

## 🔧 Configuration Checklist

- [ ] Azure SQL Database created
- [ ] Northwind data loaded
- [ ] Azure AI Foundry project created
- [ ] GPT-4o deployment configured
- [ ] .env file populated with credentials
- [ ] Python dependencies installed
- [ ] ODBC Driver 18 installed
- [ ] Firewall rules configured
- [ ] Application tested locally

## 🔐 Security Features

✅ Read-only queries (SELECT only)  
✅ Azure SQL firewall protection  
✅ Encrypted database connections  
✅ Session-based isolation  
✅ Environment variable configuration  
✅ No SQL injection (parameterized queries)

## 💼 Business Value Points

### For Business Users
- ⚡ Instant data access
- 🎯 No SQL knowledge required
- 📊 Self-service analytics
- ⏱️ Time savings: 5-10 minutes per query

### For IT Teams
- 📉 Reduced query backlog
- 🔄 Consistent query patterns
- 📝 Automatic audit trail
- 🛡️ Controlled data access

### For Organizations
- 💰 Cost reduction
- 🚀 Faster insights
- 📈 Better data utilization
- 🎓 Lower training costs

## 🆘 Troubleshooting Quick Fixes

### Can't connect to database
```bash
# Check firewall rules
az sql server firewall-rule list \
  --resource-group NYP_sql_agent \
  --server your-server-name
```

### ODBC driver not found
```bash
# macOS
brew install msodbcsql18

# Ubuntu/Debian
sudo ACCEPT_EULA=Y apt-get install msodbcsql18
```

### Azure OpenAI rate limit
```python
# Wait and retry, or check quota in Azure Portal
# Navigate to: Azure OpenAI > Quotas
```

### Environment variables missing
```bash
# Verify .env file exists
cat .env

# Compare with template
diff .env .env.template
```

## 📞 Support Resources

- **Azure SQL**: https://docs.microsoft.com/azure/sql-database/
- **Azure OpenAI**: https://docs.microsoft.com/azure/ai-services/openai/
- **Flask**: https://flask.palletsprojects.com/
- **Northwind**: https://github.com/Microsoft/sql-server-samples/

## 🎯 Demo Success Checklist

Pre-Demo:
- [ ] Practice demo 3 times
- [ ] Test all sample queries
- [ ] Verify internet connectivity
- [ ] Have backup screenshots
- [ ] Know customer's industry

During Demo:
- [ ] Start with simple queries
- [ ] Show SQL generation
- [ ] Explain results
- [ ] Relate to customer use case
- [ ] Handle questions confidently

Post-Demo:
- [ ] Send recording
- [ ] Share documentation
- [ ] Provide cost estimate
- [ ] Schedule follow-up
- [ ] Send thank you email

## 🎨 Customization Options

**UI Themes**: Modify colors in templates/index.html  
**Sample Data**: Replace Northwind with custom schema  
**Authentication**: Add Azure AD integration  
**Deployment**: Azure App Service, AKS, or VMs  
**Monitoring**: Add Application Insights  
**Caching**: Implement Redis for query results

## 📈 Metrics to Track

- Query response time
- Query accuracy rate
- User adoption rate
- IT ticket reduction
- Time saved per user
- ROI calculation

---

**Resource Group**: NYP_sql_agent  
**Location**: East US 2  
**Database**: Northwind  
**AI Project**: NYP_AIFoundry  
**Deployment**: NYP_demo

**Application URL**: http://localhost:5000  
**Health Check**: http://localhost:5000/api/health
