import pymysql
import csv
import os
import time

# Database configuration
DB_HOST = os.environ.get('DB_HOST', 'mysql.local')
DB_USER = os.environ.get('DB_USER', 'flask_user')
DB_PASSWORD = os.environ.get('DB_PASSWORD', 'password')
DB_NAME = os.environ.get('DB_NAME', 'product_catalog')

def wait_for_db(max_attempts=30, delay=2):
    """Wait for database to become available"""
    print(f"Attempting to connect to database at {DB_HOST}...")
    
    for attempt in range(max_attempts):
        try:
            connection = pymysql.connect(
                host=DB_HOST,
                user=DB_USER,
                password=DB_PASSWORD,
                cursorclass=pymysql.cursors.DictCursor
            )
            connection.close()
            print("Database connection successful!")
            return True
        except Exception as e:
            print(f"Attempt {attempt+1}/{max_attempts}: Database not available yet. Error: {e}")
            time.sleep(delay)
    
    print("Failed to connect to database after maximum attempts")
    return False

def init_database():
    """Initialize the database and create tables"""
    try:
        # Connect without specifying database to create it if it doesn't exist
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            cursorclass=pymysql.cursors.DictCursor
        )
        
        with connection.cursor() as cursor:
            # Create database if it doesn't exist
            cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_NAME}")
            cursor.execute(f"USE {DB_NAME}")
            
            # Create products table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS products (
                    product_id INT PRIMARY KEY,
                    product_name VARCHAR(100) NOT NULL,
                    category VARCHAR(50) NOT NULL,
                    price DECIMAL(10, 2) NOT NULL,
                    description TEXT
                )
            """)
            
            # Check if data already exists
            cursor.execute("SELECT COUNT(*) as count FROM products")
            result = cursor.fetchone()
            
            if result['count'] == 0:
                # Load data from CSV file
                with open('products.csv', 'r') as file:
                    csv_reader = csv.DictReader(file)
                    for row in csv_reader:
                        cursor.execute("""
                            INSERT INTO products (product_id, product_name, category, price, description)
                            VALUES (%s, %s, %s, %s, %s)
                        """, (
                            int(row['product_id']),
                            row['product_name'],
                            row['category'],
                            float(row['price']),
                            row['description']
                        ))
                
                print("Sample data loaded successfully!")
            else:
                print("Data already exists in the products table")
        
        connection.commit()
        print("Database initialization completed successfully!")
        
    except Exception as e:
        print(f"Database initialization error: {e}")
    finally:
        if connection:
            connection.close()

if __name__ == "__main__":
    if wait_for_db():
        init_database()
    else:
        print("Failed to initialize database: could not connect to MySQL server")