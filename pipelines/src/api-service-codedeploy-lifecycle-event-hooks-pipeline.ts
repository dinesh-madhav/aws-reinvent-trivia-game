#!/usr/bin/env node
import { App, Stack, StackProps } from 'aws-cdk-lib';
import { TriviaGameCfnPipeline } from './common/cfn-pipeline';

class TriviaGameLifecycleHooksPipelineStack extends Stack {
    constructor(parent: App, name: string, props?: StackProps) {
        super(parent, name, props);

        new TriviaGameCfnPipeline(this, 'Pipeline', {
            pipelineName: 'codedeploy-lifecycle-event-hooks',
            stackName: 'Hooks',
            stackNamePrefix: 'TriviaBackend',
            templateName: 'Hooks',
            directory: 'trivia-backend/infra/codedeploy-lifecycle-event-hooks',
            pipelineCdkFileName: 'api-service-codedeploy-lifecycle-event-hooks-pipeline',
        });
    }
}

const app = new App();
new TriviaGameLifecycleHooksPipelineStack(app, 'TriviaGameLifecycleHooksPipeline', {
    env: { account: process.env['CDK_DEFAULT_ACCOUNT'], region: 'us-east-1' },
    tags: {
        project: "nike-workshop"
    }
});
app.synth();