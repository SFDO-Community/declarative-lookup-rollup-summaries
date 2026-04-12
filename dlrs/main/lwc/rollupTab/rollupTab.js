import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import USER_ID from "@salesforce/user/Id";

import RollupEditor, { CLASS_SCHEDULER_CONFIG } from "c/rollupEditor";
import ClassSchedulerModal from "c/classSchedulerModal";

import getRollupConfig from "@salesforce/apex/RollupEditorController.getRollupConfig";
import saveRollupConfig from "@salesforce/apex/RollupEditorController.saveRollupConfig";

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

export default class RollupTab extends NavigationMixin(LightningElement) {
  currentPageRef;
  rollupName;
  rollup;
  isLoading = false;

  channelName = `/event/${this._buildApiName("UserNotification__e")}`;

  @wire(CurrentPageReference)
  updateCurrentPageRef(newPageRef) {
    this.currentPageRef = newPageRef;
    this.rollupName = this.currentPageRef.state.c__rollupName;
    this.getRollup();
  }

  connectedCallback() {
    // Register error listener
    this.registerErrorListener();
    this.handleSubscribe();
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
      this.getRollup();
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
            this[NavigationMixin.Navigate]({
              type: "standard__navItemPage",
              attributes: {
                apiName: this._buildApiName("ManageLookupRollupSummaries2")
              }
            });
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

          if (this.pendingSaveRollupName) {
            let pendingRollupName = this.pendingSaveRollupName;
            if (deploymentData.status !== "Succeeded") {
              // allows for recovery of non-saved rollup editor state
              pendingRollupName = "pending-" + pendingRollupName;
            }
            this.pendingSaveRollupName = undefined;
            this.openEditor(pendingRollupName);
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

  async getRollup() {
    this.isLoading = true;
    try {
      this.rollup = await getRollupConfig({
        rollupName: this.rollupName
      });

      this.rollupId = this.rollup.id;
    } catch (error) {
      this.errors.record = [error.message];
    }
    this.isLoading = false;
  }

  async editRollupClickHandler() {
    const result = await RollupEditor.open({
      description: "Rollup Config Editor",
      rollupName: this.rollupName
    });

    switch (result?.action) {
      case "deloyStart":
        this.isLoading = true;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Deployment Started",
            message:
              "Started Metadata Record Updates in Deployment " + result.jobId,
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

  async manageRollupJobSchedule() {
    await ClassSchedulerModal.open(CLASS_SCHEDULER_CONFIG).then((results) => {
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

  startActivation() {
    this.runSave({ ...this.rollup, active: true });
  }

  startDeactivation() {
    this.runSave({ ...this.rollup, active: false });
  }

  async runSave(rollup) {
    this.isLoading = true;
    const jobId = await saveRollupConfig({
      rollup: JSON.stringify(rollup)
    });
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Deployment Started",
        message: "Started Metadata Record Updates in Deployment " + jobId,
        variant: "info"
      })
    );
    this.pendingSaveRollupName = this.rollup.developerName;
  }

  cloneClickHandler() {
    delete this.rollup.developerName;
    delete this.rollup.id;
    this.rollupId = undefined;
    this.errors = {};
  }

  // use an imported API name and swap parts to apply namespace to other API names that we can't import correctly
  _buildApiName(value, useDefaultNamespace = false) {
    let apiName = SCHEDULE_ITEMS_OBJECT.objectApiName;
    if (useDefaultNamespace) {
      if (apiName === "LookupRollupSummaryScheduleItems__c") {
        apiName = "c__LookupRollupSummaryScheduleItems__c";
      }
    }
    return apiName.replace("LookupRollupSummaryScheduleItems__c", value);
  }
}
