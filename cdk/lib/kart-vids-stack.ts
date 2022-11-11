import { Stack, StackProps } from 'aws-cdk-lib';
import { User } from 'aws-cdk-lib/aws-iam';
import { Construct } from 'constructs';
import { VideoStorage } from './kart-vids/video-storage';
import { dashDev, KartVidsStage, setStage } from './stage';

export interface KartVidsStackProps extends StackProps {
  stage: KartVidsStage;
  stackName: string;
}

export class KartVidsStack extends Stack {
  constructor(scope: Construct, id: string, props: KartVidsStackProps) {
    super(scope, id, props);
    setStage(props.stage);

    const apiUser = new User(this, 'VideoStorageUser', {
      userName: dashDev('kartvids'),
    });

    new VideoStorage(this, 'Videos', { apiUser });
  }
}
