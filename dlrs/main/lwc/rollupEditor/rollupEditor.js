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
    const fieldNames = [
      'Label',
      'DeveloperName',
      'Description__c',
      'RelationshipField__c',
      'RelationshipCriteria__c',
      'RelationshipCriteriaFields__c',
      'FieldToAggregate__c',
      'FieldToOrderBy__c',
      'AggregateOperation__c',
      'AggregateResultField__c',
      'AggregateAllRows__c',
      'RowLimit__c',
      'Active__c', // No Input Element for this field
      'CalculationMode__c',
      'CalculationSharingMode__c',
      'ConcatenateDelimiter__c',
      'TestCode2__c',
      'TestCodeParent__c',
      'TestCodeSeeAllData__c'
    ];

    const checkboxFields = ['Active__c', 'AggregateAllRows__c', 'TestCodeSeeAllData__c'];

    fieldNames.forEach(fieldName => {
      const inputElement = this.template.querySelector(`[data-name="rollup_${fieldName}"]`);
      if(inputElement){
        const attribute = checkboxFields.includes(fieldName) ? 'checked' : 'value';
        this.rollup[fieldName] = inputElement[attribute];
      }
    })
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

  get calculationModes(){
    return [
      { label: "Realtime", value: "Realtime" },
      { label: "Scheduled", value: "Scheduled" },
      { label: "Developer", value: "Developer" },
      { label: "Process Builder", value: "Process Builder" },
    ];
  }

  get calculationSharingModes(){
    return [
      { label: "User", value: "User" },
      { label: "System", value: "System" }
    ];
  }

  onToggleSection(event){
    const sectionName = event.currentTarget.getAttribute('data-section-button');
    const element = this.template.querySelector(`[data-section-name="${sectionName}"]`);
    const expandClass = 'slds-is-open';
    if(element.className.includes(expandClass)){
      element.className = element.className.replace(expandClass, '');
    } else {
      element.className += ' ' + expandClass;
    }
  }

  onToggleButtonGroupList(){
    const elementName = 'expandable-button-list';
    const element = this.template.querySelector(`[data-name="${elementName}"]`);
    const expandClass = 'slds-is-open';
    if(element.className.includes(expandClass)){
      element.className = element.className.replace(expandClass, '');
    } else {
      element.className += ' ' + expandClass;
    }
  }


}
