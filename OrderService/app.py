from flask import Flask, request, jsonify
import json
import os
import requests
from datetime import datetime

app = Flask(__name__)

ORDERS_FILE = '/data/orders.json'
DAPR_HTTP_PORT = os.getenv('DAPR_HTTP_PORT', '3500')
PRODUCT_SERVICE_URL = f'http://localhost:{DAPR_HTTP_PORT}/v1.0/invoke/product-service/method'

def load_orders():
    if os.path.exists(ORDERS_FILE):
        with open(ORDERS_FILE, 'r') as f:
            return json.load(f)
    return []

def save_orders(orders):
    os.makedirs(os.path.dirname(ORDERS_FILE), exist_ok=True)
    with open(ORDERS_FILE, 'w') as f:
        json.dump(orders, f, indent=2)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'})

@app.route('/orders', methods=['POST'])
def create_order():
    data = request.json
    orders = load_orders()
    
    # Get product info via Dapr service invocation
    try:
        response = requests.get(f'{PRODUCT_SERVICE_URL}/products/{data["product_id"]}')
        if response.status_code != 200:
            return jsonify({'error': 'Product not found'}), 404
        product = response.json()
    except Exception as e:
        print(f"Error calling ProductService: {e}")
        return jsonify({'error': 'Failed to get product info'}), 500
    
    order = {
        'id': len(orders) + 1,
        'product_id': data['product_id'],
        'product_name': product['name'],
        'product_price': product['price'],
        'quantity': data['quantity'],
        'total': product['price'] * data['quantity'],
        'created_at': datetime.now().isoformat()
    }
    
    orders.append(order)
    save_orders(orders)
    
    # Publish order event
    webhook_url = os.getenv('ORDER_WEBHOOK_URL')
    if webhook_url:
        try:
            requests.post(webhook_url, json=order)
        except Exception as e:
            print(f"Failed to publish order event: {e}")
    
    return jsonify(order), 201

@app.route('/orders', methods=['GET'])
def get_orders():
    return jsonify(load_orders())

@app.route('/dapr/subscribe', methods=['GET'])
def subscribe():
    return jsonify([
        {
            "pubsubname": "product-pubsub",
            "topic": "product-created",
            "route": "/webhooks/product"
        }
    ])

@app.route('/webhooks/product', methods=['POST'])
def product_webhook():
    data = request.json
    print(f"Product event received: {data}")
    return jsonify({'status': 'ok'})

@app.route('/webhooks/order', methods=['POST'])
def order_webhook():
    data = request.json
    print(f"Order event received: {data}")
    return jsonify({'status': 'ok'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)