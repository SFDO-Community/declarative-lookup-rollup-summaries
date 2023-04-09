import { api, LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRollupConfig from "@salesforce/apex/RollupEditorController.getRollupConfig";
import validateRollupConfig from "@salesforce/apex/RollupEditorController.validateRollupConfig";
import saveRollupConfig from "@salesforce/apex/RollupEditorController.saveRollupConfig";

export default class RollupEditor extends LightningElement {
  DEFAULT_ROLLUP_VALUES = { Active__c: false };
  @track
  rollup = this.DEFAULT_ROLLUP_VALUES;
  errors = {};

  _rollupName;
  @api
  async loadRollup(rollupName) {
    this.rollupName = rollupName;
  }

  get rollupName() {
    return this._rollupName;
  }
  set rollupName(val) {
    this._rollupName = val;

    this.getRollup();
  }

  connectedCallback() {
    this.getRollup();
  }

  get rollupCanBeActivated() {
    return this.rollup.Id && !this.rollup.Active__c;
  }

  get rollupCanBeDeactivated() {
    return this.rollup.Id && this.rollup.Active__c;
  }

  async getRollup() {
    if (!this.rollupName) {
      this.rollup = this.DEFAULT_ROLLUP_VALUES;
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

  cancelClickHandler() {
    this.rollupName = undefined;
  }

  cloneClickHandler() {
    this.rollup.DeveloperName = undefined;
    this.rollup.Id = undefined;
  }

  deleteClickHandler() {
    const evt = new CustomEvent("requestdelete", {
      detail: { rollupName: this.rollup.DeveloperName }
    });
    this.dispatchEvent(evt);
    this.rollupName = undefined;
  }

  activateClickHandler() {
    this.rollup.Active__c = true;
    this.runSave();
  }

  deactivateClickHandler() {
    this.rollup.Active__c = false;
    this.runSave();
  }

  async runSave() {
    this.assembleRollupFromForm();
    await this.runValidate();
    if (Object.keys(this.errors).length > 0) {
      console.error("Record has errors", this.errors);
      return;
    }
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

  assembleRollupFromForm() {
    this.rollup.Label = this.template.querySelector(
      '[data-name="rollup_label"]'
    ).value;
    this.rollup.DeveloperName = this.template.querySelector(
      '[data-name="rollup_DeveloperName"]'
    ).value;
    this.rollup.RelationshipField__c = this.template.querySelector(
      '[data-name="rollup_relationship_field"]'
    ).value;
    this.rollup.RelationshipCriteria__c = this.template.querySelector(
      '[data-name="rollup_relationship_criteria"]'
    ).value;
    this.rollup.RelationshipCriteriaFields__c = this.template.querySelector(
      '[data-name="rollup_relationship_criteria_fields"]'
    ).value;
    this.rollup.FieldToAggregate__c = this.template.querySelector(
      '[data-name="rollup_FieldToAggregate__c"]'
    ).value;
    this.rollup.AggregateOperation__c = this.template.querySelector(
      '[data-name="rollup_AggregateOperation__c"]'
    ).value;
    this.rollup.AggregateResultField__c = this.template.querySelector(
      '[data-name="rollup_AggregateResultField__c"]'
    ).value;
    this.rollup.AggregateAllRows__c = this.template.querySelector(
      '[data-name="rollup_AggregateAllRows__c"]'
    ).value;
    this.rollup.RowLimit__c = this.template.querySelector(
      '[data-name="rollup_RowLimit__c"]'
    ).value;
    this.rollup.ConcatenateDelimiter__c = this.template.querySelector(
      '[data-name="rollup_ConcatenateDelimiter__c"]'
    ).value;
  }
  childObjectSelected(event) {
    this.rollup.ChildObject__c = event.detail.selectedRecord;
  }
  parentObjectSelected(event) {
    this.rollup.ParentObject__c = event.detail.selectedRecord;
  }

  get rollupAsString() {
    return JSON.stringify(this.rollup, null, 2);
  }

  get errorsAsString() {
    return JSON.stringify(this.errors);
  }

  get aggregateOptions() {
    return [
      { label: "Sum", value: "Sum" },
      { label: "Max", value: "Max" },
      { label: "Min", value: "Min" },
      { label: "Avg", value: "Avg" },
      { label: "Count", value: "Count" },
      { label: "Count Distinct", value: "Count Distinct" },
      { label: "Concatenate", value: "Concatenate" },
      { label: "Concatenate Distinct", value: "	Concatenate Distinct" },
      { label: "First", value: "First" },
      { label: "Last", value: "Last" }
    ];
  }
}
