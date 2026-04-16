import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import USER_ID from "@salesforce/user/Id";

import RollupEditor, { CLASS_SCHEDULER_CONFIG } from "c/rollupEditor";
import ClassSchedulerModal from "c/classSchedulerModal";
import { buildApiName } from "c/utils";

import getRollupConfig from "@salesforce/apex/RollupEditorController.getRollupConfig";
import saveRollupConfig from "@salesforce/apex/RollupEditorController.saveRollupConfig";

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

  channelName = `/event/${buildApiName("UserNotification__e")}`;

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
    // TODO: change to using the LMS instead of directly subscribing to the PE
    if (!isEmpEnabled) {
      console.error("Emp API Is not currently enabled");
      return;
    }
    // Callback invoked whenever a new event message is received
    const messageCallback = (response) => {
      // deployment probably changed the rollup definitions, should refresh
      if (
        !USER_ID.startsWith(response.data.payload[buildApiName("Recipient__c")])
      ) {
        // This message isn't for us, don't do anything
        return;
      }
      const deploymentData = JSON.parse(
        response.data.payload[buildApiName("Payload__c")]
      );

      switch (response.data.payload[buildApiName("Type__c")]) {
        case "DeploymentResult":
          if (deploymentData.done && deploymentData.success) {
            // there was a deployment that might impact us, refresh the data
            this.getRollup();
          }
          break;
        default:
          break;
      }
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
}
