from flask import Flask, request, jsonify
import json
import os
import requests
from datetime import datetime

app = Flask(__name__)

PRODUCTS_FILE = '/data/products.json'
DAPR_HTTP_PORT = os.getenv('DAPR_HTTP_PORT', '3500')
PUBSUB_NAME = 'product-pubsub'
TOPIC_NAME = 'product-created'

def load_products():
    if os.path.exists(PRODUCTS_FILE):
        with open(PRODUCTS_FILE, 'r') as f:
            return json.load(f)
    return []

def save_products(products):
    os.makedirs(os.path.dirname(PRODUCTS_FILE), exist_ok=True)
    with open(PRODUCTS_FILE, 'w') as f:
        json.dump(products, f, indent=2)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'})

@app.route('/products', methods=['POST'])
def create_product():
    data = request.json
    products = load_products()
    
    product = {
        'id': len(products) + 1,
        'name': data['name'],
        'price': data['price'],
        'created_at': datetime.now().isoformat()
    }
    
    products.append(product)
    save_products(products)
    
    # Publish event via Dapr
    publish_url = f'http://localhost:{DAPR_HTTP_PORT}/v1.0/publish/{PUBSUB_NAME}/{TOPIC_NAME}'
    try:
        requests.post(publish_url, json=product)
    except Exception as e:
        print(f"Failed to publish event: {e}")
    
    return jsonify(product), 201

@app.route('/products', methods=['GET'])
def get_products():
    return jsonify(load_products())

@app.route('/products/<int:product_id>', methods=['GET'])
def get_product(product_id):
    products = load_products()
    product = next((p for p in products if p['id'] == product_id), None)
    if product:
        return jsonify(product)
    return jsonify({'error': 'Product not found'}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)