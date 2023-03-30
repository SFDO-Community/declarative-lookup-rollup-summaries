import { api, LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRollupConfig from "@salesforce/apex/RollupEditorController.getRollupConfig";
import validateRollupConfig from "@salesforce/apex/RollupEditorController.validateRollupConfig";
import saveRollupConfig from "@salesforce/apex/RollupEditorController.saveRollupConfig";

export default class RollupEditor extends LightningElement {
  errors = {};
  _rollupName;
  rollup = {};

  connectedCallback() {
    this.getRollup();
  }

  async getRollup() {
    if (!this.rollupName) {
      this.rollup = {};
      return;
    }
    try {
      this.rollup = await getRollupConfig({
        rollupName: this.rollupName
      });
    } catch (error) {
      this.errors.record = [error.message];
    }
  }

  async runValidate() {
    this.errors = await validateRollupConfig({
      rollup: JSON.stringify(this.rollup)
    });
  }

  async runSave() {
    const jobId = await saveRollupConfig({
      rollup: JSON.stringify(this.rollup)
    });
    const evt = new ShowToastEvent({
      title: "Deployment Started",
      message: "Started Metadata Record Upates in Deployment " + jobId,
      variant: "info"
    });
    this.dispatchEvent(evt);
  }

  updateRollup() {
    try {
      this.rollup = JSON.parse(
        this.template.querySelector("lightning-textarea").value
      );
    } catch (error) {
      console.error(error);
    }
  }

  @api
  get rollupName() {
    return this._rollupName;
  }
  set rollupName(val) {
    this._rollupName = val;

    this.getRollup();
  }

  get rollupAsString() {
    return JSON.stringify(this.rollup, null, 2);
  }

  get errorsAsString() {
    return JSON.stringify(this.errors);
  }
}
