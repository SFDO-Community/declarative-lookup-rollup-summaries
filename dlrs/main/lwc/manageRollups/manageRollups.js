import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningConfirm from "lightning/confirm";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";

import getAllRollupConfigs from "@salesforce/apex/RollupEditorController.getAllRollupConfigs";
import deleteRollupConfig from "@salesforce/apex/RollupEditorController.deleteRollupConfig";
import USER_ID from "@salesforce/user/Id";
import RollupEditor from "c/rollupEditor";
import ClassSchedulerModal from "c/classSchedulerModal";

// import so we can get a namespace from it
// can't import the Platform Event or CMDT directly
// because they get corrupted
import SCHEDULE_ITEMS_OBJECT from "@salesforce/schema/LookupRollupSummaryScheduleItems__c";

import {
  subscribe,
  unsubscribe,
  onError,
  isEmpEnabled
} from "lightning/empApi";

const STATUS_LABELS = {
  Scheduled: "Watch and Process",
  Realtime: "Realtime",
  "Process Builder": "Automatable",
  Developer: "Developer"
};

export default class ManageRollups extends NavigationMixin(LightningElement) {
  dtColumns = [
    {
      type: "button",
      label: "Name",
      sortable: true,
      fieldName: "label",
      initialWidth: 300,
      typeAttributes: {
        label: { fieldName: "label" },
        name: "rollup_select",
        title: "Edit",
        value: "edit",
        variant: "base",
        stretch: true
      }
    },
    {
      label: "Parent",
      fieldName: "parentObject",
      sortable: true
    },
    {
      label: "Child",
      fieldName: "childObject",
      sortable: true
    },
    {
      label: "Field To Aggregate",
      fieldName: "fieldToAggregate",
      sortable: true
    },
    {
      label: "Aggregate Result Field",
      fieldName: "aggregateResultField",
      sortable: true
    },
    {
      label: "Rollup Type",
      fieldName: "aggregateOperation",
      sortable: true
    },
    {
      label: "Calc Mode",
      fieldName: "calculationMode",
      sortable: true
    },
    {
      label: "Active",
      fieldName: "active",
      initialWidth: 75,
      type: "boolean",
      sortable: true
    },
    {
      type: "button-icon",
      initialWidth: 50,
      typeAttributes: {
        name: "rollup_delete",
        iconName: "action:delete",
        value: "delete",
        variant: "natrual"
      }
    }
  ];

  @wire(CurrentPageReference)
  pageRef;

  sortByField = "active";
  sortDirection = "desc";
  pendingSaveRollupName;

  channelName = `/event/${this._buildApiName("UserNotification__e")}`;
  subscription = {};

  rollups = {};
  rollupList = [];
  searchFilter = "";
  isLoading = true;
  selectedRollup = undefined;

  connectedCallback() {
    this.refreshRollups();
    // Register error listener
    this.registerErrorListener();
    this.handleSubscribe();
  }

  async refreshRollups() {
    this.isLoading = true;
    this.rollups = await getAllRollupConfigs();

    Object.keys(this.rollups).forEach((k) => {
      this.rollups[k] = {
        ...this.rollups[k],
        calculationMode:
          STATUS_LABELS[this.rollups[k].calculationMode] ??
          this.rollups[k].calculationMode
      };
    });

    if (this.rollups.length === 0) {
      // no rollups in the database, start to create a new one
      this.openEditor(null);
    }
    this.calcRollupList();
    this.isLoading = false;
  }

  calcRollupList() {
    this.rollupList = Object.values(this.rollups).filter((r) => {
      if (this.searchFilter.trim().length === 0) {
        return true;
      }
      for (const c of this.dtColumns) {
        if (
          r[c.fieldName] &&
          ("" + r[c.fieldName]).toLowerCase().indexOf(this.searchFilter) >= 0
        ) {
          return true;
        }
      }
      // didn't match any of the displayed fields
      return false;
    });
    this.rollupList.sort((a, b) => {
      const dirModifier = this.sortDirection === "asc" ? 1 : -1;
      const aVal = a[this.sortByField];
      const bVal = b[this.sortByField];
      let res = 0;
      if (typeof aVal === "boolean") {
        if (aVal) {
          // pull up
          res = 1;
        }
        if (bVal) {
          // pull down
          res = res - 1;
        }
      } else {
        res = aVal.localeCompare(bVal);
      }
      if (res === 0) {
        return a.label.localeCompare(b.label) * dirModifier;
      }

      return res * dirModifier;
    });
  }

  rollupSelectHandler(event) {
    const action = event.detail.action;
    const row = event.detail.row;
    switch (action.name) {
      case "rollup_select":
        this.openEditor(row.developerName);
        break;
      case "rollup_delete":
        this.requestDelete(row.developerName);
        break;
      default:
        throw new Error("unexpected action on rollupSelectHandler");
    }
  }

  async openEditor(rollupName) {
    const result = await RollupEditor.open({
      description: "Rollup Config Editor",
      rollupName
    });

    switch (result?.action) {
      case "delete":
        this.requestDelete(result.rollupName);
        break;
      case "deloyStart":
        this.isLoading = true;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Deployment Started",
            message:
              "Started Metadata Record Upates in Deployment " + result.jobId,
            variant: "info"
          })
        );
        this.pendingSaveRollupName = result.rollupName;
        break;
      case "navigate":
        this[NavigationMixin.Navigate](result.config);
        break;
      default:
        break;
    }
  }

  async requestDelete(rollupName) {
    const confirmed = await LightningConfirm.open({
      message: `Are you sure you want to delete the rollup named: ${rollupName}`,
      label: "Delete Rollup Configuration",
      theme: "warning"
    });
    if (confirmed) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Delete Started",
          message: `Started request to delete ${rollupName}`,
          variant: "info"
        })
      );
      this.isLoading = true;
      deleteRollupConfig({ rollupName: rollupName });
    }
  }

  runCreateNew() {
    this.openEditor(null);
  }

  async manageRollupJobSchedule() {
    await ClassSchedulerModal.open({
      label: "Schedule Rollup Job",
      description: "Scheduled RollupJob to process Scheduled Items",
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
    }).then((results) => {
      if (results) {
        try {
          const evt = new ShowToastEvent(results);
          this.dispatchEvent(evt);
        } catch (err) {
          // known issue with Lighting Locker can cause this to fail
          console.error("Failed to create toast with outcome", err);
        }
      }
    });
  }

  handleInputChange() {
    this.searchFilter = this.template
      .querySelector("lightning-input")
      .value.toLowerCase();
    this.calcRollupList();
  }

  handleRequestDelete(event) {
    this.requestDelete(event.detail.rollupName);
  }

  handleOnSort(event) {
    // The method onsort event handler
    this.sortByField = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    // assign the latest attribute with the sorted column fieldName and sorted direction
    this.calcRollupList();
  }

  disconnectedCallback() {
    this.handleUnsubscribe();
  }

  // Handles subscribe button click
  handleSubscribe() {
    if (!isEmpEnabled) {
      console.error("Emp API Is not currently enabled");
      return;
    }
    // Callback invoked whenever a new event message is received
    const messageCallback = (response) => {
      // console.log("New message received: ", JSON.stringify(response));
      // deployment probably changed the rollup definitions, should refresh
      this.isLoading = false;
      this.refreshRollups();
      if (
        !USER_ID.startsWith(
          response.data.payload[this._buildApiName("Recipient__c")]
        )
      ) {
        // This message isn't for us, don't do anything
        return;
      }
      let title, message, messageData, variant, mode;
      const deploymentData = JSON.parse(
        response.data.payload[this._buildApiName("Payload__c")]
      );

      switch (response.data.payload[this._buildApiName("Type__c")]) {
        case "DeleteRequestResult":
          this.pendingSaveRollupName = undefined;
          if (deploymentData.success) {
            title = "Delete Completed!";
            message = `${deploymentData.metadataNames} deleted successfully`;
            variant = "success";
            mode = "dismissible";
          } else {
            title = "Delete Failed!";
            message = `Attempt to delete ${deploymentData.metadataNames} returned with errors [${deploymentData.error}]`;
            variant = "error";
            mode = "sticky";
          }
          break;
        case "DeploymentResult":
          if (this.pendingSaveRollupName) {
            const pendingRollupName = this.pendingSaveRollupName;
            this.pendingSaveRollupName = undefined;
            this.openEditor(pendingRollupName);
          }
          if (deploymentData.status === "Succeeded") {
            title = "Deployment Completed!";
            message = "Metadata saved successfully";
            variant = "success";
            mode = "dismissible";
          } else {
            title = "Deployment Failed!";
            message =
              "Status of " +
              deploymentData.status +
              ", errors [" +
              deploymentData.details.componentFailures
                .map((failure) => `${failure.fullName}: ${failure.problem}`)
                .join("\n") +
              "], \n{0}";
            // if you know a better way to build this URL please replace this
            messageData = [
              {
                label: "Click to view Deployment",
                url: `/lightning/setup/DeployStatus/page?address=%2Fchangemgmt%2FmonitorDeploymentsDetails.apexp%3FasyncId%3D${deploymentData.id}`
              }
            ];
            variant = "error";
            mode = "sticky";
          }
          break;
        default:
          break;
      }

      const evt = new ShowToastEvent({
        title,
        message,
        messageData,
        variant,
        mode
      });
      this.dispatchEvent(evt);
      // Response contains the payload of the new message received
    };

    // Invoke subscribe method of empApi. Pass reference to messageCallback
    subscribe(this.channelName, -1, messageCallback).then((response) => {
      // Response contains the subscription information on subscribe call
      console.log("EmpAPI Subscribe", JSON.stringify(response));
      this.subscription = response;
    });
  }

  // Handles unsubscribe button click
  handleUnsubscribe() {
    // Invoke unsubscribe method of empApi
    unsubscribe(this.subscription, (response) => {
      console.log("unsubscribe() response: ", JSON.stringify(response));
      // Response is true for successful unsubscribe
    });
  }

  registerErrorListener() {
    // Invoke onError empApi method
    onError((error) => {
      console.error("Received error from server: ", JSON.stringify(error));
      // Error contains the server-side error
    });
  }

  // use an imported API name and swap parts to apply namespace to other API names that we can't import correctly
  _buildApiName(value) {
    return SCHEDULE_ITEMS_OBJECT.objectApiName.replace(
      "LookupRollupSummaryScheduleItems__c",
      value
    );
  }
}
