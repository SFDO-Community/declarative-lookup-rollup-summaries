import { LightningElement, api } from "lwc";

export default class RollupEditorError extends LightningElement {
  @api
  errors;

  get hasErrors() {
    return !!this.errors;
  }
}
