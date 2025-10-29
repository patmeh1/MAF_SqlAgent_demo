#!/usr/bin/env python3
"""
Load Northwind sample data into Azure SQL Database using Azure AD authentication.
"""
import os
import sys
import pyodbc
import struct
from azure.identity import AzureCliCredential

# Add parent directory to path to import from project
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

def load_northwind_data():
    """Load the Northwind database schema and data."""
    
    # Database connection details
    server = "nyp-sql-server-1761717077.database.windows.net"
    database = "Northwind"
    driver = "ODBC Driver 18 for SQL Server"
    
    print(f"Connecting to {server}/{database}...")
    
    # Get Azure AD token
    credential = AzureCliCredential()
    token_bytes = credential.get_token("https://database.windows.net/.default").token.encode("UTF-16-LE")
    token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)
    
    # SQL_COPT_SS_ACCESS_TOKEN from msodbcsql.h
    SQL_COPT_SS_ACCESS_TOKEN = 1256
    
    # Build connection string
    connection_string = f"DRIVER={{{driver}}};SERVER={server};DATABASE={database};Encrypt=yes;TrustServerCertificate=no;"
    
    # Connect with Azure AD token
    conn = pyodbc.connect(connection_string, attrs_before={SQL_COPT_SS_ACCESS_TOKEN: token_struct})
    cursor = conn.cursor()
    
    print("Connected successfully!")
    
    # Read the SQL file
    sql_file = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'database', 'northwind.sql')
    print(f"Reading SQL file: {sql_file}")
    
    with open(sql_file, 'r') as f:
        sql_content = f.read()
    
    # Split into individual statements (separated by GO)
    statements = [s.strip() for s in sql_content.split('GO') if s.strip()]
    
    print(f"Executing {len(statements)} SQL statements...")
    
    # Execute each statement
    for i, statement in enumerate(statements, 1):
        try:
            # Skip empty statements or comments
            if not statement or statement.startswith('--'):
                continue
                
            cursor.execute(statement)
            conn.commit()
            
            if i % 10 == 0:
                print(f"  Executed {i}/{len(statements)} statements...")
                
        except Exception as e:
            print(f"Warning: Error executing statement {i}: {str(e)}")
            print(f"Statement: {statement[:100]}...")
            # Continue with next statement
            continue
    
    print("All statements executed!")
    
    # Verify data was loaded
    print("\nVerifying data load...")
    cursor.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME")
    tables = cursor.fetchall()
    print(f"Tables created: {len(tables)}")
    for table in tables:
        cursor.execute(f"SELECT COUNT(*) FROM [{table[0]}]")
        count = cursor.fetchone()[0]
        print(f"  - {table[0]}: {count} rows")
    
    cursor.close()
    conn.close()
    
    print("\n✅ Northwind database loaded successfully!")

if __name__ == "__main__":
    try:
        load_northwind_data()
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
