import { api } from "lwc";

import LightningModal from "lightning/modal";

export default class DeploymentMonitorModal extends LightningModal {
  @api
  deploymentManagerProps;

  @api
  deploymentManagerEventHandlers;

  @api
  headerLabel;

  handleDeploymentCompleted(event) {
    this.deploymentManagerEventHandlers?.deploymentcompleted?.(event);
    this.close();
  }

  get myHandlers() {
    return {
      ...this.deploymentManagerEventHandlers,
      deploymentcompleted: this.handleDeploymentCompleted.bind(this)
    };
  }
}
