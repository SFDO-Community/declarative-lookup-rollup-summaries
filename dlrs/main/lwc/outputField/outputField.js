import { LightningElement, api } from "lwc";

export default class OutputField extends LightningElement {
  @api
  label;

  @api
  checkboxLabel;

  @api
  value;

  @api
  type;

  get isNumber() {
    return this.type.toLowerCase() === "number";
  }

  get isText() {
    return this.type.toLowerCase() === "text";
  }

  get isDateTime() {
    return this.type.toLowerCase() === "datetime";
  }

  get isEmail() {
    return this.type.toLowerCase() === "email";
  }

  get isCheckbox() {
    return this.type.toLowerCase() === "checkbox";
  }

  get isPill() {
    return this.type.toLowerCase() === "pill";
  }
}
