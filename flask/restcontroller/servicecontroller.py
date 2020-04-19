import logging
from flask import Blueprint, jsonify

service_url = Blueprint('service_url', __name__)

@service_url.route('/', methods=['GET'])
def about():
    """Health check route for Flask API 
    """
    logging.info("Flask API")
    return jsonify(success=True, message='Flask API success')
