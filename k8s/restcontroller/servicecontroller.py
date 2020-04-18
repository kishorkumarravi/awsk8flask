import json
import logging
from marshmallow import ValidationError
from flask import Blueprint, jsonify, request, make_response
import line_profiler

profile = line_profiler.LineProfiler()

service_url = Blueprint('service_url', __name__)

@profile
@service_url.route('/', methods=['GET'])
def about():
    """Health check route for AWS K8S Flask API 
    """
    logging.info("AWS K8S Flask API")
    return jsonify(success=True, message='AWS K8S Flask API')

@profile
@service_url.route('/service/', methods=['GET', 'POST'])
def get_service_response():
    """ API to get service response
    """
    if request.data:
        json_req = json.loads(request.data)
        try:
            print(json_req)
            return jsonify(success=True, message='service response success')
        except ValidationError as error:
            return jsonify(success=True, error=error)

    else:
        return make_response(jsonify(success=False, error='EMPTY_POST_DATA'), 400)

