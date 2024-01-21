import { LightningElement, api } from "lwc";

/**
 * @typedef step
 * @property {string} label
 * @property {"complete"|"current"|"incomplete"|"failed"} status
 */

export default class FlexiblePath extends LightningElement {
  /** @type {step[]} */
  @api
  get steps() {
    return this._steps;
  }

  set steps(val) {
    this._steps = val.map((v) => ({
      ...v,
      ["is" + v.status.charAt(0).toUpperCase() + v.status.slice(1)]: true
    }));
  }

  get nextActionLabel() {
    if (!this.steps) {
      return "unknown";
    }
    let nextLabel = this.steps.find((s) => s.status === "current")?.label;
    if (!nextLabel) {
      nextLabel = this.steps.find((s) => s.status === "incomplete")?.label;
    }
    return nextLabel;
  }

  handleNextActionClick() {
    this.dispatchEvent(
      new CustomEvent("nextactionclick", {
        detail: {
          label: this.nextActionLabel
        }
      })
    );
  }
}
