from flask import Flask, render_template
import socket
import os
import logging
from datetime import datetime

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s'
)

app = Flask(__name__)

def get_ip():
    try:
        return socket.gethostbyname(socket.gethostname())
    except Exception:
        return "N/A"

def get_version():
    try:
        with open(os.path.join(os.path.dirname(__file__), 'VERSION')) as f:
            return f.read().strip()
    except Exception:
        return "N/A"

def common_context():
    return {
        "app_name": os.environ.get("APP_NAME", "test_app"),
        "pod_name": os.environ.get("HOSTNAME", "N/A"),  # Kubernetes sets HOSTNAME to pod name
        "pod_ip": os.environ.get("POD_IP", get_ip()),    # Set via Downward API or fallback
        "node_name": os.environ.get("NODE_NAME", "N/A"), # Set via Downward API
        "node_ip": os.environ.get("NODE_IP", "N/A"),     # Set via Downward API
        "namespace": os.environ.get("POD_NAMESPACE", "N/A"), # Set via Downward API
        "container_id": os.environ.get("CONTAINER_ID", "N/A"),
        "python_version": os.environ.get("PYTHON_VERSION", os.sys.version),
        "flask_env": os.environ.get("FLASK_ENV", "N/A"),
        "version": get_version(),
    }

@app.route('/')
def index():
    logging.info("Home page viewed")
    return render_template("index.html", **common_context())

@app.route('/clients')
def clients():
    logging.info("Clients page viewed")
    return render_template("clients.html", **common_context())

@app.route('/orders')
def orders():
    logging.info("Orders page viewed")
    return render_template("orders.html", **common_context())

@app.route('/health')
def health():
    logging.info("Health page viewed")
    return render_template("health.html", **common_context())

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)