"""
Test script for Multi-Agent System
Demonstrates routing between SQL and General agents
"""

import asyncio
import os
from dotenv import load_dotenv
from sql_agent import create_agent_from_env
from agents.sql_agent_wrapper import SQLAgentWrapper
from agents.orchestrator import create_orchestrator_from_env

# Load environment variables
load_dotenv()


async def test_multi_agent_system():
    """Test the multi-agent orchestrator with various queries."""
    
    print("=" * 70)
    print("Multi-Agent System Test")
    print("=" * 70)
    print()
    
    # Initialize the system
    print("🔧 Initializing multi-agent system...")
    sql_agent = create_agent_from_env()
    sql_agent_wrapper = SQLAgentWrapper(sql_agent)
    orchestrator = create_orchestrator_from_env(sql_agent_wrapper)
    print("✅ System initialized!\n")
    
    # Test queries
    test_queries = [
        # SQL Agent queries
        ("Show me all products", "sql"),
        ("What are the top 5 most expensive products?", "sql"),
        ("How many customers do we have?", "sql"),
        
        # General Agent queries
        ("What is machine learning?", "general"),
        ("Explain the difference between AI and ML", "general"),
        ("Tell me about Microsoft Azure", "general"),
        
        # Mixed/ambiguous queries (let router decide)
        ("What makes a good database design?", "auto"),
        ("How should I analyze sales data?", "auto"),
    ]
    
    for i, (query, expected_agent) in enumerate(test_queries, 1):
        print("-" * 70)
        print(f"Test {i}/{len(test_queries)}")
        print(f"Query: {query}")
        print(f"Expected Agent: {expected_agent}")
        print()
        
        try:
            result = await orchestrator.query(query)
            
            print(f"✅ Success: {result['success']}")
            print(f"🤖 Agent Used: {result.get('agent_used', 'Unknown')}")
            print(f"📝 Response: {result['response'][:200]}...")
            
            if 'sql' in result:
                print(f"💾 SQL: {result['sql'][:100]}...")
            
            print()
            
        except Exception as e:
            print(f"❌ Error: {e}")
            print()
    
    print("=" * 70)
    print("Test Complete!")
    print("=" * 70)
    
    # Show conversation history
    history = orchestrator.get_conversation_history()
    print(f"\n📚 Total queries processed: {len(history)}")
    
    sql_count = sum(1 for h in history if 'SQL' in h.get('agent', ''))
    general_count = len(history) - sql_count
    
    print(f"   - SQL Agent: {sql_count} queries")
    print(f"   - General Agent: {general_count} queries")


if __name__ == "__main__":
    print("\nStarting Multi-Agent System Test...\n")
    
    # Check if environment is configured
    required_vars = ['SQL_SERVER', 'SQL_DATABASE', 'AZURE_OPENAI_ENDPOINT', 
                     'AZURE_OPENAI_API_KEY', 'AZURE_OPENAI_DEPLOYMENT']
    
    missing = [var for var in required_vars if not os.getenv(var)]
    
    if missing:
        print("❌ Error: Missing required environment variables:")
        for var in missing:
            print(f"   - {var}")
        print("\nPlease configure your .env file before running this test.")
        exit(1)
    
    # Run the test
    asyncio.run(test_multi_agent_system())
