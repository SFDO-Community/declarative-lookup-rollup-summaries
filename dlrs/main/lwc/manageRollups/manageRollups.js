import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningConfirm from "lightning/confirm";
import getAllRollupConfigs from "@salesforce/apex/RollupEditorController.getAllRollupConfigs";
import deleteRollupConfig from "@salesforce/apex/RollupEditorController.deleteRollupConfig";
import USER_ID from "@salesforce/user/Id";

import {
  subscribe,
  unsubscribe,
  onError,
  isEmpEnabled
} from "lightning/empApi";

export default class ManageRollups extends LightningElement {
  dtColumns = [
    {
      label: "Name",
      fieldName: "Label"
    },
    {
      label: "Parent",
      fieldName: "ParentObject__c"
    },
    {
      label: "Field To Aggregate",
      fieldName: "FieldToAggregate__c"
    },
    {
      label: "Child",
      fieldName: "ChildObject__c"
    },
    {
      label: "Relationship Field",
      fieldName: "RelationshipField__c"
    },
    {
      label: "Operation",
      fieldName: "AggregateOperation__c"
    },
    {
      label: "Mode",
      fieldName: "CalculationMode__c"
    },
    {
      label: "Active",
      fieldName: "Active__c"
    },
    {
      type: "action",
      typeAttributes: {
        rowActions: [
          { label: "Edit", name: "rollup_select" },
          { label: "Delete", name: "rollup_delete" }
        ]
      }
    }
  ];

  // We only want events for which we've been assigned as the recipient
  channelName = `/event/UserNotification__e?Recipient__c='${USER_ID.substring(
    1,
    15
  )}'`;
  subscription = {};

  rollups = {};
  rollupList = [];
  searchFilter = "";
  selectedRollup = undefined;

  connectedCallback() {
    this.refreshRollups();
    // Register error listener
    this.registerErrorListener();
    this.handleSubscribe();
  }

  async refreshRollups() {
    this.rollups = await getAllRollupConfigs();
    this.calcRollupList();
  }

  calcRollupList() {
    this.rollupList = Object.values(this.rollups).filter((r) => {
      if (this.searchFilter.trim().length === 0) {
        return true;
      }
      for (const c of this.dtColumns) {
        if (
          r[c.fieldName] &&
          "" + r[c.fieldName].toLowerCase().indexOf(this.searchFilter) >= 0
        ) {
          return true;
        }
      }
      // didn't match any of the displayed fields
      return false;
    });
  }

  rollupSelectHandler(event) {
    const action = event.detail.action;
    const row = event.detail.row;
    switch (action.name) {
      case "rollup_select":
        this.template
          .querySelector("c-rollup-editor")
          .loadRollup(row.DeveloperName);
        break;
      case "rollup_delete":
        this.requestDelete(row.DeveloperName);
        break;
      default:
        throw new Error("unexpected action on rollupSelectHandler");
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
      deleteRollupConfig({ rollupName: rollupName });
    }
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
      this.refreshRollups();
      if (!USER_ID.startsWith(response.data.payload.Recipient__c)) {
        // This message isn't for us, don't do anything
        return;
      }
      let title, message, messageData, variant, mode;
      const deploymentData = JSON.parse(response.data.payload.Payload__c);

      switch (response.data.payload.Type__c) {
        case "DeleteRequestResult":
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
      this.subscription = response;
    });
  }

  // Handles unsubscribe button click
  handleUnsubscribe() {
    // Invoke unsubscribe method of empApi
    unsubscribe(this.subscription, (/*response*/) => {
      // console.log("unsubscribe() response: ", JSON.stringify(response));
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
}
