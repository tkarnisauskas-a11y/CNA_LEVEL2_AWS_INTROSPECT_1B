from flask import Flask, request, jsonify
import sys

app = Flask(__name__)

@app.route('/dapr/subscribe', methods=['GET'])
def subscribe():
    return jsonify([{
        "pubsubname": "product-pubsub",
        "topic": "product.new",
        "route": "/orders/handle"
    }])

# Dapr will POST messages here
@app.route('/orders/handle', methods=['POST'])
def handle_order_event():
    body = request.json
    event_id = body.get('id')
    event_type = body.get('type')
    data = body.get('data', {})
    
    # Extract product details from event data
    product_id = data.get('id', 'unknown')
    product_name = data.get('name', 'unknown')
    product_price = data.get('price', 'unknown')
    
    print(f'[EVENT RECEIVED] Product ID: {product_id}, Name: {product_name}, Price: ${product_price}', flush=True)
    print(f'[EVENT DETAILS] Event ID: {event_id}, Type: {event_type}', flush=True)
    sys.stdout.flush()
    
    # Process business logic (idempotent if at-least-once)
    # e.g., write to DB, emit further events, call downstream services
    
    # Return 200 for success; non-2xx triggers retry based on component config
    return '', 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)