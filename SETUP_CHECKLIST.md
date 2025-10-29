# SQL Agent Demo - Setup Checklist

Complete this checklist to ensure your demo environment is ready.

## ☑️ Prerequisites

- [ ] Azure subscription active and accessible
- [ ] Azure CLI installed (`az --version`)
- [ ] Python 3.9+ installed (`python3 --version`)
- [ ] ODBC Driver 18 for SQL Server installed
- [ ] Git installed (optional, for version control)
- [ ] Web browser (Chrome, Edge, or Firefox)

## ☑️ Azure Resource Setup

- [ ] Resource group `NYP_sql_agent` created
- [ ] Azure SQL Server created
- [ ] Azure SQL Database `Northwind` created
- [ ] SQL Server firewall rules configured
  - [ ] Allow Azure services
  - [ ] Your client IP added
- [ ] SQL admin credentials saved securely
- [ ] Connection to database tested

## ☑️ AI Foundry Setup

- [ ] Visited https://ai.azure.com
- [ ] AI Foundry Hub created
- [ ] AI Foundry Project `NYP_AIFoundry` created
- [ ] GPT-4o model deployed
- [ ] Deployment named `NYP_demo`
- [ ] API endpoint URL copied
- [ ] API key copied
- [ ] Deployment tested (optional)

## ☑️ Database Setup

- [ ] Downloaded project files
- [ ] Located `database/northwind.sql` file
- [ ] Loaded Northwind schema into database
- [ ] Verified data loaded (check table counts)
- [ ] Tested connection from local machine

**Verification Commands:**
```sql
SELECT COUNT(*) FROM Categories;  -- Should return 8
SELECT COUNT(*) FROM Customers;   -- Should return 10
SELECT COUNT(*) FROM Products;    -- Should return 10
```

## ☑️ Application Configuration

- [ ] Copied `.env.template` to `.env`
- [ ] Updated `SQL_SERVER` in .env
- [ ] Updated `SQL_DATABASE` in .env
- [ ] Updated `SQL_USERNAME` in .env
- [ ] Updated `SQL_PASSWORD` in .env
- [ ] Updated `AZURE_OPENAI_ENDPOINT` in .env
- [ ] Updated `AZURE_OPENAI_API_KEY` in .env
- [ ] Updated `AZURE_OPENAI_DEPLOYMENT` in .env
- [ ] Verified all values are correct (no placeholders)

## ☑️ Python Environment

- [ ] Created virtual environment (`python3 -m venv venv`)
- [ ] Activated virtual environment
- [ ] Installed dependencies (`pip install -r requirements.txt`)
- [ ] No installation errors
- [ ] Verified Flask installed (`python -c "import flask"`)
- [ ] Verified OpenAI installed (`python -c "import openai"`)
- [ ] Verified pyodbc installed (`python -c "import pyodbc"`)

## ☑️ Application Testing

- [ ] Started application (`python app.py`)
- [ ] No startup errors
- [ ] Application accessible at http://localhost:5000
- [ ] Home page loads correctly
- [ ] Tested sample query: "Show me all products"
- [ ] Results displayed correctly
- [ ] SQL query visible
- [ ] Natural language response generated
- [ ] Tested at least 3 different queries
- [ ] All queries successful

## ☑️ Demo Preparation

- [ ] Read DEMO_GUIDE.md
- [ ] Reviewed sample questions
- [ ] Practiced demo flow 3 times
- [ ] Tested all demo queries
- [ ] Prepared backup screenshots
- [ ] Reviewed architecture diagram
- [ ] Understood business value points
- [ ] Prepared for common questions
- [ ] Know how to handle errors gracefully
- [ ] Laptop charged / power adapter ready

## ☑️ Network & Presentation

- [ ] Stable internet connection verified
- [ ] VPN configured (if required)
- [ ] Screen sharing tested
- [ ] Audio/video tested (if virtual demo)
- [ ] Browser zoom set for visibility (125%)
- [ ] Unnecessary tabs/applications closed
- [ ] Notifications disabled
- [ ] Backup internet option available

## ☑️ Documentation Ready

- [ ] README.md available for sharing
- [ ] DEMO_GUIDE.md reviewed
- [ ] QUICK_REFERENCE.md printed/ready
- [ ] Architecture diagram accessible
- [ ] Cost estimate prepared (if requested)
- [ ] Follow-up email template ready

## ☑️ Final Verification (Day of Demo)

**30 Minutes Before:**
- [ ] Start all Azure resources
- [ ] Test database connection
- [ ] Start application and verify
- [ ] Run 2-3 test queries
- [ ] Clear conversation history
- [ ] Close unnecessary windows
- [ ] Have water nearby
- [ ] Take a deep breath 😊

**Sample Test Query to Run:**
```
"Show me the top 5 most expensive products"
```

**Expected Result:**
- Query executes successfully
- Results show 5 products
- Natural language explanation provided
- SQL query is visible

## 🎯 Success Criteria

Your environment is ready when:
- ✅ Application starts without errors
- ✅ Database connection works
- ✅ Queries return results
- ✅ UI is responsive and attractive
- ✅ You're confident in the demo flow

## 🆘 Emergency Contacts

**Azure Support:**
- Portal: https://portal.azure.com
- Support: [Your support contact]

**Internal:**
- Technical Lead: [Name & Contact]
- Backup Presenter: [Name & Contact]
- Azure Specialist: [Name & Contact]

## 📋 Notes Section

_Use this space for any additional notes or reminders:_

---
---
---

## ✅ Final Sign-off

I have completed all checklist items and am ready for the demo.

**Name:** _________________  
**Date:** _________________  
**Demo Date/Time:** _________________  
**Customer:** _________________

**Confidence Level:** ☐ Ready  ☐ Need Practice  ☐ Need Help

---

**Good luck with your demo! 🚀**

_Remember: Enthusiasm is contagious, and imperfections are opportunities to show how we handle challenges!_
