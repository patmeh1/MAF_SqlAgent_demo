"""
SQL Agent Wrapper for Microsoft Agent Framework
Wraps the existing SQLAgent as a specialized agent for database queries
"""

import asyncio
from typing import Dict, Any, List
from agent_framework import ChatMessage, Role
from sql_agent import SQLAgent


class SQLAgentWrapper:
    """Wrapper that adapts SQLAgent to work with Microsoft Agent Framework."""
    
    def __init__(self, sql_agent: SQLAgent):
        """
        Initialize the SQL Agent Wrapper.
        
        Args:
            sql_agent: Instance of the existing SQLAgent
        """
        self.sql_agent = sql_agent
        self.name = "SQLAgent"
        self.description = """Specialist in querying Azure SQL Database. 
        Use this agent when the user asks questions about:
        - Database records, tables, or data
        - Product information, orders, customers
        - Sales data, inventory, or business metrics
        - Any question that requires querying a database
        """
    
    async def process_query(self, question: str) -> Dict[str, Any]:
        """
        Process a database query asynchronously.
        
        Args:
            question: Natural language question about the database
            
        Returns:
            Dictionary containing query results and response
        """
        # Run synchronous SQLAgent.query in thread pool
        loop = asyncio.get_event_loop()
        result = await loop.run_in_executor(
            None, 
            self.sql_agent.query, 
            question
        )
        return result
    
    async def run(self, messages: List[ChatMessage]) -> List[ChatMessage]:
        """
        Run the SQL agent with the given conversation context.
        
        Args:
            messages: List of ChatMessage objects representing the conversation
            
        Returns:
            List of ChatMessage objects with the agent's response
        """
        # Extract the last user message
        user_messages = [msg for msg in messages if msg.role == Role.USER]
        if not user_messages:
            return [ChatMessage(
                role=Role.ASSISTANT,
                text="I need a question to query the database.",
                author_name=self.name
            )]
        
        last_question = user_messages[-1].text
        
        # Process the query
        result = await self.process_query(last_question)
        
        # Format response as ChatMessage
        if result['success']:
            response_text = f"{result['response']}\n\n"
            response_text += f"**SQL Query Executed:**\n```sql\n{result['sql']}\n```\n\n"
            
            if result['results']:
                response_text += f"**Results:** {result['row_count']} row(s) returned"
        else:
            response_text = f"Error processing database query: {result.get('error', 'Unknown error')}"
        
        return [ChatMessage(
            role=Role.ASSISTANT,
            text=response_text,
            author_name=self.name
        )]
    
    def get_schema_info(self) -> str:
        """Get database schema information."""
        return self.sql_agent.schema_info
    
    def clear_history(self):
        """Clear the agent's conversation history."""
        self.sql_agent.clear_history()
