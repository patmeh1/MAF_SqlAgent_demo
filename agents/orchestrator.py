"""
Multi-Agent Orchestrator using Microsoft Agent Framework
Routes queries to specialized agents based on intent
"""

import asyncio
from typing import Dict, Any, List, Optional
from enum import Enum
from agent_framework import ChatMessage, Role, ChatAgent
from agent_framework.azure import AzureOpenAIChatClient
from .sql_agent_wrapper import SQLAgentWrapper
from .general_agent import GeneralAgent
import json


class AgentType(Enum):
    """Types of agents available in the system."""
    SQL = "sql"
    GENERAL = "general"
    UNKNOWN = "unknown"


class MultiAgentOrchestrator:
    """
    Orchestrator that manages multiple specialized agents.
    Uses a planner agent to route queries to the appropriate specialist.
    """
    
    def __init__(
        self,
        sql_agent: SQLAgentWrapper,
        general_agent: GeneralAgent,
        azure_openai_endpoint: str = None,
        azure_openai_api_key: str = None,
        azure_openai_deployment: str = None
    ):
        """
        Initialize the Multi-Agent Orchestrator.
        
        Args:
            sql_agent: SQL specialized agent for database queries
            general_agent: General agent for non-database queries
            azure_openai_endpoint: Azure OpenAI endpoint
            azure_openai_api_key: Azure OpenAI API key
            azure_openai_deployment: Azure OpenAI deployment name
        """
        self.sql_agent = sql_agent
        self.general_agent = general_agent
        
        # Initialize the planner/router agent using Azure OpenAI
        # Extract the base endpoint (remove everything after and including /openai/)
        endpoint = azure_openai_endpoint
        if endpoint and '/openai/' in endpoint:
            endpoint = endpoint.split('/openai/')[0]
        
        self.planner_client = AzureOpenAIChatClient(
            endpoint=endpoint,
            deployment_name=azure_openai_deployment or "gpt-4o",
            api_key=azure_openai_api_key
        )
        
        self.conversation_history: List[Dict[str, Any]] = []
        
    async def _route_query(self, user_question: str, conversation_context: List[ChatMessage]) -> AgentType:
        """
        Determine which agent should handle the query.
        
        Args:
            user_question: The user's question
            conversation_context: Previous conversation messages
            
        Returns:
            AgentType indicating which agent should handle the query
        """
        # Build context from recent conversation
        recent_context = ""
        if conversation_context:
            recent_msgs = conversation_context[-4:]  # Last 4 messages
            recent_context = "\n".join([
                f"{msg.role.value}: {msg.text[:200]}"  # Limit length
                for msg in recent_msgs
            ])
        
        system_prompt = f"""You are an intelligent query router for a multi-agent system. 
Your job is to analyze the user's question and determine which specialized agent should handle it.

Available agents:
1. SQL Agent - Handles database queries about:
   - Product information, orders, customers
   - Sales data, inventory, business metrics
   - Any question requiring database access
   - Tables in the database: Products, Orders, Customers, Categories, Suppliers, etc.

2. General Agent - Handles everything else:
   - General knowledge questions
   - Web searches and current information
   - Conversations and explanations
   - Document analysis
   - Questions not related to the database

Analyze the user's question and respond with ONLY a JSON object in this format:
{{
    "agent": "sql" or "general",
    "confidence": 0.0 to 1.0,
    "reasoning": "brief explanation of your choice"
}}

Recent conversation context:
{recent_context if recent_context else "No previous context"}

Database schema information:
{self.sql_agent.get_schema_info()[:500]}...
"""
        
        user_prompt = f"User question: {user_question}\n\nWhich agent should handle this?"
        
        try:
            # Use the planner to route
            response = await self.planner_client.get_response(
                messages=[
                    ChatMessage(role=Role.SYSTEM, text=system_prompt),
                    ChatMessage(role=Role.USER, text=user_prompt)
                ],
                temperature=0.1,
                json_output=True
            )
            
            # Parse response - get_response returns a ChatResponse object
            # Use the text attribute which contains the response content
            content = response.text
            if isinstance(content, str):
                result = json.loads(content)
            else:
                result = content
                
            agent_choice = result.get("agent", "general").lower()
            
            print(f"🎯 Router Decision: {agent_choice} (confidence: {result.get('confidence', 0.0):.2f})")
            print(f"   Reasoning: {result.get('reasoning', 'N/A')}")
            
            if agent_choice == "sql":
                return AgentType.SQL
            elif agent_choice == "general":
                return AgentType.GENERAL
            else:
                return AgentType.GENERAL  # Default to general
                
        except Exception as e:
            print(f"⚠️  Routing error: {e}, defaulting to General Agent")
            return AgentType.GENERAL
    
    async def query(self, user_question: str, conversation_context: Optional[List[ChatMessage]] = None) -> Dict[str, Any]:
        """
        Process a user query using the appropriate agent.
        
        Args:
            user_question: The user's question
            conversation_context: Optional previous conversation messages
            
        Returns:
            Dictionary containing the response and metadata
        """
        if conversation_context is None:
            conversation_context = []
        
        # Step 1: Route to appropriate agent
        agent_type = await self._route_query(user_question, conversation_context)
        
        # Step 2: Process with selected agent
        try:
            if agent_type == AgentType.SQL:
                print(f"📊 Routing to SQL Agent")
                result = await self.sql_agent.process_query(user_question)
                result['agent_used'] = 'SQL Agent'
                result['agent_type'] = 'sql'
                
            else:  # AgentType.GENERAL
                print(f"🌐 Routing to General Agent")
                result = await self.general_agent.process_query(user_question)
                result['agent_used'] = 'General Agent'
                result['agent_type'] = 'general'
            
            # Add to conversation history
            self.conversation_history.append({
                'question': user_question,
                'agent': result['agent_used'],
                'response': result.get('response', ''),
                'success': result.get('success', True)
            })
            
            return result
            
        except Exception as e:
            error_msg = f"Error processing query: {str(e)}"
            print(f"❌ {error_msg}")
            return {
                'success': False,
                'question': user_question,
                'response': error_msg,
                'error': str(e),
                'agent_used': 'None (Error)',
                'agent_type': 'error'
            }
    
    async def query_with_agent_choice(
        self, 
        user_question: str, 
        agent_type: str,
        conversation_context: Optional[List[ChatMessage]] = None
    ) -> Dict[str, Any]:
        """
        Process a query with a specific agent (bypassing routing).
        
        Args:
            user_question: The user's question
            agent_type: 'sql' or 'general' to force a specific agent
            conversation_context: Optional previous conversation messages
            
        Returns:
            Dictionary containing the response and metadata
        """
        try:
            if agent_type.lower() == 'sql':
                print(f"📊 Forced routing to SQL Agent")
                result = await self.sql_agent.process_query(user_question)
                result['agent_used'] = 'SQL Agent (Forced)'
                result['agent_type'] = 'sql'
            else:
                print(f"🌐 Forced routing to General Agent")
                result = await self.general_agent.process_query(user_question)
                result['agent_used'] = 'General Agent (Forced)'
                result['agent_type'] = 'general'
            
            self.conversation_history.append({
                'question': user_question,
                'agent': result['agent_used'],
                'response': result.get('response', ''),
                'success': result.get('success', True)
            })
            
            return result
            
        except Exception as e:
            error_msg = f"Error processing query with {agent_type} agent: {str(e)}"
            print(f"❌ {error_msg}")
            return {
                'success': False,
                'question': user_question,
                'response': error_msg,
                'error': str(e),
                'agent_used': f'{agent_type} Agent (Error)',
                'agent_type': 'error'
            }
    
    def get_conversation_history(self) -> List[Dict[str, Any]]:
        """Get the conversation history."""
        return self.conversation_history
    
    def clear_history(self):
        """Clear conversation history for all agents."""
        self.conversation_history = []
        self.sql_agent.clear_history()
        self.general_agent.clear_history()
    
    def get_available_agents(self) -> Dict[str, str]:
        """Get information about available agents."""
        return {
            'sql': self.sql_agent.description,
            'general': self.general_agent.description
        }


def create_orchestrator_from_env(sql_agent: SQLAgentWrapper) -> MultiAgentOrchestrator:
    """
    Create a MultiAgentOrchestrator from environment variables.
    
    Args:
        sql_agent: Initialized SQLAgentWrapper instance
        
    Returns:
        MultiAgentOrchestrator instance
    """
    import os
    
    # Create general agent
    general_agent = GeneralAgent(
        azure_openai_endpoint=os.getenv('AZURE_OPENAI_ENDPOINT'),
        azure_openai_api_key=os.getenv('AZURE_OPENAI_API_KEY'),
        azure_openai_deployment=os.getenv('AZURE_OPENAI_DEPLOYMENT')
    )
    
    # Create orchestrator
    orchestrator = MultiAgentOrchestrator(
        sql_agent=sql_agent,
        general_agent=general_agent,
        azure_openai_endpoint=os.getenv('AZURE_OPENAI_ENDPOINT'),
        azure_openai_api_key=os.getenv('AZURE_OPENAI_API_KEY'),
        azure_openai_deployment=os.getenv('AZURE_OPENAI_DEPLOYMENT')
    )
    
    return orchestrator
