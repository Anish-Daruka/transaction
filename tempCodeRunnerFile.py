from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/api/data', methods=['GET'])
def get_data():
    # Sample JSON response
    return jsonify({
        "message": "Hello from Flask!",
        "items": [
            {"id": 1, "name": "Item 1"},
            {"id": 2, "name": "Item 2"}
        ]
    })

if __name__ == '__main__':
    app.run(debug=True)