#!/bin/bash

set -ex

# Provision infrastructure stack

npm install

npm run deploy-test-infra

npm run deploy-prod-infra

# Provision lifecycle event hooks

cd ../codedeploy-lifecycle-event-hooks

npm install

aws cloudformation package --template-file template.yaml --s3-bucket $1 --output-template-file packaged-template.yaml

aws cloudformation deploy --region us-west-2 --template-file packaged-template.yaml --stack-name TriviaBackendHooksTest --tags project=nike-workshop --capabilities CAPABILITY_NAMED_IAM --tags project=nike-workshop --parameter-overrides TriviaBackendDomain=api-test.nike-workshop.com

aws cloudformation deploy --region us-west-2 --template-file packaged-template.yaml --stack-name TriviaBackendHooksProd --tags project=nike-workshop --capabilities CAPABILITY_NAMED_IAM --tags project=nike-workshop --parameter-overrides TriviaBackendDomain=api.nike-workshop.com

cd ../codedeploy-blue-green

# Provision ECS and CodeDeploy resources

aws ecs create-cluster --region us-west-2 --cluster-name default --tags key=project,value=nike-workshop

aws ecs update-cluster-settings --region us-west-2 --cluster default --settings name=containerInsights,value=enabled

npm run deploy-test-deployment-resources

npm run deploy-prod-deployment-resources

# Generate task definition and appsec files

mkdir -p build

export AWS_REGION=us-west-2

node produce-config.js -g test -s TriviaBackendTest -d TriviaDeploymentResourcesTest -h TriviaBackendHooksTest

node produce-config.js -g prod -s TriviaBackendProd -d TriviaDeploymentResourcesProd -h TriviaBackendHooksProd

ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text --region us-west-2`

sed -i "s|<PLACEHOLDER>|$ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/nike-workshop-backend:latest|g" build/task-definition-test.json build/task-definition-prod.json

# Start deployment

aws ecs deploy --region us-west-2 --service TriviaBackendTest --codedeploy-application AppECS-TriviaBackendTest --codedeploy-deployment-group DgpECS-TriviaBackendTest --task-definition build/task-definition-test.json --codedeploy-appspec build/appspec-test.json

aws ecs deploy --region us-west-2 --service TriviaBackendTest --codedeploy-application AppECS-TriviaBackendProd --codedeploy-deployment-group Dgp-TriviaBackendProd --task-definition build/task-definition-prod.json --codedeploy-appspec build/appspec-prod.json
