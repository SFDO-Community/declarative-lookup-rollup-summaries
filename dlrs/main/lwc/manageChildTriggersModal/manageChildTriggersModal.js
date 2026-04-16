import { api } from "lwc";

import LightningModal from "lightning/modal";

export default class ManageChildTriggersModal extends LightningModal {
  @api
  rollupName;

  handleDismiss() {
    this.close();
  }

  handleDeploy() {
    // reach into the nested component to start the deploy
    this.refs.manageTriggers.deploy();
  }
}
