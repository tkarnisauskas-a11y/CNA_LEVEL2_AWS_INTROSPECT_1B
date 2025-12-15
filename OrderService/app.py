from flask import Flask, request

app = Flask(__name__)

# Dapr will POST messages here
@app.route('/orders/handle', methods=['POST'])
def handle_order_event():
    body = request.json
    event_id = body.get('id')
    event_type = body.get('type')
    data = body.get('data')
    
    print(f'Received order event: id={event_id}, type={event_type}, data={data}')
    
    # Process business logic (idempotent if at-least-once)
    # e.g., write to DB, emit further events, call downstream services
    
    # Return 200 for success; non-2xx triggers retry based on component config
    return '', 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)