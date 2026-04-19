import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import {
  subscribe,
  unsubscribe,
  MessageContext
} from "lightning/messageService";

import RollupEditor, { CLASS_SCHEDULER_CONFIG } from "c/rollupEditor";
import ClassSchedulerModal from "c/classSchedulerModal";
import { buildApiName } from "c/utils";

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
      if (message.payload === undefined) {
        return;
      }

      const res = JSON.parse(message.payload);

      if (Array.isArray(res)) {
        return;
      }

      let title, msg, messageData, variant, mode;

      switch (message.type) {
        case "DeploymentResult":
          if (res.done && res.success) {
            if (res.id === this.lastSuccessfullDeployment) {
              // we've already reacted to this, ignoring it
              return;
            }
            this.lastSuccessfullDeployment = res.id;
            // there was a deployment that might impact us, refresh the data
            this.getRollup();
          }
          break;
        case "DeleteRequestResult":
          if (res.success) {
            this[NavigationMixin.Navigate]({
              type: "standard__navItemPage",
              attributes: {
                apiName: buildApiName("ManageLookupRollupSummaries2")
              }
            });

            title = "Delete Completed!";
            msg = `${res.metadataNames} deleted successfully`;
            variant = "success";
            mode = "dismissible";
          } else {
            title = "Delete Failed!";
            msg = `Attempt to delete ${res.metadataNames} returned with errors [${res.error}]`;
            variant = "error";
            mode = "sticky";
          }
          break;
        default:
          break;
      }

      const evt = new ShowToastEvent({
        title,
        message: msg,
        messageData,
        variant,
        mode
      });
      this.dispatchEvent(evt);
    };

    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        userNotification,
        (message) => handleMessage(message),
        {}
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
  }

  cloneClickHandler() {
    delete this.rollup.developerName;
    delete this.rollup.id;
    this.rollupId = undefined;
    this.errors = {};
  }
}
