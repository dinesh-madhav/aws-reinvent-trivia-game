# Canaries

The trivia game application can use Amazon CloudWatch Synthetics to continuously load the webpage and APIs, and alarm when the page does not load or does not render correctly.

## Prep

Create an SNS topic for notifications about the canary alarms.  An email address or to a [chat bot](https://docs.aws.amazon.com/chatbot/latest/adminguide/setting-up.html) can then be subscribed to the topic to receive notifications about canary alarms.
```
aws sns create-topic --name nike-workshop-notifications --region us-west-2
```

## Customize

Replace all references to 'nike-workshop.com' with your own domain name.

## Deploy

Ideally, use the pipelines in the "[pipelines](../pipelines/)" folder to deploy the canaries.  Alternatively, you can use the AWS CLI to deploy.

These instructions require an S3 bucket to store the canary source code, marked as `$BUCKET_NAME` below.

### Package the canary code

Package and upload the canary script:

```
npm install
mkdir -p nodejs/
cp -a node_modules/ nodejs/
cp canary.js nodejs/node_modules/
zip -r trivia-game-canary-code.zip nodejs/
aws s3 cp trivia-game-canary-code.zip s3://$BUCKET_NAME/
```

### Create the test endpoint canary

Deploy the resources for running a continuous monitoring canary against the test endpoints:

```
aws cloudformation deploy \
  --region us-west-2 \
  --template-file template.yaml \
  --stack-name TriviaGameCanariesTest \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides Stage=test SourceBucket=$BUCKET_NAME SourceObjectKey="trivia-game-canary-code.zip" WebpageUrl="https://test.nike-workshop.com" ApiEndpoint="https://api-test.nike-workshop.com/" \
  --tags project=nike-workshop
```

### Create the production endpoint canary

Deploy the resources for running a continuous monitoring canary against the production endpoints:

```
aws cloudformation deploy \
  --region us-west-2 \
  --template-file template.yaml \
  --stack-name TriviaGameCanariesProd \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides Stage=prod SourceBucket=$BUCKET_NAME SourceObjectKey="trivia-game-canary-code.zip" WebpageUrl="https://www.nike-workshop.com" ApiEndpoint="https://api.nike-workshop.com/" \
  --tags project=nike-workshop
```
