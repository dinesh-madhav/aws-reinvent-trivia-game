#!/usr/bin/env node
import { App, Stack, StackProps } from 'aws-cdk-lib';
import { TriviaGameCfnPipeline } from './common/cfn-pipeline';

class TriviaGameCanariesPipelineStack extends Stack {
    constructor(parent: App, name: string, props?: StackProps) {
        super(parent, name, props);

        new TriviaGameCfnPipeline(this, 'Pipeline', {
            pipelineName: 'canaries',
            stackName: 'Canaries',
            templateName: 'Canaries',
            directory: 'canaries',
            pipelineCdkFileName: 'canaries-pipeline',
        });
    }
}

const app = new App();
new TriviaGameCanariesPipelineStack(app, 'TriviaGameCanariesPipeline', {
    env: { account: process.env['CDK_DEFAULT_ACCOUNT'], region: 'us-west-2' },
    tags: {
        project: "nike-workshop"
    }
});
app.synth();