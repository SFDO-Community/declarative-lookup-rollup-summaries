import { api, track, wire } from "lwc";

import LightningModal from "lightning/modal";

import { PATH_STATES } from "c/flexiblePath";

import getRollupConfig from "@salesforce/apex/RollupEditorController.getRollupConfig";
import validateRollupConfig from "@salesforce/apex/RollupEditorController.validateRollupConfig";
import saveRollupConfig from "@salesforce/apex/RollupEditorController.saveRollupConfig";
import getFieldOptions from "@salesforce/apex/RollupEditorController.getFieldOptions";
import getManageTriggerPageUrl from "@salesforce/apex/RollupEditorController.getManageTriggerPageUrl";
import getFullCalculatePageUrl from "@salesforce/apex/RollupEditorController.getFullCalculatePageUrl";
import getScheduleCalculatePageUrl from "@salesforce/apex/RollupEditorController.getScheduleCalculatePageUrl";
import hasChildTriggerDeployed from "@salesforce/apex/LookupRollupStatusCheckController.hasChildTriggerDeployed";
import getScheduledJobs from "@salesforce/apex/LookupRollupStatusCheckController.getScheduledJobs";
import getOutstandingScheduledItemsForLookup from "@salesforce/apex/LookupRollupStatusCheckController.getOutstandingScheduledItemsForLookup";

const DEFAULT_ROLLUP_VALUES = Object.freeze({
  Active__c: false,
  CalculationMode__c: "Scheduled",
  CalculationSharingMode__c: "System"
});

const STEP_TEMPLATES = Object.freeze({
  default: [
    {
      label: "Configure",
      name: "save",
      nextActionLabel: "Save",
      status: PATH_STATES.current
    },
    { label: "...", status: PATH_STATES.incomplete }
  ],
  Realtime: [
    {
      label: "Configure",
      name: "save",
      nextActionLabel: "Save",
      status: PATH_STATES.complete
    },
    {
      label: "Deploy Trigger",
      name: "deployTrigger",
      nextActionLabel: "Manage Triggers",
      status: PATH_STATES.incomplete
    },
    { label: "Activate", name: "activate", status: PATH_STATES.incomplete }
  ],
  Scheduled: [
    {
      label: "Configure",
      name: "save",
      nextActionLabel: "Save",
      status: PATH_STATES.complete
    },
    {
      label: "Schedule Job",
      name: "scheduleJob",
      nextActionLabel: "Schedule",
      status: PATH_STATES.incomplete
    },
    {
      label: "Deploy Trigger",
      name: "deployTrigger",
      nextActionLabel: "Manage Triggers",
      status: PATH_STATES.incomplete
    },
    { label: "Activate", name: "activate", status: PATH_STATES.incomplete }
  ],
  other: [
    {
      label: "Configure",
      name: "save",
      nextActionLabel: "Save",
      status: PATH_STATES.complete
    },
    { label: "Activate", name: "activate", status: PATH_STATES.incomplete }
  ]
});
export default class RollupEditor extends LightningModal {
  isLoading = false;
  childTriggerIsDeployed = false;
  rollupId;

  @wire(getScheduledJobs)
  scheduledJobCount;

  @wire(getOutstandingScheduledItemsForLookup, { lookupID: "$rollupId" })
  outstandingScheduledItems;

  openAccordianSections = [
    "Information",
    "ChildObject",
    "ParentObject",
    "Relationship",
    "RollupDetails",
    "CalculationMode"
  ];

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
    this.errors = {}; // clear any existing error
    this._rollupName = val;
    this.getRollup();
  }

  get cardHeader() {
    return this.rollup.Id ? `Edit ${this.rollup.Label}` : "Create Rollup";
  }

  get saveButtonLabel() {
    return this.rollup.Id ? "Save" : "Create";
  }

  async connectedCallback() {
    await this.getRollup();
  }

  get rollupCanBeActivated() {
    return this.rollup.Id && !this.rollup.Active__c;
  }

  get rollupCanBeDeactivated() {
    return this.rollup.Id && this.rollup.Active__c;
  }

  get scheduledItemsError() {
    if (
      !this.outstandingScheduledItems ||
      !this.outstandingScheduledItems?.data
    ) {
      return null;
    }

    return `This rollup has ${this.outstandingScheduledItems} outstanding scheduled items`;
  }

  get relationshipCriteriaPlaceholder() {
    return "Status__c\r\nDays__c";
  }

  async getRollup() {
    if (!this.rollupName) {
      this.rollup = { ...DEFAULT_ROLLUP_VALUES };
    } else {
      try {
        this.rollup = await getRollupConfig({
          rollupName: this.rollupName
        });
        this.rollupId = this.rollup.Id;
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
    if (this.rollup.ParentObject__c) {
      this.parentRFieldOptions = await getFieldOptions({
        objectName: this.rollup.ParentObject__c
      });
    } else {
      this.parentRFieldOptions = [];
    }
  }

  async configureSteps() {
    const newSteps = [];
    if (!this.rollup?.Id) {
      for (let s of STEP_TEMPLATES.default) {
        newSteps.push(s);
      }
      this.steps = newSteps;
      return;
    }

    this.childTriggerIsDeployed = await hasChildTriggerDeployed({
      lookupID: this.rollup.Id
    });
    for (let s of STEP_TEMPLATES[this.rollup.CalculationMode__c] ||
      STEP_TEMPLATES.other) {
      if (s.name === "deployTrigger") {
        s.status = this.childTriggerIsDeployed
          ? PATH_STATES.complete
          : PATH_STATES.incomplete;
      }
      if (s.name === "scheduleJob") {
        s.status =
          this.scheduledJobCount.data > 0
            ? PATH_STATES.complete
            : PATH_STATES.incomplete;
      }
      if (s.name === "activate") {
        s.status = this.rollup.Active__c
          ? PATH_STATES.complete
          : PATH_STATES.incomplete;
      }
      newSteps.push(s);
    }

    // TODO: mark first incomplete as current
    // TODO: reorder to all complete are on left
    this.steps = newSteps;
    console.log("New Steps", JSON.stringify(this.steps));
  }

  async getChildRelationshipFieldOptions() {
    if (this.rollup.ChildObject__c) {
      this.childRFieldOptions = await getFieldOptions({
        objectName: this.rollup.ChildObject__c
      });
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
    this.rollup.DeveloperName = undefined;
    this.rollup.Id = undefined;
  }

  deleteClickHandler() {
    this.close({ action: "delete", rollupName: this.rollup.DeveloperName });
  }

  activateClickHandler() {
    this.rollup.Active__c = true;
    this.runSave();
  }

  deactivateClickHandler() {
    this.rollup.Active__c = false;
    this.runSave();
  }

  rollupTypeChangeHandler(event) {
    this.rollup.AggregateOperation__c = event.detail.value;
  }

  pathClickHandler(event) {
    console.log("Path clicked", event.detail.label);
    switch (event.detail.name) {
      case "deployTrigger":
        this.manageTriggerHandler();
        break;
      case "activate":
        this.activateClickHandler();
        break;
      case "scheduleJob":
        console.error("Job Schedule UI not implemented");
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
    const url = await getManageTriggerPageUrl({ rollupId: this.rollup.Id });
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
    const url = await getFullCalculatePageUrl({ rollupId: this.rollup.Id });
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
    const url = await getScheduleCalculatePageUrl({ rollupId: this.rollup.Id });
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
      '[data-name="rollup_DeveloperName"]'
    );
    if (!devNameElem || devNameElem.value.trim().length > 0) {
      return;
    }
    this.rollup.DeveloperName = this._makeApiSafe(event.currentTarget.value);
    devNameElem.value = this.rollup.DeveloperName;
  }

  relationshipFieldSelectedHandler(event) {
    console.log("Relationship Field Selected", event.detail.selectedOption);
    const refs = event.detail?.selectedOption?.referencesTo;
    if (refs && refs.length === 1) {
      this.rollup.ParentObject__c = refs[0];
      this.getParentRelationshipFieldOptions();
    }
  }

  _makeApiSafe(val) {
    return val.replace(/^([0-9])/, "X$1").replace(/[^0-9a-zA-Z]+/g, "_");
  }

  async runSave() {
    this.isLoading = true;
    this.assembleRollupFromForm();
    await this.runValidate();
    if (Object.keys(this.errors).length > 0) {
      console.error("Record has errors", this.errors);
      return;
    }
    const jobId = await saveRollupConfig({
      rollup: JSON.stringify(this.rollup)
    });

    this.close({
      action: "deloyStart",
      jobId,
      rollupName: this.rollup.DeveloperName
    });
    this.isLoading = false;
  }

  assembleRollupFromForm() {
    const fieldNames = [
      "Label",
      "DeveloperName",
      "Description__c",
      "RelationshipField__c",
      "RelationshipCriteria__c",
      "RelationshipCriteriaFields__c",
      "FieldToAggregate__c",
      "FieldToOrderBy__c",
      "AggregateOperation__c",
      "AggregateResultField__c",
      "AggregateAllRows__c",
      "RowLimit__c",
      "Active__c", // No Input Element for this field
      "CalculationMode__c",
      "CalculationSharingMode__c",
      "ConcatenateDelimiter__c",
      "TestCode2__c",
      "TestCodeParent__c",
      "TestCodeSeeAllData__c"
    ];

    const checkboxFields = [
      "Active__c",
      "AggregateAllRows__c",
      "TestCodeSeeAllData__c"
    ];

    fieldNames.forEach((fieldName) => {
      const inputElement = this.template.querySelector(
        `[data-name="rollup_${fieldName}"]`
      );
      if (inputElement) {
        const attribute = checkboxFields.includes(fieldName)
          ? "checked"
          : "value";
        this.rollup[fieldName] = inputElement[attribute];
        console.log(`fieldName (${fieldName}) :  ${inputElement[attribute]}`);
      }
    });
  }

  childObjectSelected(event) {
    this.rollup.ChildObject__c = event.detail.selectedRecord;
    this.getChildRelationshipFieldOptions();
  }

  parentObjectSelected(event) {
    this.rollup.ParentObject__c = event.detail.selectedRecord;
    this.getParentRelationshipFieldOptions();
  }

  get supportsTrigger() {
    return (
      this.rollup.Id &&
      ["Scheduled", "Realtime"].includes(this.rollup.CalculationMode__c)
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
      { label: "Queued Job", value: "Scheduled" },
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
      this.rollup.AggregateOperation__c
    );
  }

  get shouldDisableFieldToOrderBy() {
    return !["Concatenate", "Concatenate Distinct", "First", "Last"].includes(
      this.rollup.AggregateOperation__c
    );
  }

  get shouldDisableRowLimit() {
    return !["Concatenate", "Concatenate Distinct", "Last"].includes(
      this.rollup.AggregateOperation__c
    );
  }
}
