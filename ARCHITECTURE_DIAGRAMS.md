# Architecture & Flow Diagrams

## System Architecture

```
╔═══════════════════════════════════════════════════════════════╗
║                        PRESENTATION LAYER                      ║
╠═══════════════════════════════════════════════════════════════╣
║                                                                ║
║   ┌────────────────────────────────────────────────────┐     ║
║   │         Web Browser (Chat Interface)                │     ║
║   │                                                      │     ║
║   │  • Natural language input                           │     ║
║   │  • Result visualization                             │     ║
║   │  • SQL query display                                │     ║
║   │  • Conversation history                             │     ║
║   └──────────────────┬─────────────────────────────────┘     ║
║                      │ HTTPS                                  ║
║                      ↓                                         ║
╠═══════════════════════════════════════════════════════════════╣
║                      APPLICATION LAYER                         ║
╠═══════════════════════════════════════════════════════════════╣
║                                                                ║
║   ┌────────────────────────────────────────────────────┐     ║
║   │           Flask Web Application                     │     ║
║   │                                                      │     ║
║   │  Routes:                                            │     ║
║   │  • POST /api/query    - Execute query              │     ║
║   │  • GET  /api/history  - Get history                │     ║
║   │  • POST /api/clear    - Clear history              │     ║
║   │  • GET  /api/health   - Health check               │     ║
║   └──────────────────┬─────────────────────────────────┘     ║
║                      │                                         ║
║                      ↓                                         ║
║   ┌────────────────────────────────────────────────────┐     ║
║   │              SQL Agent (Agent Framework)            │     ║
║   │                                                      │     ║
║   │  1. Receive natural language query                 │     ║
║   │  2. Get database schema context                    │     ║
║   │  3. Generate SQL using GPT-4o                      │     ║
║   │  4. Execute query safely (SELECT only)             │     ║
║   │  5. Format results                                 │     ║
║   │  6. Generate natural language response             │     ║
║   └──────────────────┬─────────────────────────────────┘     ║
║                      │                                         ║
╠═══════════════════════════════════════════════════════════════╣
║                      AI & DATA LAYERS                          ║
╠═══════════════════════════════════════════════════════════════╣
║                      │                                         ║
║        ┌─────────────┴──────────────┐                         ║
║        │                             │                         ║
║        ↓                             ↓                         ║
║  ┌──────────────┐            ┌──────────────┐                ║
║  │ Azure OpenAI │            │  Azure SQL   │                ║
║  │   (GPT-4o)   │            │   Database   │                ║
║  │              │            │              │                ║
║  │ Deployment:  │            │  Northwind   │                ║
║  │  NYP_demo    │            │   Database   │                ║
║  └──────────────┘            └──────────────┘                ║
║                                                                ║
╚═══════════════════════════════════════════════════════════════╝
```

## Query Flow Diagram

```
User Query: "Show me the top 5 most expensive products"
│
│ ① Natural Language Input
↓
┌─────────────────────────────────────────────────────────┐
│                    Flask Web Server                      │
│                  (Receives HTTP POST)                    │
└────────────────────────┬────────────────────────────────┘
                         │ ② Pass to Agent
                         ↓
┌─────────────────────────────────────────────────────────┐
│                      SQL Agent                           │
│                                                          │
│  Step 1: Get Database Schema                            │
│  ┌────────────────────────────────────────────┐        │
│  │ Tables: Categories, Products, Orders...    │        │
│  │ Columns: ProductID, ProductName, Price...  │        │
│  └────────────────────────────────────────────┘        │
│                         │                               │
│  Step 2: Build Prompt with Schema + User Question      │
│  ┌────────────────────────────────────────────┐        │
│  │ System: You are a SQL expert...            │        │
│  │ Schema: [Full database schema]             │        │
│  │ User: "Show top 5 expensive products"      │        │
│  └────────────────────────────────────────────┘        │
└────────────────────────┬────────────────────────────────┘
                         │ ③ Send to GPT-4o
                         ↓
┌─────────────────────────────────────────────────────────┐
│              Azure OpenAI (GPT-4o)                       │
│                                                          │
│  Analyzes:                                              │
│  • User intent: List products                           │
│  • Sorting: By price descending                         │
│  • Limit: Top 5                                         │
│                                                          │
│  Generates:                                             │
│  ┌────────────────────────────────────────────┐        │
│  │ SELECT TOP 5                                │        │
│  │   ProductName,                              │        │
│  │   UnitPrice                                 │        │
│  │ FROM Products                               │        │
│  │ ORDER BY UnitPrice DESC                     │        │
│  └────────────────────────────────────────────┘        │
└────────────────────────┬────────────────────────────────┘
                         │ ④ Return SQL
                         ↓
┌─────────────────────────────────────────────────────────┐
│                      SQL Agent                           │
│                                                          │
│  Validates Query (Safety Check)                         │
│  • Only SELECT allowed ✓                                │
│  • No DROP/DELETE/UPDATE ✓                             │
└────────────────────────┬────────────────────────────────┘
                         │ ⑤ Execute Query
                         ↓
┌─────────────────────────────────────────────────────────┐
│              Azure SQL Database                          │
│                                                          │
│  Executes Query on Northwind Database                   │
│  ┌────────────────────────────────────────────┐        │
│  │ ProductName         │ UnitPrice            │        │
│  │─────────────────────┼──────────────────────│        │
│  │ Mishi Kobe Niku     │ $97.00              │        │
│  │ Uncle Bob's Pears   │ $40.00              │        │
│  │ Northwoods Sauce    │ $30.00              │        │
│  │ Boysenberry Spread  │ $25.00              │        │
│  │ Cajun Seasoning     │ $22.00              │        │
│  └────────────────────────────────────────────┘        │
└────────────────────────┬────────────────────────────────┘
                         │ ⑥ Return Results
                         ↓
┌─────────────────────────────────────────────────────────┐
│                      SQL Agent                           │
│                                                          │
│  Step 3: Format Results + Generate NL Response         │
│  Sends to GPT-4o:                                       │
│  • Original question                                    │
│  • SQL executed                                         │
│  • Query results                                        │
└────────────────────────┬────────────────────────────────┘
                         │ ⑦ Get Natural Language Response
                         ↓
┌─────────────────────────────────────────────────────────┐
│              Azure OpenAI (GPT-4o)                       │
│                                                          │
│  Generates Response:                                    │
│  "Based on the data, the top 5 most expensive          │
│   products are led by Mishi Kobe Niku at $97.00..."   │
└────────────────────────┬────────────────────────────────┘
                         │ ⑧ Return Complete Response
                         ↓
┌─────────────────────────────────────────────────────────┐
│                    Flask Web Server                      │
│                                                          │
│  Packages Response:                                     │
│  {                                                      │
│    "sql": "SELECT TOP 5...",                           │
│    "results": [...],                                    │
│    "response": "The top 5 most...",                    │
│    "row_count": 5                                       │
│  }                                                      │
└────────────────────────┬────────────────────────────────┘
                         │ ⑨ Send JSON Response
                         ↓
┌─────────────────────────────────────────────────────────┐
│                    Web Browser                           │
│                                                          │
│  Displays:                                              │
│  ┌─────────────────────────────────────────────────┐  │
│  │ 🤖 Agent:                                        │  │
│  │                                                  │  │
│  │ The top 5 most expensive products are...        │  │
│  │                                                  │  │
│  │ SQL Query:                                       │  │
│  │ ┌────────────────────────────────────┐         │  │
│  │ │ SELECT TOP 5 ProductName,          │         │  │
│  │ │ UnitPrice FROM Products            │         │  │
│  │ │ ORDER BY UnitPrice DESC            │         │  │
│  │ └────────────────────────────────────┘         │  │
│  │                                                  │  │
│  │ Results:                                         │  │
│  │ ┌────────────────────────────────────┐         │  │
│  │ │ [Formatted Table with 5 products]  │         │  │
│  │ └────────────────────────────────────┘         │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Security Flow

```
┌──────────────────────────────────────────────────────────┐
│                    Security Layers                        │
└──────────────────────────────────────────────────────────┘

1. Network Security
   ┌─────────────────────────────────────────┐
   │  Azure SQL Firewall                     │
   │  • Allow Azure Services: ✓              │
   │  • Client IP Whitelist: ✓               │
   │  • Public Access: Restricted            │
   └─────────────────────────────────────────┘

2. Connection Security
   ┌─────────────────────────────────────────┐
   │  TLS/SSL Encryption                     │
   │  • Encrypt=yes                          │
   │  • TrustServerCertificate=no            │
   │  • ODBC Driver 18                       │
   └─────────────────────────────────────────┘

3. Authentication
   ┌─────────────────────────────────────────┐
   │  SQL Authentication                     │
   │  • Username: sqladmin                   │
   │  • Password: [Stored in .env]           │
   │  • Credentials: Environment variables   │
   └─────────────────────────────────────────┘

4. Query Safety
   ┌─────────────────────────────────────────┐
   │  SQL Agent Validation                   │
   │  • SELECT queries only                  │
   │  • No INSERT/UPDATE/DELETE              │
   │  • No DROP/ALTER                        │
   │  • Parameterized queries                │
   └─────────────────────────────────────────┘

5. Session Isolation
   ┌─────────────────────────────────────────┐
   │  Flask Session Management               │
   │  • Unique session per user              │
   │  • Separate agent instances             │
   │  • No cross-session data leakage        │
   └─────────────────────────────────────────┘
```

## Data Flow Diagram

```
┌─────────────┐
│    User     │ Types: "Show customers in France"
└──────┬──────┘
       │
       ↓ HTTP POST
┌─────────────┐
│   Flask     │ Receives request
└──────┬──────┘
       │
       ↓ Python call
┌─────────────┐
│  SQL Agent  │ Processes query
└──────┬──────┘
       │
       ├──────→ [Step 1: Get Schema]
       │          ↓
       │       ┌─────────────┐
       │       │  Azure SQL  │ Returns schema
       │       └──────┬──────┘
       │              ↓
       ←──────────────┘
       │
       ├──────→ [Step 2: Generate SQL]
       │          ↓
       │       ┌─────────────┐
       │       │ GPT-4o API  │ Returns SQL
       │       └──────┬──────┘
       │              ↓
       ←──────────────┘
       │
       ├──────→ [Step 3: Execute]
       │          ↓
       │       ┌─────────────┐
       │       │  Azure SQL  │ Returns data
       │       └──────┬──────┘
       │              ↓
       ←──────────────┘
       │
       ├──────→ [Step 4: Format Response]
       │          ↓
       │       ┌─────────────┐
       │       │ GPT-4o API  │ Returns text
       │       └──────┬──────┘
       │              ↓
       ←──────────────┘
       │
       ↓ JSON response
┌─────────────┐
│   Browser   │ Displays results
└─────────────┘
```

## Component Interaction

```
┌─────────────────────────────────────────────────────────┐
│                    Component Map                         │
└─────────────────────────────────────────────────────────┘

app.py (Flask Application)
├── Routes
│   ├── / → index.html
│   ├── /api/query → query()
│   ├── /api/history → get_history()
│   ├── /api/clear → clear_history()
│   └── /api/health → health_check()
│
└── Uses: sql_agent.py

sql_agent.py (Agent Implementation)
├── SQLAgent Class
│   ├── __init__() → Connect to Azure OpenAI & SQL
│   ├── _get_database_schema() → Read SQL schema
│   ├── _generate_sql_query() → Call GPT-4o
│   ├── _execute_query() → Run SQL
│   ├── _format_results_for_llm() → Prepare data
│   ├── _generate_natural_language_response() → Call GPT-4o
│   └── query() → Main orchestration
│
└── Uses: openai, pyodbc

index.html (Frontend)
├── UI Components
│   ├── Header
│   ├── Chat Container
│   ├── Message Display
│   ├── Results Table
│   ├── Input Field
│   └── Buttons
│
└── JavaScript Functions
    ├── sendMessage() → POST to /api/query
    ├── formatResults() → Display data
    ├── clearHistory() → POST to /api/clear
    └── askQuestion() → Helper for samples

Azure Resources
├── Resource Group: NYP_sql_agent
├── SQL Server
│   ├── Database: Northwind
│   └── Firewall Rules
├── AI Foundry Project: NYP_AIFoundry
│   └── Deployment: NYP_demo (GPT-4o)
├── Storage Account
└── Key Vault
```

---

**Use these diagrams in your customer presentations!**

Copy and paste them into documents, or draw them on a whiteboard during technical discussions.
