# Multi-Agent System Architecture

## Overview

This application has been enhanced with the **Microsoft Agent Framework** to create an intelligent multi-agent system. Instead of just answering SQL queries, the system can now handle a variety of tasks including database queries, general knowledge questions, web searches, and conversations.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     User Interface                          │
│                  (Flask Web Application)                    │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              Multi-Agent Orchestrator                       │
│         (Intelligent Query Router/Planner)                  │
│  • Analyzes user intent                                     │
│  • Routes to appropriate specialized agent                  │
│  • Manages conversation context                             │
└─────────────┬───────────────────────┬───────────────────────┘
              │                       │
              ▼                       ▼
┌─────────────────────────┐   ┌─────────────────────────┐
│     SQL Agent           │   │   General Agent         │
│  (Database Queries)     │   │  (Knowledge & Search)   │
│                         │   │                         │
│  • Natural language     │   │  • General questions    │
│    to SQL translation   │   │  • Web information      │
│  • Query execution      │   │  • Conversations        │
│  • Result formatting    │   │  • Document analysis    │
│  • Schema awareness     │   │  • Non-DB queries       │
└───────────┬─────────────┘   └─────────────────────────┘
            │
            ▼
┌─────────────────────────┐
│   Azure SQL Database    │
│  (Northwind Database)   │
└─────────────────────────┘
```

## Components

### 1. Multi-Agent Orchestrator (`agents/orchestrator.py`)

The orchestrator is the brain of the system. It:
- **Analyzes user queries** to understand intent
- **Routes queries** to the appropriate specialized agent
- **Maintains context** across conversations
- **Handles errors** gracefully

**Key Features:**
- Intelligent routing using GPT-4o
- Confidence scoring for routing decisions
- Support for forced agent selection
- Conversation history management

### 2. SQL Agent (`agents/sql_agent_wrapper.py`)

Specialized agent for database operations:
- Converts natural language to SQL queries
- Executes queries on Azure SQL Database
- Returns formatted results
- Provides query explanations

**Use Cases:**
- "Show me all products"
- "What are the top 5 selling products?"
- "List customers from London"
- "Calculate total revenue by category"

### 3. General Agent (`agents/general_agent.py`)

Handles non-database queries:
- General knowledge questions
- Web searches and current information
- Conversations and explanations
- Document analysis

**Use Cases:**
- "What is machine learning?"
- "Tell me about the weather"
- "Explain quantum computing"
- "Who won the last World Cup?"

## How It Works

### Query Processing Flow

1. **User submits a question** via the web interface
2. **Orchestrator receives the query** and analyzes it
3. **Router/Planner agent** determines the best agent:
   - Examines query content
   - Considers conversation context
   - Reviews database schema information
   - Makes a routing decision with confidence score
4. **Selected agent processes the query**:
   - SQL Agent: Generates and executes SQL
   - General Agent: Uses AI to provide information
5. **Response is formatted and returned** to the user
6. **Conversation history is updated** for context

### Example Routing Decisions

| User Query | Agent Selected | Reasoning |
|------------|---------------|-----------|
| "Show me all products" | SQL Agent | Directly queries database tables |
| "What is AI?" | General Agent | General knowledge question |
| "Top 5 customers by orders" | SQL Agent | Requires database aggregation |
| "Tell me a joke" | General Agent | Conversational, no data needed |
| "Products under $20" | SQL Agent | Database filtering query |
| "Current weather in Seattle" | General Agent | External information |

## Technical Implementation

### Agent Framework Integration

The application uses the **Microsoft Agent Framework** which provides:
- **ChatAgent**: Base agent class with conversational capabilities
- **OpenAIChatClient**: Integration with Azure OpenAI
- **ChatMessage**: Standard message format across agents
- **Async/await support**: Efficient concurrent operations

### Key Technologies

- **Microsoft Agent Framework**: Multi-agent orchestration
- **Azure OpenAI (GPT-4o)**: Language understanding and generation
- **Azure SQL Database**: Data storage
- **Flask**: Web application framework
- **Python asyncio**: Asynchronous processing

## API Endpoints

### `/api/query` (POST)
Process a user query with automatic agent routing.

**Request:**
```json
{
  "question": "What are the top selling products?",
  "agent": "sql"  // Optional: force specific agent
}
```

**Response:**
```json
{
  "success": true,
  "question": "What are the top selling products?",
  "response": "Based on the query results...",
  "agent_used": "SQL Agent",
  "agent_type": "sql",
  "sql": "SELECT TOP 5...",
  "results": [...],
  "timestamp": "2024-10-29T..."
}
```

### `/api/agents` (GET)
Get information about available agents.

**Response:**
```json
{
  "success": true,
  "agents": {
    "sql": "Specialist in querying Azure SQL Database...",
    "general": "General knowledge assistant..."
  }
}
```

### `/api/history` (GET)
Retrieve conversation history for the session.

### `/api/clear` (POST)
Clear conversation history and reset agents.

## Benefits of Multi-Agent Architecture

### 1. **Flexibility**
- Handle diverse query types
- Not limited to database queries
- Extensible to new agent types

### 2. **Intelligence**
- Automatic query classification
- Context-aware routing
- Optimized agent selection

### 3. **Scalability**
- Easy to add new specialized agents
- Independent agent development
- Modular architecture

### 4. **User Experience**
- Natural conversation flow
- Mixed query types in one session
- Transparent agent selection

## Adding New Agents

To extend the system with a new specialized agent:

1. **Create a new agent class** in `agents/`:
```python
class DocumentAgent:
    def __init__(self, ...):
        self.name = "DocumentAgent"
        self.description = "Analyzes documents..."
    
    async def run(self, messages):
        # Agent logic
        return response_messages
```

2. **Update the orchestrator** to include the new agent:
```python
self.document_agent = DocumentAgent(...)
```

3. **Add routing logic** in `_route_query()`:
```python
# Add to agent descriptions
# Update routing decision logic
```

4. **Update API and UI** to support the new agent type.

## Configuration

All agents are configured via environment variables in `.env`:

```bash
# Azure OpenAI (used by all agents)
AZURE_OPENAI_ENDPOINT=https://your-endpoint.openai.azure.com/
AZURE_OPENAI_API_KEY=your-api-key
AZURE_OPENAI_DEPLOYMENT=gpt-4o

# SQL Database (used by SQL Agent)
SQL_SERVER=your-server.database.windows.net
SQL_DATABASE=Northwind
SQL_AUTH_TYPE=azure_ad  # or 'sql'

# Optional: SQL Authentication
SQL_USERNAME=sqladmin
SQL_PASSWORD=your-password
```

## Best Practices

1. **Query Clarity**: Be specific in your questions for better routing
2. **Context Matters**: The orchestrator uses conversation history
3. **Agent Selection**: You can force a specific agent if needed
4. **Error Handling**: The system gracefully handles routing errors
5. **Performance**: Async operations ensure responsive experience

## Future Enhancements

Possible extensions to the multi-agent system:
- **Document Agent**: PDF and document analysis
- **Image Agent**: Image understanding and generation
- **Code Agent**: Code analysis and generation
- **Research Agent**: Deep web research with source citations
- **Analytics Agent**: Advanced data visualization
- **Email Agent**: Email composition and management

## Monitoring and Debugging

The orchestrator provides console logging:
```
🎯 Router Decision: sql (confidence: 0.95)
   Reasoning: Query requires database access for product information
📊 Routing to SQL Agent
```

Emoji indicators:
- 🎯 Routing decision
- 📊 SQL Agent
- 🌐 General Agent
- ⚠️  Warning/fallback
- ❌ Error

## Conclusion

The multi-agent architecture transforms a simple SQL query tool into an intelligent assistant capable of handling diverse tasks. By leveraging the Microsoft Agent Framework, the system provides:
- Smart query routing
- Multiple specialized capabilities
- Seamless user experience
- Extensible architecture

This makes it ideal for enterprise applications where users need both structured data access and general assistance in one unified interface.
