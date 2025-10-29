#!/bin/bash

# Quick Start Script for SQL Agent Demo
# This script helps you get started quickly

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        SQL Agent Demo - Quick Start Guide                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  No .env file found!"
    echo ""
    echo "Steps to get started:"
    echo ""
    echo "1️⃣  Set up Azure resources:"
    echo "   cd scripts"
    echo "   chmod +x setup_azure_resources.sh"
    echo "   ./setup_azure_resources.sh"
    echo ""
    echo "2️⃣  Create AI Foundry project in Azure Portal:"
    echo "   Visit: https://ai.azure.com"
    echo "   - Create project: NYP_AIFoundry"
    echo "   - Deploy GPT-4o model: NYP_demo"
    echo ""
    echo "3️⃣  Update .env file with Azure OpenAI credentials"
    echo ""
    echo "4️⃣  Run this script again: ./quick_start.sh"
    echo ""
    exit 1
fi

echo "✅ Found .env file"
echo ""

# Check if virtual environment exists
if [ ! -d venv ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
    echo "✅ Virtual environment created"
    echo ""
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Check if dependencies are installed
if ! python -c "import flask" 2>/dev/null; then
    echo "📥 Installing dependencies..."
    pip install -r requirements.txt
    echo "✅ Dependencies installed"
    echo ""
else
    echo "✅ Dependencies already installed"
    echo ""
fi

# Check if database is loaded
echo "🔍 Checking database connection..."
if python -c "from dotenv import load_dotenv; import os; load_dotenv(); import pyodbc; conn = pyodbc.connect(f\"Driver={{ODBC Driver 18 for SQL Server}};Server=tcp:{os.getenv('SQL_SERVER')},1433;Database={os.getenv('SQL_DATABASE')};Uid={os.getenv('SQL_USERNAME')};Pwd={os.getenv('SQL_PASSWORD')};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;\"); cursor = conn.cursor(); cursor.execute('SELECT COUNT(*) FROM Categories'); print('OK' if cursor.fetchone()[0] > 0 else 'EMPTY'); conn.close()" 2>/dev/null | grep -q "OK"; then
    echo "✅ Database is loaded and accessible"
    echo ""
else
    echo "⚠️  Database appears to be empty or inaccessible"
    echo ""
    echo "Would you like to load the Northwind database now? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "📊 Loading Northwind database..."
        python scripts/load_database.py
        echo ""
    fi
fi

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    Ready to Start!                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "🚀 Starting the application..."
echo ""
echo "   Access the demo at: http://localhost:5000"
echo ""
echo "   Press CTRL+C to stop the server"
echo ""
echo "══════════════════════════════════════════════════════════════"
echo ""

# Start the application
python app.py
