# Quick Start Guide - Multi-Agent System

## 🚀 Quick Setup (5 minutes)

### 1. Prerequisites Check
```bash
# Check Python version (3.9+ required)
python --version

# Check Azure CLI is installed
az --version

# Verify ODBC Driver 18 for SQL Server
odbcinst -j
```

### 2. Clone and Setup
```bash
# Navigate to the repository
cd MAF_SqlAgent_demo

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies (includes agent-framework)
pip install -r requirements.txt
```

### 3. Configure Environment
```bash
# Copy environment template
cp .env.template .env

# Edit .env with your Azure credentials
nano .env  # or use your favorite editor
```

Required variables:
```bash
SQL_SERVER=your-server.database.windows.net
SQL_DATABASE=Northwind
AZURE_OPENAI_ENDPOINT=https://your-endpoint.openai.azure.com/
AZURE_OPENAI_API_KEY=your-key
AZURE_OPENAI_DEPLOYMENT=gpt-4o
```

### 4. Run the Application
```bash
python app.py
```

Open browser: `http://localhost:5001`

## 💡 Quick Test

### Test Queries
Try these to see the multi-agent system in action:

**SQL Agent (Database Queries):**
```
Show me all products
What are the top 5 most expensive products?
How many customers do we have?
```

**General Agent (Knowledge/Conversation):**
```
What is machine learning?
Tell me about Microsoft Azure
Explain database normalization
```

**Mixed Conversation:**
```
1. Show me products under $20
2. What makes a good pricing strategy?
3. Calculate average product price
4. What are current market trends?
```

## 🧪 Test Script

Run the automated test:
```bash
python test_multi_agent.py
```

This validates:
- System initialization
- SQL agent routing
- General agent routing
- Mixed query handling

## 🔧 Common Commands

### Start Application
```bash
python app.py
```

### Run Tests
```bash
python test_multi_agent.py
```

### Check Dependencies
```bash
pip list | grep agent-framework
```

### Clear History
```bash
# Via API:
curl -X POST http://localhost:5001/api/clear
```

### Get Available Agents
```bash
# Via API:
curl http://localhost:5001/api/agents
```

## 📊 API Quick Reference

### Query with Auto-Routing
```bash
curl -X POST http://localhost:5001/api/query \
  -H "Content-Type: application/json" \
  -d '{"question": "Show me all products"}'
```

### Force Specific Agent
```bash
# Force SQL Agent
curl -X POST http://localhost:5001/api/query \
  -H "Content-Type: application/json" \
  -d '{"question": "Your question", "agent": "sql"}'

# Force General Agent
curl -X POST http://localhost:5001/api/query \
  -H "Content-Type: application/json" \
  -d '{"question": "Your question", "agent": "general"}'
```

### Get Agent Information
```bash
curl http://localhost:5001/api/agents
```

### Get Conversation History
```bash
curl http://localhost:5001/api/history
```

## 🏗️ Architecture at a Glance

```
User Query
    ↓
Orchestrator (Router/Planner)
    ↓
    ├── SQL Agent → Database
    └── General Agent → AI Response
```

### Files You'll Work With

**Main Application:**
- `app.py` - Flask web app with multi-agent endpoints

**Multi-Agent System:**
- `agents/orchestrator.py` - Routes queries to agents
- `agents/sql_agent_wrapper.py` - Database query specialist
- `agents/general_agent.py` - Knowledge/conversation specialist

**Original (Still Used):**
- `sql_agent.py` - Core SQL functionality

## 🎯 Key Concepts

### 1. Agent Types
- **SQL Agent**: Database queries only
- **General Agent**: Everything else
- **Orchestrator**: Decides which agent to use

### 2. Routing Logic
The orchestrator examines:
- Query content
- Conversation context
- Database schema
- Previous interactions

### 3. Response Format
```json
{
  "success": true,
  "agent_used": "SQL Agent",
  "agent_type": "sql",
  "response": "...",
  "sql": "SELECT ...",  // Only for SQL agent
  "results": [...],      // Only for SQL agent
  "timestamp": "..."
}
```

## 🔍 Debugging

### Enable Debug Logging
```python
# In app.py, last line:
app.run(host='0.0.0.0', port=5001, debug=True)
```

### Console Output
Watch for routing decisions:
```
🎯 Router Decision: sql (confidence: 0.95)
   Reasoning: Query requires database access
📊 Routing to SQL Agent
```

### Check Agent Status
```bash
curl http://localhost:5001/api/health
```

## 🐛 Troubleshooting

### "Module not found: agent_framework"
```bash
pip install agent-framework agent-framework-openai
```

### "Connection refused to database"
- Check SQL_SERVER in .env
- Verify firewall rules allow your IP
- Test with: `sqlcmd -S server -U user -P pass`

### "OpenAI API error"
- Verify AZURE_OPENAI_API_KEY in .env
- Check endpoint URL format
- Ensure deployment name is correct

### "Routing always goes to General Agent"
- Check if database schema loaded correctly
- Review orchestrator logs for routing reasoning
- Verify SQL agent wrapper initialization

## 📚 Further Reading

- **[MULTI_AGENT_ARCHITECTURE.md](MULTI_AGENT_ARCHITECTURE.md)** - Detailed architecture
- **[README.md](README.md)** - Full setup and usage guide
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Implementation details

## 🆘 Getting Help

1. Check the logs in terminal
2. Review error messages in browser console
3. Test with `test_multi_agent.py`
4. Verify environment variables
5. Check Azure resources are accessible

## 🎓 Learning Path

1. **Start Here**: Run the application and try sample queries
2. **Understand**: Read MULTI_AGENT_ARCHITECTURE.md
3. **Experiment**: Modify routing logic in orchestrator.py
4. **Extend**: Add a new specialized agent
5. **Customize**: Adjust agent instructions and behavior

## ⚡ Performance Tips

1. **Async Operations**: All agents use async/await
2. **Session Management**: Each user gets isolated orchestrator
3. **Caching**: Consider caching common queries
4. **Connection Pooling**: Database connections are managed efficiently
5. **Token Limits**: Adjust max_tokens for faster/cheaper responses

## 🎨 Customization Quick Wins

### Change Port
```python
# In app.py, last line:
app.run(host='0.0.0.0', port=8080, debug=True)
```

### Adjust Routing Confidence
```python
# In agents/orchestrator.py, _route_query():
temperature=0.1,  # Lower = more deterministic routing
```

### Add Sample Questions
```html
<!-- In templates/index.html -->
<li onclick="askQuestion('Your custom question')">
  • Your custom question
</li>
```

## 🚢 Deployment Checklist

- [ ] Set `debug=False` in app.py
- [ ] Use production WSGI server (gunicorn)
- [ ] Configure proper FLASK_SECRET_KEY
- [ ] Set up HTTPS
- [ ] Configure Azure App Service
- [ ] Set environment variables in production
- [ ] Enable application logging
- [ ] Set up monitoring and alerts

## 📊 Monitoring

Watch these metrics:
- Routing accuracy (SQL vs General)
- Query response times
- Agent error rates
- Session counts
- Popular query patterns

---

**Repository**: https://github.com/patmeh1/MAF_SqlAgent_demo
**Framework**: Microsoft Agent Framework
**Last Updated**: October 29, 2025
