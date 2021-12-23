ifneq (,)
.error This Makefile requires GNU Make.
endif

.DEFAULT_GOAL := build
DOCKER_COMP_RUN=docker-compose run --rm --service-ports
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
HASH := $(shell git rev-parse HEAD)

JOB_TEMPLATE := dc-training.tmpl.yaml

ifneq ("$(wildcard ./.env)","")
    include .env
	export
endif

.phony: build
build:
	docker-compose build terragrunt

REGION=us-east-2
SERVICE=labs
MODULE=cluster


S3_URI := s3://document-crunch/kira-mapping-project/
TARGET_DIR := ./KIRA Mapping Project

upload:
	@aws s3 cp --recursive "${TARGET_DIR}" ${S3_URI}

#Terragrunt commands
# working directory corresponds to account/region/layer 
TERRAGRUNT=${DOCKER_COMP_RUN} -w "//data/live/${REGION}/${SERVICE}/${MODULE}" terragrunt terragrunt

.phony: clean clean-terragrunt init version

init:  
	${TERRAGRUNT} init -input=false -no-color -input=false

version: 
	${TERRAGRUNT} --version

clean: clean-terragrunt
	docker-compose down
 
clean-terragrunt:
	-find . -name ".terragrunt-cache" -print0 | xargs -r0 -- rm -r
	-find . -name ".terraform.lock.hcl" -print0 | xargs -r0 -- rm -r

interactive:
	${DOCKER_COMP_RUN} terragrunt bash

.phony:  plan, rg

# plan: 
# 	${TERRAGRUNT} plan

# apply:
# 	${TERRAGRUNT} apply --auto-approve

# destroy:
# 	${TERRAGRUNT} destory --auto-approve	

vpc.%: MODULE=vpc
vpc.%: 
	${TERRAGRUNT} $* ${argument}

cluster.%: MODULE=cluster
cluster.%: 
	${TERRAGRUNT} $* ${argument}

argo.%: MODULE=argocd-helm
argo.%: 
	${TERRAGRUNT} $* ${argument}


# aws --profile <ACCOUNT_NAME> eks --region <YOUR_REGION> update-kubeconfig --name lab

 # aws  eks --region us-east-2 update-kubeconfig --name lab
#kubectl get ingress --all-namespaces

#https://208071568133.signin.aws.amazon.com/console
# echo 'yq() {
#   docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
# }' | tee -a ~/.bashrc && source ~/.bashrc

# check command existence
# for command in kubectl jq envsubst aws
#   do
#     which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
#   done


#enable kubectl bash completion
# kubectl completion bash >>  ~/.bash_completion
# . /etc/profile.d/bash_completion.sh
# . ~/.bash_completion


.PHONY: create-eks, delete-eks, set-kubeconfig

set-kubeconfig:
	@aws eks --region us-east-2 update-kubeconfig --name ${SERVICE}

create-eks:  
	@eksctl create cluster --name ${SERVICE} --node-type m5a.large --nodes 3 --nodes-min 3 --nodes-max 5 --region us-east-2

delete-eks:
	@eksctl delete cluster --name ${SERVICE} --region us-east-2

# Expand the template into multiple files, one for each item to be processed.
#  look into the make way to doing this
expand-template:		
	

# argo-workflows admin privileges to argocd namespace, all jobs must run in argocd namesapce.. 
# kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=argo:default -n argo

#Scaling kubernetes
# kubectl create deployment php-apache --image=us.gcr.io/k8s-artifacts-prod/hpa-example
# kubectl set resources deploy php-apache --requests=cpu=200m
# kubectl expose deploy php-apache --port 80

# kubectl get pod -l app=php-apache
#kubectl autoscale deployment php-apache `#The target average CPU utilization` \
    --cpu-percent=50 \
    --min=1 `#The lower limit for the number of pods that can be set by the autoscaler` \
    --max=10 `#The upper limit for the number of pods that can be set by the autoscaler`
#	kubectl get hpa

#kubectl get configmap -n kube-system aws-auth -o yaml | grep -v "creationTimestamp\|resourceVersion\|selfLink\|uid" | sed '/^  annotations:/,+2 d' > aws-auth.yaml


