import { Duration } from "aws-cdk-lib";
import { IGrantable, User } from "aws-cdk-lib/aws-iam";
import { CorsRule, HttpMethods } from "aws-cdk-lib/aws-s3";
import { Construct } from "constructs";
import { KartVidsConstruct } from "../construct";
import { SecureBucket } from "../patterns/secure-bucket";

export interface VideoStorageProps {
    apiUser: IGrantable;
}

export class VideoStorage extends KartVidsConstruct {
    constructor(scope: Construct, id: string, props: VideoStorageProps) {
        super(scope, id);

        const bucket = new SecureBucket(this, 'VideoStorage', {
            enforceSSL: true,
            bucketName: 'kart-vids-videos',
            versioned: true,
            publicReadAccess: false,
            cors: this.corsConfig(),
            intelligentTieringConfigurations: [
                {
                    name: 'videos',
                    prefix: 'videos/originals',
                    archiveAccessTierTime: Duration.days(90),
                    deepArchiveAccessTierTime: Duration.days(180),
                }
            ]
        });

        bucket.grantReadWrite(props.apiUser);
    }

    corsConfig(): CorsRule[] {
        if (this.isDev()) {
            return [{ id: 'localhost', maxAge: Duration.hours(1).toSeconds(), allowedMethods: [HttpMethods.GET, HttpMethods.POST], allowedHeaders: ['*'], allowedOrigins: ['http://localhost:4000'] }];
        } else {
            return [{ id: 'kart-vids.fly.dev', maxAge: Duration.hours(1).toSeconds(), allowedMethods: [HttpMethods.GET, HttpMethods.POST], allowedHeaders: ['*'], allowedOrigins: ['https://kart-vids.fly.dev'] }];
        }
    }
}