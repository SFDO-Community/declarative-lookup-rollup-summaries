import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import LightningConfirm from "lightning/confirm";

import { PATH_STATES } from "c/flexiblePath";
import ClassSchedulerModal from "c/classSchedulerModal";
import ManageChildTriggersModal from "c/manageChildTriggersModal";
import { buildApiName } from "c/utils";

import getScheduledJobs from "@salesforce/apex/LookupRollupStatusCheckController.getScheduledJobs";
import hasChildTriggerDeployed from "@salesforce/apex/LookupRollupStatusCheckController.hasChildTriggerDeployed";
import getFullCalculatePageUrl from "@salesforce/apex/RollupEditorController.getFullCalculatePageUrl";
import getScheduleCalculatePageUrl from "@salesforce/apex/RollupEditorController.getScheduleCalculatePageUrl";
import deleteRollupConfig from "@salesforce/apex/RollupEditorController.deleteRollupConfig";

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
    nextActionLabel: "Activate",
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

export default class RollupRecordHeader extends NavigationMixin(
  LightningElement
) {
  _rollup;
  @api
  set rollup(val) {
    this._rollup = val;
    this.configureSteps();
  }
  get rollup() {
    return this._rollup;
  }

  breadcrumbManageLink;
  get breadcrumbName() {
    return this.rollup?.label;
  }

  @track
  steps = [];

  connectedCallback() {
    this[NavigationMixin.GenerateUrl]({
      type: "standard__navItemPage",
      attributes: {
        apiName: buildApiName("ManageLookupRollupSummaries2")
      }
    }).then((url) => {
      this.breadcrumbManageLink = url;
    });
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
        if (this.childTriggerIsDeployed) {
          s.status = PATH_STATES.complete;
        } else if (this.rollup.active) {
          s.status = PATH_STATES.failed;
        } else {
          s.status = PATH_STATES.incomplete;
        }
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

  breadcrumbManageLinkClickHandler(event) {
    event.preventDefault();
    this[NavigationMixin.Navigate]({
      type: "standard__navItemPage",
      attributes: {
        apiName: buildApiName("ManageLookupRollupSummaries2")
      }
    });
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

  handleEditClick() {
    this.dispatchEvent(new CustomEvent("editclick"));
  }

  get activationIsDisabled() {
    // if rollup requires a trigger but that trigger isn't installed
    if (["Realtime", "Scheduled"].includes(this.rollup.calculationMode)) {
      return !this.childTriggerIsDeployed;
    }
    return false;
  }

  get rollupIsInactive() {
    return this.rollup.id && !this.rollup.active;
  }

  get rollupCanBeDeactivated() {
    return this.rollup.id && this.rollup.active;
  }

  async schedulRecalculateHandler() {
    const url = await getScheduleCalculatePageUrl({ rollupId: this.rollup.id });
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url
      }
    });
  }

  async manageTriggerHandler() {
    const result = await ManageChildTriggersModal.open({
      rollupName: this.rollup.developerName
    });
    console.log(result);
  }

  async recalculateNowHandler() {
    const url = await getFullCalculatePageUrl({ rollupId: this.rollup.id });
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url
      }
    });
  }

  get supportsTrigger() {
    return (
      this.rollup.id &&
      ["Scheduled", "Realtime"].includes(this.rollup.calculationMode)
    );
  }

  activateClickHandler() {
    if (this.rollupIsInactive && !this.activationIsDisabled) {
      this.dispatchEvent(new CustomEvent("startactivation"));
    } else {
      console.log("Unable to activate rollup");
    }
  }

  deactivateClickHandler() {
    this.dispatchEvent(new CustomEvent("startdeactivation"));
  }

  deleteClickHandler() {
    this.requestDelete();
  }

  async requestDelete() {
    const confirmed = await LightningConfirm.open({
      message: `Are you sure you want to delete the rollup named: ${this.rollup.developerName}`,
      label: "Delete Rollup Configuration",
      theme: "warning"
    });
    if (confirmed) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Delete Started",
          message: `Started request to delete ${this.rollup.developerName}`,
          variant: "info"
        })
      );
      this.isLoading = true;
      deleteRollupConfig({ rollupName: this.rollup.developerName });
    }
  }
}
