from flask import Flask, jsonify, request
import mysql.connector

app = Flask(__name__)

def get_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="YOUR_PASSWORD", # Change to your MySQL password
        database="dbonlineshop"
    )

@app.route('/likes', methods=['GET'])
def get_likes():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT product_id FROM product_likes")
    rows = cursor.fetchall()
    liked_ids = [row[0] for row in rows]
    cursor.close()
    conn.close()
    return jsonify({"liked_products": liked_ids}), 200

@app.route('/likes', methods=['POST'])
def add_like():
    data = request.get_json()
    product_id = data.get('product_id')
    if not product_id:
        return jsonify({"error": "product_id is required"}), 400
    conn = get_db()
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO product_likes (product_id) VALUES (%s)", (product_id,))
        conn.commit()
        response = jsonify({"message": f"Product {product_id} liked"}), 201
    except Exception as e:
        conn.rollback()
        response = jsonify({"error": str(e)}), 400
    finally:
        cursor.close()
        conn.close()
    return response

@app.route('/likes/<int:product_id>', methods=['DELETE'])
def remove_like(product_id):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM product_likes WHERE product_id = %s", (product_id,))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({"message": f"Product {product_id} unliked"}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)