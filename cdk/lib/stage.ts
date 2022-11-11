import { RemovalPolicy } from "aws-cdk-lib";

export enum KartVidsStage {
    DEV = 'dev',
    PROD = 'prod',
}

let currentStage: KartVidsStage;
export function setStage(stage: KartVidsStage) {
    currentStage = stage;
}

export function getStage() {
    if (!currentStage) {
        throw new Error('KartVidsStage not yet set before accessing!');
    }

    return currentStage;
}

export function dashDev(string: string) {
    if (getStage() === KartVidsStage.DEV) {
        return `${string}-dev`;
    }

    return string;
}

export function getRemovalPolicy(): RemovalPolicy {
    if (getStage() === KartVidsStage.DEV) {
        return RemovalPolicy.DESTROY;
    }

    return RemovalPolicy.RETAIN;
}