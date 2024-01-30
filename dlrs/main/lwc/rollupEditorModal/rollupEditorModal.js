import { api } from "lwc";
import LightningModal from "lightning/modal";

export default class RollupEditorModal extends LightningModal {
  @api rollupName;

  handleCancelRequest() {
    this.close();
  }

  handleRequestDelete() {
    this.close({ action: "delete", rollupName: this.rollupName });
  }
}
