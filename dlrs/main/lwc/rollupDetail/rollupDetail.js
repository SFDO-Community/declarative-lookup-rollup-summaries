import { LightningElement, api } from "lwc";

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
      ...(this.rollup.relationshipCriteriaFields === undefined
        ? []
        : this.rollup.relationshipCriteriaFields?.split("\n").map((field) => ({
            label: field.trim(),
            name: field.trim()
          })))
    ];
  }
}
