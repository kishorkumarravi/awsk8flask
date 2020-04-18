BINARY_NAME=aws_k8s
Docker_Repo_DevOps=localhost

init:
	pip install -r requirements.txt

dr docker-run:
	docker-compose up -d

dev-env:
	python3 -m venv env
	. ./env/bin/activate
	pip install --upgrade pip --user

d-local:
	docker build -f ./packaging/k8s-rest/Dockerfile . -t ${BINARY_NAME}

dr docker-run:
	docker-compose up -d

drm docker-remove:
	docker-compose -f ./docker-compose.yml down