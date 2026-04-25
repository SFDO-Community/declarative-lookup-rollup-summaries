import { LightningElement, api } from "lwc";

// TODO: should centralize these
const CALCULATION_MODES = {
  Scheduled: "Watch for Changes and Process Later",
  Realtime: "Realtime",
  "Process Builder": "Invocable by Automation",
  Developer: "Developer"
};
export default class RollupDetail extends LightningElement {
  @api
  rollup;

  get relationshipCriteriaFieldsPills() {
    return [
      {
        label: this.rollup.fieldToAggregate,
        name: this.rollup.fieldToAggregate,
        tooltip: "DLRS automatically monitors the Field to Aggregate"
      },
      {
        label: this.rollup.relationshipField,
        name: this.rollup.relationshipField,
        tooltip: "DLRS automatically monitors the Relationship Field"
      },
      this.rollup.relationshipCriteriaFields?.split("\n")?.map((field) => ({
        label: field.trim(),
        name: field.trim()
      })) ?? []
    ];
  }

  get calculationMode() {
    return (
      CALCULATION_MODES[this.rollup.calculationMode] ??
      this.rollup.calculationMode
    );
  }
}
