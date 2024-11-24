import { api, track, wire } from "lwc";

import LightningModal from "lightning/modal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { PATH_STATES } from "c/flexiblePath";

import getRollupConfig from "@salesforce/apex/RollupEditorController.getRollupConfig";
import validateRollupConfig from "@salesforce/apex/RollupEditorController.validateRollupConfig";
import saveRollupConfig from "@salesforce/apex/RollupEditorController.saveRollupConfig";
import getFieldOptions from "@salesforce/apex/RollupEditorController.getFieldOptions";
import getManageTriggerPageUrl from "@salesforce/apex/RollupEditorController.getManageTriggerPageUrl";
import getFullCalculatePageUrl from "@salesforce/apex/RollupEditorController.getFullCalculatePageUrl";
import getScheduleCalculatePageUrl from "@salesforce/apex/RollupEditorController.getScheduleCalculatePageUrl";
import hasChildTriggerDeployed from "@salesforce/apex/LookupRollupStatusCheckController.hasChildTriggerDeployed";
import getScheduledFullCalculates from "@salesforce/apex/LookupRollupStatusCheckController.getScheduledFullCalculates";
import getScheduledJobs from "@salesforce/apex/LookupRollupStatusCheckController.getScheduledJobs";
import getOutstandingScheduledItemsForLookup from "@salesforce/apex/LookupRollupStatusCheckController.getOutstandingScheduledItemsForLookup";
import ClassSchedulerModal from "c/classSchedulerModal";

const DEFAULT_ROLLUP_VALUES = Object.freeze({
  active: false,
  calculationMode: "Scheduled",
  calculationSharingMode: "System"
});

const STEPS = Object.freeze({
  configure: {
    label: "Configure",
    name: "save",
    nextActionLabel: "Save",
    status: PATH_STATES.complete
  },
  schedule: {
    label: "Schedule Job",
    name: "scheduleJob",
    nextActionLabel: "Schedule",
    status: PATH_STATES.incomplete
  },
  trigger: {
    label: "Deploy Trigger",
    name: "deployTrigger",
    nextActionLabel: "Manage Triggers",
    status: PATH_STATES.incomplete
  },
  activate: {
    label: "Activate",
    name: "activate",
    nextActionLabel: "Save & Activate",
    status: PATH_STATES.incomplete
  }
});

const STEP_TEMPLATES = Object.freeze({
  Realtime: [STEPS.configure, STEPS.trigger, STEPS.activate],
  Scheduled: [STEPS.configure, STEPS.schedule, STEPS.trigger, STEPS.activate],
  other: [STEPS.configure, STEPS.activate]
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
  childTriggerIsDeployed = false;
  rollupId;
  nextFullCalculateAt = "";

  @wire(getOutstandingScheduledItemsForLookup, { lookupID: "$rollupId" })
  outstandingScheduledItems;

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

  get rollupCanBeActivated() {
    return this.rollup.id && !this.rollup.active;
  }

  get rollupCanBeDeactivated() {
    return this.rollup.id && this.rollup.active;
  }

  get scheduledItemsIcon() {
    if (!this.rollup.id || !this.outstandingScheduledItems?.data) {
      return "";
    }

    return "utility:warning";
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
        this.nextFullCalculateAt = await getScheduledFullCalculates({
          lookupID: this.rollupId
        });
      } catch (error) {
        this.errors.record = [error.message];
      }
    }
    this.configureSteps();
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

  async configureSteps() {
    const newSteps = [];
    const scheduledJobCount = await getScheduledJobs();
    this.childTriggerIsDeployed = await hasChildTriggerDeployed({
      lookupID: this.rollup.id
    });
    for (let s of STEP_TEMPLATES[this.rollup.calculationMode] ||
      STEP_TEMPLATES.other) {
      if (s.name === "deployTrigger") {
        s.status = this.childTriggerIsDeployed
          ? PATH_STATES.complete
          : PATH_STATES.incomplete;
      }
      if (s.name === "scheduleJob") {
        s.status =
          scheduledJobCount > 0 ? PATH_STATES.complete : PATH_STATES.incomplete;
      }
      if (s.name === "activate") {
        s.status = this.rollup.active
          ? PATH_STATES.complete
          : PATH_STATES.incomplete;
      }
      newSteps.push(s);
    }

    // mark first incomplete as current
    const firstIncomplete = newSteps.find(
      (s) => s.status === PATH_STATES.incomplete
    );
    if (firstIncomplete) {
      firstIncomplete.status = PATH_STATES.current;
    }

    this.steps = newSteps;
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

  cloneClickHandler() {
    delete this.rollup.developerName;
    delete this.rollup.id;
    this.rollupId = undefined;
    this.errors = {};
  }

  deleteClickHandler() {
    this.close({ action: "delete", rollupName: this.rollup.developerName });
  }

  activateClickHandler() {
    this.rollup.active = true;
    this.runSave();
  }

  deactivateClickHandler() {
    this.rollup.active = false;
    this.runSave();
  }

  rollupTypeChangeHandler(event) {
    this.rollup.aggregateOperation = event.detail.value;
  }

  async pathClickHandler(event) {
    console.log("Path clicked", event.detail.label);
    switch (event.detail.name) {
      case "deployTrigger":
        this.manageTriggerHandler();
        break;
      case "activate":
        this.activateClickHandler();
        break;
      case "scheduleJob":
        await ClassSchedulerModal.open(CLASS_SCHEDULER_CONFIG).then(
          (results) => {
            if (results) {
              try {
                const evt = new ShowToastEvent(results);
                this.dispatchEvent(evt);
              } catch (err) {
                // known issue with Lighting Locker can cause this to fail
                console.error("Failed to create toast with outcome", err);
              }
            }
          }
        );
        // recalculate Path after Schedule is created
        this.configureSteps();
        break;
      case "save":
        this.runSave();
        break;
      default:
        console.error("Unexpected action", event.detail.label);
        break;
    }
  }

  async manageTriggerHandler() {
    const url = await getManageTriggerPageUrl({ rollupId: this.rollup.id });
    this.close({
      action: "navigate",
      config: {
        type: "standard__webPage",
        attributes: {
          url
        }
      }
    });
  }

  async recalculateNowHandler() {
    const url = await getFullCalculatePageUrl({ rollupId: this.rollup.id });
    this.close({
      action: "navigate",
      config: {
        type: "standard__webPage",
        attributes: {
          url
        }
      }
    });
  }

  async schedulRecalculateHandler() {
    const url = await getScheduleCalculatePageUrl({ rollupId: this.rollup.id });
    this.close({
      action: "navigate",
      config: {
        type: "standard__webPage",
        attributes: {
          url
        }
      }
    });
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
    console.log("Relationship Field Selected", event.detail.selectedOption);
    const refs = event.detail?.selectedOption?.referencesTo;
    if (refs && refs.length === 1) {
      this.rollup.parentObject = refs[0];
      this.rollup.aggregateResultField = undefined;
      this.getParentRelationshipFieldOptions();
    }
  }

  calculationModeChangeHandler(event) {
    this.rollup.calculationMode = event.detail.value;
    this.configureSteps();
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
      return;
    }
    const jobId = await saveRollupConfig({
      rollup: JSON.stringify(this.rollup)
    });

    try {
      window.sessionStorage.setItem(
        "pending-" + this.rollup.developerName,
        JSON.stringify(this.rollup)
      );
    } catch (err) {
      console.error("Error setting session storage", err);
    }

    this.close({
      action: "deloyStart",
      jobId,
      rollupName: this.rollup.developerName
    });
    this.isLoading = false;
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
    this.configureSteps();
  }

  parentObjectSelected(event) {
    this.rollup.parentObject = event.detail.selectedRecord;
    this.getParentRelationshipFieldOptions();
    this.rollup.aggregateResultField = undefined;
    this.configureSteps();
  }

  get supportsTrigger() {
    return (
      this.rollup.id &&
      ["Scheduled", "Realtime"].includes(this.rollup.calculationMode)
    );
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
