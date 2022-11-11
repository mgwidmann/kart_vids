import { Construct } from "constructs";
import { getStage, KartVidsStage } from "./stage";

export class KartVidsConstruct extends Construct {
    stage: KartVidsStage;

    constructor(scope: Construct, id: string) {
        super(scope, id);
        this.stage = getStage();
    }

    isDev() {
        return this.stage === KartVidsStage.DEV;
    }

    isProd() {
        return this.stage === KartVidsStage.PROD;
    }
}