import { Fn, RemovalPolicy } from "aws-cdk-lib";
import { Bucket, BucketEncryption, BucketProps, BlockPublicAccess } from "aws-cdk-lib/aws-s3";
import { Construct } from "constructs";
import { getRemovalPolicy, getStage, KartVidsStage } from "../stage";

export interface SecureBucketProps extends BucketProps {
    encryption?: BucketEncryption;
    enforceSSL: true;
    bucketName: string;
    removalPolicy?: RemovalPolicy;
    versioned: true;
    publicReadAccess: false;
    blockPublicAccess?: BlockPublicAccess;
    serverAccessLogsPrefix?: string;
}

export class SecureBucket extends Bucket {
    stage: KartVidsStage;

    constructor(scope: Construct, id: string, props: SecureBucketProps) {
        const stage = getStage();
        props.encryption = props.encryption || BucketEncryption.S3_MANAGED;
        props.removalPolicy = props.removalPolicy || getRemovalPolicy();
        props.blockPublicAccess = BlockPublicAccess.BLOCK_ALL; // No override
        props.serverAccessLogsPrefix = props.serverAccessLogsPrefix || 'access-logs';
        if (stage === KartVidsStage.DEV) {
            props.bucketName = `${props.bucketName}-dev`;
        } else {
            props.bucketName = `${props.bucketName}-prod`;
        }
        props.bucketName = Fn.sub(`${props.bucketName}-\${AWS::AccountId}`);

        super(scope, id, props);

        this.stage = stage;
    }
}