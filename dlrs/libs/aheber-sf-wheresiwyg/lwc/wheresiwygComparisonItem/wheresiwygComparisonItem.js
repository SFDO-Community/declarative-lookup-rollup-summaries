import { LightningElement, api, track } from "lwc";

export default class WheresiwygComparisonItem extends LightningElement {
  @api
  baseObject;

  @api
  index;

  @track
  _item;

  @api
  get item() {
    return this._item;
  }
  set item(val) {
    this._item = JSON.parse(JSON.stringify(val));
  }

  buildFilterConfig() {
    // this.item.subjects = Array.from(
    //   this.template.querySelectorAll(".subjects")
    // ).map((elem) => elem.value);
    this.item.operator =
      this.template.querySelector("lightning-combobox").value;
    this.item.values = Array.from(
      this.template.querySelectorAll(".values")
    ).map((elem) => elem.value);
    this.sendFilterCriteria(this.item);
  }

  handleSubjectSelected(event) {
    console.log("Values", event.detail.subjects);
    this.item.subjects = event.detail.subjects;
    this.buildFilterConfig();
  }

  sendFilterCriteria(config) {
    this.dispatchEvent(
      new CustomEvent("updateitem", {
        detail: { index: this.index, config }
      })
    );
  }

  addValue() {
    this.item.values.push("");
  }

  get allowsMultipleValues() {
    return (
      this.criteriaOperators.find((o) => o.value === this.item.operator)
        .type === "multi"
    );
  }

  get criteriaOperators() {
    return [
      { label: "=", value: "=", type: "single" },
      { label: "!=", value: "!=", type: "single" },
      { label: "<>", value: "<>", type: "single" },
      { label: ">", value: ">", type: "single" },
      { label: "<", value: "<", type: "single" },
      { label: ">=", value: ">=", type: "single" },
      { label: "<=", value: "<=", type: "single" },
      { label: "IN", value: "IN", type: "multi" },
      {
        label: "NOT IN",
        value: "NOT IN",
        type: "multi",
        limit: "multi-select"
      },
      {
        label: "INCLUDES",
        value: "INCLUDES",
        type: "multi",
        limit: "multi-select"
      },
      {
        label: "EXCLUDES",
        value: "EXCLUDES",
        type: "multi",
        limit: "multi-select"
      }
    ];
  }
}
