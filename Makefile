BINARY_NAME=aws_k8s
Docker_Repo_DevOps=localhost
VERSION=$(shell echo $(BUILD_ID))
BRANCH=$(shell echo $(BRANCH_NAME) | tr '[A-Z]' '[a-z]')
JOB_NAME:=$(shell echo $(TF_VAR_JOB_NAME))
BUILD=$(BRANCH)_$(VERSION)

AWS_ACCESS_KEY_ID := $(shell echo $(AWS_ACCESS_KEY_ID_2))
AWS_SECRET_ACCESS_KEY := $(shell echo $(AWS_SECRET_ACCESS_KEY_2))

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

d-k8s-app:
	docker build -f ./packaging/k8s-rest/Dockerfile . -t ${BINARY_NAME}

env-file:
	rm .env || true
	echo 'AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}' >> .env
	echo 'AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}' >> .env
	
daws docker-aws-creds:
	curl --silent "http://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
	sudo rm -rf ./awscli-bundle || true
	sudo unzip -o awscli-bundle.zip > /dev/null

	sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
	sudo chmod 777 /usr/local/aws
	sudo chmod 777 /usr/local/bin/aws
	sudo aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
	sudo aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
	sudo aws configure set default.region us-west-2
	sudo chmod 777 /home1/ubuntu/.aws/credentials
	sudo chmod 777 /home1/ubuntu/.aws/config
	sudo chmod 777 /var/run/docker.sock
	
	aws ecr get-login --no-include-email --region=us-west-2  | sh

dpops docker-publish-ops:
	docker tag ${BINARY_NAME}:$(BUILD) ${Docker_Repo_DevOps}/${BRANCH_NAME}/${BINARY_NAME}:$(BUILD)
	docker push ${Docker_Repo_DevOps}/${BRANCH_NAME}/${BINARY_NAME}:$(BUILD)

dr docker-run:
	docker-compose up -d

full-stack:
	docker-compose up -d

down full-stack-down:
	docker-compose down

drm docker-remove:
	docker-compose -f ./docker-compose.yml down

deploy-k8s-alpha deploy-k8s-beta deploy-k8s-gamma:
	make -B -C ./deploy/v3/ deploy-tesla-mode

tf-destroy:
	make -B -C ./deploy/v3/ destroy

scale-test:
	make -B -C ./tests/ scale

tests:
	make -B -C lint || true

lint:
	mkdir lint || true
	pylint filesync/ | tee pylint.out
	mv pylint.out ./lint/
