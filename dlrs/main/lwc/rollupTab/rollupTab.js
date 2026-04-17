import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";

import RollupEditor, { CLASS_SCHEDULER_CONFIG } from "c/rollupEditor";
import ClassSchedulerModal from "c/classSchedulerModal";

import userNotification from "@salesforce/messageChannel/UserNotification__c";
import getRollupConfig from "@salesforce/apex/RollupEditorController.getRollupConfig";
import saveRollupConfig from "@salesforce/apex/RollupEditorController.saveRollupConfig";

export default class RollupTab extends NavigationMixin(LightningElement) {
  currentPageRef;
  rollupName;
  rollup;
  isLoading = false;

  @wire(MessageContext)
  messageContext;

  @wire(CurrentPageReference)
  updateCurrentPageRef(newPageRef) {
    this.currentPageRef = newPageRef;
    this.rollupName = this.currentPageRef.state.c__rollupName;
    this.getRollup();
  }

  connectedCallback() {
    this.subscribeToMessageChannel();
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  subscribeToMessageChannel() {
    // Handler for message received by component
    const handleMessage = (message) => {
      if (message.type !== "DeploymentResult") {
        return;
      }
      if (message.payload === undefined) {
        return;
      }

      const res = JSON.parse(message.payload);

      if (Array.isArray(res)) {
        return;
      }

      switch (message.type) {
        case "DeploymentResult":
          if (res.done && res.success) {
            // there was a deployment that might impact us, refresh the data
            this.getRollup();
          }
          break;
        default:
          break;
      }
    };

    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        userNotification,
        (message) => handleMessage(message),
        { scope: APPLICATION_SCOPE }
      );
    }
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
