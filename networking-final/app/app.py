from flask import Flask, render_template, jsonify
import pymysql
import os
from datetime import datetime

app = Flask(__name__)

# Database configuration
DB_HOST = os.environ.get('DB_HOST', 'mysql.local')  # Using private DNS name
DB_USER = os.environ.get('DB_USER', 'flask_user')
DB_PASSWORD = os.environ.get('DB_PASSWORD', 'password')
DB_NAME = os.environ.get('DB_NAME', 'product_catalog')

def get_db_connection():
    """Create a database connection"""
    try:
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
        return connection
    except Exception as e:
        print(f"Database connection error: {e}")
        return None

@app.route('/')
def index():
    """Home page showing all products"""
    try:
        connection = get_db_connection()
        if connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT * FROM products")
                products = cursor.fetchall()
            connection.close()
            return render_template('index.html', products=products)
        else:
            return render_template('error.html', error="Database connection failed")
    except Exception as e:
        return render_template('error.html', error=str(e))

@app.route('/api/products')
def api_products():
    """API endpoint to get all products as JSON"""
    try:
        connection = get_db_connection()
        if connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT * FROM products")
                products = cursor.fetchall()
            connection.close()
            
            # Convert decimal values to float for JSON serialization
            for product in products:
                if 'price' in product:
                    product['price'] = float(product['price'])
            
            return jsonify({"products": products})
        else:
            return jsonify({"error": "Database connection failed"}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/products/<int:product_id>')
def api_product(product_id):
    """API endpoint to get a specific product by ID"""
    try:
        connection = get_db_connection()
        if connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT * FROM products WHERE product_id = %s", (product_id,))
                product = cursor.fetchone()
            connection.close()
            
            if product:
                # Convert decimal values to float for JSON serialization
                if 'price' in product:
                    product['price'] = float(product['price'])
                return jsonify(product)
            else:
                return jsonify({"error": "Product not found"}), 404
        else:
            return jsonify({"error": "Database connection failed"}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/category/<category_name>')
def category(category_name):
    """Page showing products filtered by category"""
    try:
        connection = get_db_connection()
        if connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT * FROM products WHERE category = %s", (category_name,))
                products = cursor.fetchall()
            connection.close()
            return render_template('category.html', products=products, category=category_name)
        else:
            return render_template('error.html', error="Database connection failed")
    except Exception as e:
        return render_template('error.html', error=str(e))

@app.route('/health')
def health():
    """Health check endpoint"""
    try:
        connection = get_db_connection()
        if connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
                result = cursor.fetchone()
            connection.close()
            return jsonify({
                "status": "healthy",
                "database": "connected",
                "timestamp": datetime.now().isoformat()
            })
        else:
            return jsonify({
                "status": "unhealthy",
                "database": "disconnected",
                "timestamp": datetime.now().isoformat()
            }), 500
    except Exception as e:
        return jsonify({
            "status": "unhealthy",
            "database": "error",
            "error": str(e),
            "timestamp": datetime.now().isoformat()
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5555, debug=True)