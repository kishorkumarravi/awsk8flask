"""
Main app.py where Flask application starts executing
"""
import logging
import logging.config
import os
import socket

from flask import Flask

APP = Flask(__name__)

from restcontroller.servicecontroller import service_url

APP.register_blueprint(
    service_url, url_prefix="/aws/k8")

if __name__ == '__main__':
    APP.run(host='0.0.0.0', debug=False, threaded=True)