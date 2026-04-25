import { api, track } from "lwc";

import LightningModal from "lightning/modal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getRollupConfig from "@salesforce/apex/RollupEditorController.getRollupConfig";
import validateRollupConfig from "@salesforce/apex/RollupEditorController.validateRollupConfig";
import saveRollupConfig from "@salesforce/apex/RollupEditorController.saveRollupConfig";
import getFieldOptions from "@salesforce/apex/RollupEditorController.getFieldOptions";

import { buildApiName } from "c/utils";

const DEFAULT_ROLLUP_VALUES = Object.freeze({
  active: false,
  calculationMode: "Scheduled",
  calculationSharingMode: "System"
});

export const CLASS_SCHEDULER_CONFIG = {
  label: "Process Scheduled Items",
  description:
    "Manage RollupJob schedules to process all pending Scheduled Item records for all rollups",
  className: "RollupJob",
  size: "small",
  templates: [
    {
      label: "Once Every Day",
      value: "daily",
      selectors: ["single-hour"],
      presets: { hours: ["3"] }
    },
    {
      label: "Once Every Hour",
      value: "hourly",
      selectors: ["single-minute"]
    },
    {
      label: "Every 15 minutes",
      value: "every15",
      selectors: [],
      presets: { minutes: ["0", "15", "30", "45"] }
    }
  ]
};

export default class RollupEditor extends LightningModal {
  isLoading = false;
  rollupId;

  @track
  rollup = { ...DEFAULT_ROLLUP_VALUES };
  errors = {};

  @track
  parentRFieldOptions = [];

  @track
  childRFieldOptions = [];

  @track
  steps = [];

  get rollupName() {
    return this._rollupName;
  }
  @api
  set rollupName(val) {
    this._rollupName = val;
  }

  get cardHeader() {
    return this.rollup.id ? `Edit ${this.rollup.label}` : "New Rollup";
  }

  get saveButtonLabel() {
    return this.rollup.id ? "Save" : "Create";
  }

  async connectedCallback() {
    await this.getRollup();
  }

  get relationshipCriteriaPlaceholder() {
    return "Example_Field1__c\r\nExample_Field2__c";
  }

  get childFieldOptionsPending() {
    return this.childRFieldOptions.length === 0;
  }

  get parentFieldOptionsPending() {
    return this.parentRFieldOptions.length === 0;
  }

  async getRollup() {
    if (!this.rollupName) {
      this.rollup = { ...DEFAULT_ROLLUP_VALUES };
    } else {
      try {
        this.rollup = window.sessionStorage.getItem(this.rollupName);
        if (this.rollup) {
          window.sessionStorage.removeItem(this.rollupName);
          this.rollup = JSON.parse(this.rollup);
        } else {
          // necessary to prevent HTML from trying to access a null object
          this.rollup = { ...DEFAULT_ROLLUP_VALUES };
          this.rollup = await getRollupConfig({
            rollupName: this.rollupName
          });
        }

        this.rollupId = this.rollup.id;
        this.setImpliedRelationshipCriteriaFields();
      } catch (error) {
        this.errors.record = [error.message];
      }
    }
    await this.getRelationshipFieldOptions();
  }

  async getRelationshipFieldOptions() {
    await this.getParentRelationshipFieldOptions();
    await this.getChildRelationshipFieldOptions();
  }

  async getParentRelationshipFieldOptions() {
    if (this.rollup.parentObject) {
      this.parentRFieldOptions = (
        await getFieldOptions({
          objectName: this.rollup.parentObject
        })
      ).sort((a, b) => a.label.localeCompare(b.label));
    } else {
      this.parentRFieldOptions = [];
    }
  }

  async getChildRelationshipFieldOptions() {
    if (this.rollup.childObject) {
      this.childRFieldOptions = (
        await getFieldOptions({
          objectName: this.rollup.childObject
        })
      ).sort((a, b) => a.label.localeCompare(b.label));
    } else {
      this.childRFieldOptions = [];
    }
  }

  async runValidate() {
    this.errors = await validateRollupConfig({
      rollup: JSON.stringify(this.rollup)
    });
  }

  cancelClickHandler() {
    this.close();
  }

  rollupTypeChangeHandler(event) {
    this.rollup.aggregateOperation = event.detail.value;
  }

  onLabelBlurHandler(event) {
    const devNameElem = this.template.querySelector(
      '[data-name="rollup_developerName"]'
    );
    if (!devNameElem || devNameElem.value.trim().length > 0) {
      return;
    }
    this.rollup.developerName = this._makeApiSafe(event.currentTarget.value);
    devNameElem.value = this.rollup.developerName;
  }

  relationshipFieldSelectedHandler(event) {
    this.rollup.relationshipField = event.detail?.selectedOption.value;
    this.setImpliedRelationshipCriteriaFields();
    const refs = event.detail?.selectedOption?.referencesTo;
    if (refs && refs.length === 1) {
      this.rollup.parentObject = refs[0];
      this.rollup.aggregateResultField = undefined;
      this.getParentRelationshipFieldOptions();
    }
  }

  selectFieldToAggregate(event) {
    this.rollup.fieldToAggregate = event.detail.selectedOption.value;
    this.setImpliedRelationshipCriteriaFields();
  }

  calculationModeChangeHandler(event) {
    this.rollup.calculationMode = event.detail.value;
  }

  _makeApiSafe(val) {
    return val.replace(/^([0-9])/, "X$1").replace(/[^0-9a-zA-Z]+/g, "_");
  }

  async runSave() {
    if (!this.assembleRollupFromForm()) {
      console.error("data form is invalid");
      return;
    }
    this.isLoading = true;
    await this.runValidate();
    if (Object.keys(this.errors).length > 0) {
      console.error("Record has errors", this.errors);
      this.isLoading = false;
      return;
    }
    const deploymentId = await saveRollupConfig({
      rollup: JSON.stringify(this.rollup)
    });
    this.refs.deploymentMonitor.monitorDeployment(deploymentId);

    this.dispatchEvent(
      new ShowToastEvent({
        title: "Deployment Started",
        message: `Started deployment for ${this.rollup.label}`,
        variant: "info"
      })
    );
  }

  handleDeploymentCompleted(event) {
    this.isLoading = false;
    if (!event.detail.deployResult.success) {
      console.error("Deployment failed", event.detail.deployResult);
      return;
    }

    this.close({
      action: "navigate",
      config: {
        type: "standard__component",
        attributes: {
          componentName: buildApiName("rollupTab", true)
        },
        state: {
          c__rollupName: this.rollup.developerName
        }
      }
    });
  }

  assembleRollupFromForm() {
    const fieldNames = [
      "label",
      "developerName",
      "description",
      "relationshipField",
      "relationshipCriteria",
      "relationshipCriteriaFields",
      "fieldToAggregate",
      "fieldToOrderBy",
      "aggregateOperation",
      "aggregateResultField",
      "aggregateAllRows",
      "rowLimit",
      "active", // No Input Element for this field
      "calculationMode",
      "calculationSharingMode",
      "concatenateDelimiter",
      "testCode",
      "testCodeParent",
      "testCodeSeeAllData",
      "bypassPermissionApiName"
    ];

    let isValid = true;

    const checkboxFields = ["active", "aggregateAllRows", "testCodeSeeAllData"];

    fieldNames.forEach((fieldName) => {
      const inputElement = this.template.querySelector(
        `[data-name="rollup_${fieldName}"]`
      );
      if (inputElement) {
        if (inputElement.checkValidity) {
          if (!inputElement.checkValidity()) {
            isValid = false;

            // had a weird problem where I couldn't do multiple fields in the same loop, had to separate them
            // probably a better way to do this
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
              inputElement.reportValidity();
            }, 20);
          }
        }

        const attribute = checkboxFields.includes(fieldName)
          ? "checked"
          : "value";
        this.rollup[fieldName] = inputElement[attribute];
        if (
          typeof this.rollup[fieldName] == "string" &&
          this.rollup[fieldName].trim().length === 0
        ) {
          this.rollup[fieldName] = undefined;
        }
        console.log(`fieldName (${fieldName}) :  ${this.rollup[fieldName]}`);
      }
    });
    return isValid;
  }

  childObjectSelected(event) {
    this.rollup.childObject = event.detail.selectedRecord;
    this.getChildRelationshipFieldOptions();
    this.rollup.fieldToAggregate = undefined;
    this.rollup.relationshipField = undefined;
  }

  parentObjectSelected(event) {
    this.rollup.parentObject = event.detail.selectedRecord;
    this.getParentRelationshipFieldOptions();
    this.rollup.aggregateResultField = undefined;
  }

  relationshipCriteriaFieldSelectedHandler(event) {
    const apiName = event.detail?.selectedOption?.value;
    this.rollup.relationshipCriteriaFields += "\n" + apiName;

    event.target.value = "";
  }

  handlePillRemove(event) {
    const name = event.target.name;
    this.rollup.relationshipCriteriaFields =
      this.rollup.relationshipCriteriaFields
        .split("\n")
        .filter((val) => val.trim() !== name.trim())
        .join("\n");
  }

  setImpliedRelationshipCriteriaFields() {
    this.impliedRelationshipCriteriaFields = [];
    if (this.rollup.fieldToAggregate) {
      this.impliedRelationshipCriteriaFields.push({
        label: this.rollup.fieldToAggregate,
        name: this.rollup.fieldToAggregate,
        tooltip: "DLRS automatically monitors the Field to Aggregate"
      });
    }
    if (this.rollup.relationshipField) {
      this.impliedRelationshipCriteriaFields.push({
        label: this.rollup.relationshipField,
        name: this.rollup.relationshipField,
        tooltip: "DLRS automatically monitors the Relationship Field"
      });
    }
  }

  get relationshipCriteriaFieldsPills() {
    return [
      ...(this.rollup.relationshipCriteriaFields === undefined
        ? []
        : this.rollup.relationshipCriteriaFields?.split("\n").map((field) => ({
            label: field.trim(),
            name: field.trim()
          })))
    ];
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
      { label: "Concatenate Distinct", value: "Concatenate Distinct" },
      { label: "First", value: "First" },
      { label: "Last", value: "Last" }
    ];
  }

  get calculationModes() {
    return [
      { label: "Watch for Changes and Process Later", value: "Scheduled" },
      { label: "Realtime", value: "Realtime" },
      { label: "Invocable by Automation", value: "Process Builder" },
      { label: "Developer", value: "Developer" }
    ];
  }

  get calculationSharingModes() {
    return [
      { label: "User", value: "User" },
      { label: "System", value: "System" }
    ];
  }

  get shouldDisableConcatDelim() {
    return !["Concatenate", "Concatenate Distinct"].includes(
      this.rollup.aggregateOperation
    );
  }

  get shouldDisableFieldToOrderBy() {
    return !["Concatenate", "Concatenate Distinct", "First", "Last"].includes(
      this.rollup.aggregateOperation
    );
  }

  get shouldDisableRowLimit() {
    return !["Concatenate", "Concatenate Distinct", "Last"].includes(
      this.rollup.aggregateOperation
    );
  }

  get hasErrors() {
    return Object.keys(this.errors).length > 0;
  }
}
