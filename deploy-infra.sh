#!/bin/bash

STACK_NAME=aws-bootstrap
REGION=us-east-2
CLI_PROFILE=aws-bootstrap

EC2_INSTANCE_TYPE=t2.micro

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --profile aws-bootstrap \
  --query "Account" --output text)
CODEPIPELINE_BUCKET="$STACK_NAME-$REGION-codepipeline-$AWS_ACCOUNT_ID"

GH_ACCESS_TOKEN=$(cat ~/.github/aws-bootstrap-access-token)
GH_OWNER=$(cat ~/.github/aws-bootstrap-owner)
GH_REPO=$(cat ~/.github/aws-bootstrap-repo)
GH_BRANCH=master

# Deploy static resources
echo -e "\n\n=========== Deploying setup.yml ==========="
aws cloudformation deploy \
  --region $REGION \
  --profile $CLI_PROFILE \
  --stack-name $STACK_NAME-setup \
  --template-file setup.yml \
  --no-fail-on-empty-changeset \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    CodePipelineBucket="$CODEPIPELINE_BUCKET"

# Deploy the CloudFormation template
echo -e "\n\n=========== Deploying main.yml ==========="
aws cloudformation deploy \
  --region $REGION \
  --profile $CLI_PROFILE \
  --stack-name $STACK_NAME \
  --template-file main.yml \
  --no-fail-on-empty-changeset \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    EC2InstanceType=$EC2_INSTANCE_TYPE \
    GitHubOwner="$GH_OWNER" \
    GitHubRepo="$GH_REPO" \
    GitHubBranch=$GH_BRANCH \
    GitHubPersonalAccessToken="$GH_ACCESS_TOKEN" \
    CodePipelineBucket="$CODEPIPELINE_BUCKET"
