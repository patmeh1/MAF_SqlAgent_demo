# SQL Agent Demo - Natural Language Database Query

A customer demo application that uses Azure OpenAI GPT-4o and the Microsoft Agent Framework to query an Azure SQL Database using natural language. Built with Flask, this web application provides an intuitive chat interface for interacting with the Northwind database.

![Demo Screenshot](https://via.placeholder.com/800x400?text=SQL+Agent+Chat+Interface)

## 🎯 Features

- **Natural Language Queries**: Ask questions about your database in plain English
- **Intelligent SQL Generation**: GPT-4o automatically generates optimized SQL queries
- **Real-time Results**: View query results in an interactive, formatted table
- **Chat Interface**: Beautiful, modern web UI with conversation history
- **Azure Integration**: Fully integrated with Azure SQL Database and Azure AI Foundry
- **Safe Queries**: Read-only queries to protect your data
- **Query Explanations**: Understand what SQL is being executed

## 🏗️ Architecture

```
User Question (Natural Language)
        ↓
   SQL Agent (GPT-4o)
        ↓
   SQL Query Generation
        ↓
   Azure SQL Database
        ↓
   Results + Natural Language Response
        ↓
   Web Chat Interface
```

## 📋 Prerequisites

- **Python 3.9+**
- **Azure Subscription**
- **Azure CLI** installed and configured
- **ODBC Driver 18 for SQL Server** ([Download](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server))

### Installing ODBC Driver

**macOS:**
```bash
brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
brew update
brew install msodbcsql18 mssql-tools18
```

**Linux (Ubuntu/Debian):**
```bash
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18
```

**Windows:**
Download and install from [Microsoft's website](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server)

## 🚀 Setup Instructions

### 1. Clone or Navigate to the Demo Directory

```bash
cd sql-agent-demo
```

### 2. Set Up Azure Resources

Make the setup script executable and run it:

```bash
chmod +x scripts/setup_azure_resources.sh
cd scripts
./setup_azure_resources.sh
```

This script will:
- Create an Azure Resource Group: `NYP_sql_agent`
- Deploy an Azure SQL Server and Database
- Set up firewall rules
- Configure storage and key vault
- Generate a `.env` configuration file

**Important:** You'll be prompted to enter a SQL admin password. Make it strong!

### 3. Load the Northwind Database

After the Azure resources are created, load the sample data:

**Option A: Using sqlcmd (recommended)**
```bash
cd ..
sqlcmd -S <your-server-name>.database.windows.net -d Northwind -U sqladmin -P '<your-password>' -i database/northwind.sql
```

**Option B: Using Azure Data Studio or SQL Server Management Studio**
1. Connect to your Azure SQL Database
2. Open `database/northwind.sql`
3. Execute the script

### 4. Set Up Azure AI Foundry Project

Since Azure CLI doesn't fully support AI Foundry project creation yet, complete this in the Azure Portal:

1. Go to [https://ai.azure.com](https://ai.azure.com)
2. Sign in with your Azure account
3. Create a new project:
   - **Project Name**: `NYP_AIFoundry`
   - **Hub**: Select the hub created by the script
4. Deploy GPT-4o:
   - Navigate to **Deployments**
   - Click **+ Create deployment**
   - Select **GPT-4o** model
   - **Deployment Name**: `NYP_demo`
   - Configure settings and create

5. Get your credentials:
   - Go to your deployment
   - Copy the **Endpoint URL**
   - Copy the **API Key**

### 5. Configure Environment Variables

Update the `.env` file in the project root with your Azure OpenAI credentials:

```bash
# The script created this file, but you need to update these values:
AZURE_OPENAI_ENDPOINT=https://your-resource-name.openai.azure.com/
AZURE_OPENAI_API_KEY=your-api-key-here
```

### 6. Create Python Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 7. Install Python Dependencies

```bash
pip install -r requirements.txt
```

### 8. Run the Application

```bash
python app.py
```

The application will start on `http://localhost:5000`

## 💬 Using the Application

1. Open your browser and navigate to `http://localhost:5000`
2. Type natural language questions in the chat input
3. Press Enter or click Send
4. View the generated SQL query, results, and natural language explanation

### Example Questions

- "Show me all products"
- "What are the top 5 most expensive products?"
- "How many customers do we have in each country?"
- "Which employees have the most orders?"
- "Show me orders from customers in Germany"
- "What is the total revenue by category?"
- "List all suppliers from the USA"
- "Show me products that are discontinued"

## 📁 Project Structure

```
sql-agent-demo/
├── app.py                      # Flask web application
├── sql_agent.py                # SQL Agent implementation
├── requirements.txt            # Python dependencies
├── .env                        # Environment configuration (created by setup)
├── .env.template               # Template for environment variables
├── .gitignore                  # Git ignore rules
├── README.md                   # This file
├── database/
│   └── northwind.sql           # Northwind database schema and data
├── scripts/
│   └── setup_azure_resources.sh # Azure infrastructure setup script
├── templates/
│   └── index.html              # Web chat interface
└── static/                     # (Optional) Static assets
```

## 🔧 Configuration

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `SQL_SERVER` | Azure SQL Server hostname | `nyp-sql-server.database.windows.net` |
| `SQL_DATABASE` | Database name | `Northwind` |
| `SQL_USERNAME` | SQL admin username | `sqladmin` |
| `SQL_PASSWORD` | SQL admin password | `YourPassword123!` |
| `AZURE_OPENAI_ENDPOINT` | Azure OpenAI endpoint URL | `https://xxx.openai.azure.com/` |
| `AZURE_OPENAI_API_KEY` | Azure OpenAI API key | `abc123...` |
| `AZURE_OPENAI_DEPLOYMENT` | GPT-4o deployment name | `NYP_demo` |
| `AZURE_OPENAI_API_VERSION` | API version | `2024-08-01-preview` |
| `FLASK_SECRET_KEY` | Flask session secret | Auto-generated |

## 🎨 Customization

### Adding More Sample Questions

Edit `templates/index.html` and add questions to the sample questions list:

```html
<li onclick="askQuestion('Your question here')">• Your question here</li>
```

### Modifying the Database Schema

The agent automatically reads the database schema on initialization. To use a different database:

1. Update the SQL connection settings in `.env`
2. Ensure the database is accessible
3. The agent will automatically adapt to the new schema

### Changing the UI Theme

The chat interface uses CSS in `templates/index.html`. Customize colors by modifying the gradient values:

```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

## 🔐 Security Considerations

### For Production Deployment:

1. **Use Azure AD Authentication** instead of SQL authentication
2. **Implement rate limiting** on API endpoints
3. **Add input validation** and sanitization
4. **Enable CORS** only for trusted domains
5. **Use Azure Key Vault** for secrets management
6. **Implement logging and monitoring** with Azure Application Insights
7. **Enable HTTPS** with valid SSL certificates
8. **Restrict database firewall rules** to specific IP ranges
9. **Use read-only database credentials** for the agent
10. **Implement user authentication** for the web application

### Current Security Measures:

- Read-only SELECT queries (INSERT, UPDATE, DELETE blocked)
- Azure SQL firewall rules
- Encrypted database connections
- Environment variable configuration
- Session-based agent instances

## 🐛 Troubleshooting

### ODBC Driver Not Found

**Error:** `[Microsoft][ODBC Driver Manager] Data source name not found`

**Solution:** Install ODBC Driver 18 for SQL Server (see Prerequisites section)

### Connection Timeout

**Error:** `Connection timeout`

**Solutions:**
- Check firewall rules in Azure Portal
- Verify your IP is whitelisted
- Ensure Azure services can access the server

### Azure OpenAI Rate Limits

**Error:** `Rate limit exceeded`

**Solutions:**
- Wait and retry
- Increase your Azure OpenAI quota
- Implement request throttling in the application

### Missing Environment Variables

**Error:** `Missing required environment variables`

**Solution:** Ensure all variables in `.env.template` are set in `.env`

## 📊 Demo Scenarios

### Scenario 1: Product Analysis
```
Q: "What are the most expensive products?"
Q: "Show me discontinued products"
Q: "How many products are there in each category?"
```

### Scenario 2: Customer Insights
```
Q: "How many customers are in each country?"
Q: "Show me customers from France"
Q: "Which customer has the most orders?"
```

### Scenario 3: Sales Analysis
```
Q: "What is the total revenue?"
Q: "Show me orders with freight cost over $50"
Q: "Which employee has the highest sales?"
```

## 🤝 Contributing

This is a demo application. For production use, consider:
- Adding comprehensive error handling
- Implementing user authentication
- Adding query result caching
- Supporting complex queries with JOIN operations
- Adding export functionality for results
- Implementing query history persistence

## 📝 License

This demo is provided as-is for educational and demonstration purposes.

## 🆘 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Azure SQL Database documentation
3. Check Azure OpenAI service status
4. Verify all environment variables are correctly set

## 🎓 Learning Resources

- [Azure OpenAI Service Documentation](https://learn.microsoft.com/en-us/azure/ai-services/openai/)
- [Azure SQL Database Documentation](https://learn.microsoft.com/en-us/azure/azure-sql/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Northwind Database Reference](https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/northwind-pubs)

---

**Built with ❤️ for customer demos**
