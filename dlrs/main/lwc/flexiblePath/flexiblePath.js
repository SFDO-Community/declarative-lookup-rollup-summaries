import { LightningElement, api } from "lwc";

export const PATH_STATES = {
  complete: "complete",
  current: "current",
  incomplete: "incomplete",
  failed: "failed"
};

/**
 * @typedef step
 * @property {string} label
 * @property {string} name
 * @property {keyof typeof PATH_STATES} status
 * @property {string?} nextActionLabel
 */

export default class FlexiblePath extends LightningElement {
  _steps;
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
    let nextCurrent = this.nextAction;
    return nextCurrent?.nextActionLabel ?? nextCurrent?.label;
  }

  get nextAction() {
    return (
      this.steps.find((s) => s.status === "current") ??
      this.steps.find((s) => s.status === "incomplete")
    );
  }

  handleNextActionClick() {
    const nextAction = this.nextAction;
    this.dispatchEvent(
      new CustomEvent("nextactionclick", {
        detail: {
          label: nextAction.label,
          name: nextAction.name
        }
      })
    );
  }
}
