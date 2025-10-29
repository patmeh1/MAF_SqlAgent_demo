#!/usr/bin/env python3
"""
Script to load Northwind database into Azure SQL Database
Alternative to using sqlcmd for users who don't have it installed
"""

import os
import pyodbc
from dotenv import load_dotenv

def load_northwind_database():
    """Load the Northwind database schema and data."""
    
    # Load environment variables
    load_dotenv()
    
    # Get connection details
    sql_server = os.getenv('SQL_SERVER')
    sql_database = os.getenv('SQL_DATABASE')
    sql_username = os.getenv('SQL_USERNAME')
    sql_password = os.getenv('SQL_PASSWORD')
    
    if not all([sql_server, sql_database, sql_username, sql_password]):
        print("❌ Error: Missing required environment variables in .env file")
        print("Please ensure SQL_SERVER, SQL_DATABASE, SQL_USERNAME, and SQL_PASSWORD are set.")
        return False
    
    # Connection string
    connection_string = (
        f"Driver={{ODBC Driver 18 for SQL Server}};"
        f"Server=tcp:{sql_server},1433;"
        f"Database={sql_database};"
        f"Uid={sql_username};"
        f"Pwd={sql_password};"
        f"Encrypt=yes;"
        f"TrustServerCertificate=no;"
        f"Connection Timeout=30;"
    )
    
    print("=" * 60)
    print("Northwind Database Loader")
    print("=" * 60)
    print(f"Server: {sql_server}")
    print(f"Database: {sql_database}")
    print(f"Username: {sql_username}")
    print("=" * 60)
    print()
    
    # Read SQL file
    sql_file_path = os.path.join(os.path.dirname(__file__), '..', 'database', 'northwind.sql')
    
    if not os.path.exists(sql_file_path):
        print(f"❌ Error: SQL file not found at {sql_file_path}")
        return False
    
    print("📖 Reading SQL file...")
    with open(sql_file_path, 'r') as f:
        sql_content = f.read()
    
    # Split into individual statements
    statements = [s.strip() for s in sql_content.split('GO') if s.strip()]
    
    print(f"✅ Found {len(statements)} SQL statements")
    print()
    
    try:
        print("🔌 Connecting to Azure SQL Database...")
        conn = pyodbc.connect(connection_string)
        cursor = conn.cursor()
        print("✅ Connected successfully!")
        print()
        
        # Execute each statement
        for i, statement in enumerate(statements, 1):
            try:
                print(f"⚙️  Executing statement {i}/{len(statements)}...", end='')
                cursor.execute(statement)
                conn.commit()
                print(" ✅")
            except Exception as e:
                print(f" ⚠️  Warning: {str(e)}")
                # Continue with next statement
                continue
        
        print()
        print("=" * 60)
        print("✅ Northwind database loaded successfully!")
        print("=" * 60)
        print()
        
        # Verify data was loaded
        print("🔍 Verifying data...")
        verification_queries = [
            ("Categories", "SELECT COUNT(*) FROM Categories"),
            ("Customers", "SELECT COUNT(*) FROM Customers"),
            ("Employees", "SELECT COUNT(*) FROM Employees"),
            ("Products", "SELECT COUNT(*) FROM Products"),
            ("Orders", "SELECT COUNT(*) FROM Orders"),
        ]
        
        print()
        for table_name, query in verification_queries:
            cursor.execute(query)
            count = cursor.fetchone()[0]
            print(f"  {table_name}: {count} rows")
        
        cursor.close()
        conn.close()
        
        print()
        print("=" * 60)
        print("🎉 Setup complete! You can now run the application.")
        print("   Run: python app.py")
        print("=" * 60)
        
        return True
        
    except pyodbc.Error as e:
        print(f"\n❌ Database error: {str(e)}")
        return False
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        return False


if __name__ == '__main__':
    success = load_northwind_database()
    exit(0 if success else 1)
