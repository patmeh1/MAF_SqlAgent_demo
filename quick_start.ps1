# Quick Start Script for SQL Agent Demo (Windows PowerShell)

Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        SQL Agent Demo - Quick Start Guide                   ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if .env exists
if (-Not (Test-Path .env)) {
    Write-Host "⚠️  No .env file found!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Steps to get started:"
    Write-Host ""
    Write-Host "1️⃣  Set up Azure resources:"
    Write-Host "   cd scripts"
    Write-Host "   bash setup_azure_resources.sh"
    Write-Host "   (or use Azure Portal manually)"
    Write-Host ""
    Write-Host "2️⃣  Create AI Foundry project in Azure Portal:"
    Write-Host "   Visit: https://ai.azure.com"
    Write-Host "   - Create project: NYP_AIFoundry"
    Write-Host "   - Deploy GPT-4o model: NYP_demo"
    Write-Host ""
    Write-Host "3️⃣  Copy .env.template to .env and update with your credentials"
    Write-Host ""
    Write-Host "4️⃣  Run this script again: .\quick_start.ps1"
    Write-Host ""
    exit 1
}

Write-Host "✅ Found .env file" -ForegroundColor Green
Write-Host ""

# Check if virtual environment exists
if (-Not (Test-Path venv)) {
    Write-Host "📦 Creating virtual environment..." -ForegroundColor Yellow
    python -m venv venv
    Write-Host "✅ Virtual environment created" -ForegroundColor Green
    Write-Host ""
}

# Activate virtual environment
Write-Host "🔧 Activating virtual environment..." -ForegroundColor Yellow
& .\venv\Scripts\Activate.ps1

# Check if dependencies are installed
$flaskInstalled = python -c "import flask" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "📥 Installing dependencies..." -ForegroundColor Yellow
    pip install -r requirements.txt
    Write-Host "✅ Dependencies installed" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "✅ Dependencies already installed" -ForegroundColor Green
    Write-Host ""
}

# Check database connection
Write-Host "🔍 Checking database connection..." -ForegroundColor Yellow
$dbCheck = python -c "from dotenv import load_dotenv; import os; load_dotenv(); import pyodbc; conn = pyodbc.connect(f'Driver={{ODBC Driver 18 for SQL Server}};Server=tcp:{os.getenv(''SQL_SERVER'')},1433;Database={os.getenv(''SQL_DATABASE'')};Uid={os.getenv(''SQL_USERNAME'')};Pwd={os.getenv(''SQL_PASSWORD'')};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;'); cursor = conn.cursor(); cursor.execute('SELECT COUNT(*) FROM Categories'); print('OK' if cursor.fetchone()[0] > 0 else 'EMPTY'); conn.close()" 2>$null

if ($dbCheck -match "OK") {
    Write-Host "✅ Database is loaded and accessible" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "⚠️  Database appears to be empty or inaccessible" -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "Would you like to load the Northwind database now? (y/n)"
    if ($response -match "^[Yy]$") {
        Write-Host "📊 Loading Northwind database..." -ForegroundColor Yellow
        python scripts\load_database.py
        Write-Host ""
    }
}

Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    Ready to Start!                           ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 Starting the application..." -ForegroundColor Green
Write-Host ""
Write-Host "   Access the demo at: http://localhost:5000" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Press CTRL+C to stop the server" -ForegroundColor Yellow
Write-Host ""
Write-Host "══════════════════════════════════════════════════════════════"
Write-Host ""

# Start the application
python app.py
