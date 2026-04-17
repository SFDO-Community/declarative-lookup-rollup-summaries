import { api } from "lwc";

import LightningModal from "lightning/modal";

export default class ManageChildTriggersModal extends LightningModal {
  @api
  rollupName;

  disableButtons = false;

  handleDismiss() {
    this.close();
  }

  handleDeploy() {
    // reach into the nested component to start the deploy
    this.refs.manageTriggers.deploy();
  }

  handleDeploymentStarted() {
    this.disableButtons = true;
  }

  handleDeploymentCompleted(event) {
    const deployResult = event.detail.deployResult;
    if (deployResult.success) {
      this.close();
    } else {
      this.disableButtons = false;
    }
  }
}
