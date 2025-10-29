"""
Flask Web Application for SQL Agent Demo
Provides a chat interface to query SQL database using natural language.
"""

from flask import Flask, render_template, request, jsonify, session
from dotenv import load_dotenv
import os
import secrets
from sql_agent import create_agent_from_env
from datetime import datetime

# Load environment variables
load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv('FLASK_SECRET_KEY', secrets.token_hex(32))

# Store agent instances per session
agents = {}


def get_agent_for_session():
    """Get or create an agent instance for the current session."""
    session_id = session.get('session_id')
    
    if not session_id:
        session_id = secrets.token_hex(16)
        session['session_id'] = session_id
    
    if session_id not in agents:
        try:
            agents[session_id] = create_agent_from_env()
        except Exception as e:
            print(f"Error creating agent: {e}")
            return None
    
    return agents[session_id]


@app.route('/')
def index():
    """Render the main chat interface."""
    return render_template('index.html')


@app.route('/api/query', methods=['POST'])
def query():
    """Handle natural language queries from the frontend."""
    try:
        data = request.get_json()
        user_question = data.get('question', '').strip()
        
        if not user_question:
            return jsonify({
                'success': False,
                'error': 'Please provide a question.'
            }), 400
        
        # Get agent for this session
        agent = get_agent_for_session()
        if not agent:
            return jsonify({
                'success': False,
                'error': 'Failed to initialize SQL agent. Check your configuration.'
            }), 500
        
        # Process the query
        result = agent.query(user_question)
        
        # Format response
        response = {
            'success': result['success'],
            'question': result['question'],
            'response': result['response'],
            'sql': result['sql'],
            'explanation': result['explanation'],
            'results': result['results'],
            'row_count': result.get('row_count', 0),
            'timestamp': datetime.now().isoformat()
        }
        
        if not result['success']:
            response['error'] = result.get('error', 'Unknown error occurred')
        
        return jsonify(response)
    
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Server error: {str(e)}'
        }), 500


@app.route('/api/history', methods=['GET'])
def get_history():
    """Get conversation history for the current session."""
    try:
        agent = get_agent_for_session()
        if not agent:
            return jsonify({
                'success': False,
                'error': 'No active session'
            }), 404
        
        history = agent.get_conversation_history()
        return jsonify({
            'success': True,
            'history': history
        })
    
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Error retrieving history: {str(e)}'
        }), 500


@app.route('/api/clear', methods=['POST'])
def clear_history():
    """Clear conversation history for the current session."""
    try:
        agent = get_agent_for_session()
        if agent:
            agent.clear_history()
        
        return jsonify({
            'success': True,
            'message': 'History cleared'
        })
    
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Error clearing history: {str(e)}'
        }), 500


@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat()
    })


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors."""
    return jsonify({
        'success': False,
        'error': 'Endpoint not found'
    }), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors."""
    return jsonify({
        'success': False,
        'error': 'Internal server error'
    }), 500


if __name__ == '__main__':
    # Validate required environment variables
    required_vars = [
        'SQL_SERVER',
        'SQL_DATABASE',
        'SQL_USERNAME',
        'SQL_PASSWORD',
        'AZURE_OPENAI_ENDPOINT',
        'AZURE_OPENAI_API_KEY',
        'AZURE_OPENAI_DEPLOYMENT'
    ]
    
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    
    if missing_vars:
        print("ERROR: Missing required environment variables:")
        for var in missing_vars:
            print(f"  - {var}")
        print("\nPlease update your .env file with the required values.")
        exit(1)
    
    print("=" * 60)
    print("SQL Agent Demo - Web Application")
    print("=" * 60)
    print(f"SQL Server: {os.getenv('SQL_SERVER')}")
    print(f"SQL Database: {os.getenv('SQL_DATABASE')}")
    print(f"Azure OpenAI Deployment: {os.getenv('AZURE_OPENAI_DEPLOYMENT')}")
    print("=" * 60)
    print("\nStarting Flask application...")
    print("Access the application at: http://localhost:5000")
    print("\nPress CTRL+C to stop the server.")
    print("=" * 60)
    
    app.run(debug=True, host='0.0.0.0', port=5000)
