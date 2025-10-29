"""
Test script to debug agent routing
"""

import asyncio
from sql_agent import create_agent_from_env
from agents.sql_agent_wrapper import SQLAgentWrapper
from agents.orchestrator import create_orchestrator_from_env
from dotenv import load_dotenv

load_dotenv()

async def test_routing():
    """Test the orchestrator routing for different queries."""
    
    print("=" * 60)
    print("Testing Multi-Agent Orchestrator Routing")
    print("=" * 60)
    
    # Create agents
    sql_agent = create_agent_from_env()
    sql_agent_wrapper = SQLAgentWrapper(sql_agent)
    orchestrator = create_orchestrator_from_env(sql_agent_wrapper)
    
    # Test queries
    test_queries = [
        "Show me all products",
        "What products do we have?",
        "List all customers",
        "What's the capital of France?",
        "Tell me about Python programming"
    ]
    
    for query in test_queries:
        print(f"\n{'='*60}")
        print(f"Query: {query}")
        print(f"{'='*60}")
        
        result = await orchestrator.query(query)
        
        print(f"Agent Used: {result.get('agent_used', 'Unknown')}")
        print(f"Success: {result.get('success', False)}")
        print(f"Response Preview: {result.get('response', '')[:200]}...")
        
        if result.get('sql'):
            print(f"SQL Query: {result.get('sql')}")

if __name__ == "__main__":
    asyncio.run(test_routing())
