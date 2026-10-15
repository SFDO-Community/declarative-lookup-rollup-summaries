/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {
  subscribe,
  unsubscribe,
  MessageContext
} from "lightning/messageService";

import userNotification from "@salesforce/messageChannel/UserNotification__c";
import requestDeploymentStatusCheck from "@salesforce/apex/DeploymentMonitorController.requestDeploymentStatusCheck";

// Subscribes to the deployment updates
// implements various strategies to request updates
// manages it's own timing for when and how it requests updates

const DEPLOYMENT_STATUS_LABELS = {
  Canceled: {
    value: "Canceled",
    label: "Canceled",
    description: "The queued deployment was canceled."
  },
  Canceling: {
    value: "Canceling",
    label: "Canceling",
    description: "The queued deployment is being canceled."
  },
  Failed: {
    value: "Failed",
    label: "Failed",
    description: "The deployment failed."
  },
  FinalizingDeploy: {
    value: "FinalizingDeploy",
    label: "Finalizing Deploy",
    description:
      "The deployment has started, and is in the finalizing state. Deployments in the state can't be canceled."
  },
  FinalizingDeployFailed: {
    value: "FinalizingDeployFailed",
    label: "Finalizing Deploy Failed",
    description: "The deployment failed during the finalizing state."
  },
  InProgress: {
    value: "InProgress",
    label: "In Progress",
    description: "The deployment has been started and is in progress."
  },
  Pending: {
    value: "Pending",
    label: "Pending",
    description: "The deployment has been queued but not started."
  },
  Succeeded: {
    value: "Succeeded",
    label: "Succeeded",
    description: "The deployment succeeded."
  },
  SucceededPartial: {
    value: "SucceededPartial",
    label: "Partially Succeeded",
    description:
      "The deployment succeeded, but some components might not have been successfully deployed. Check Metadata.DeployResult for more details."
  }
};

// when a deployment is finished, we should have a "countdown" that auto-dismisses when finishes
export default class DeploymentMonitor extends LightningElement {
  displayedProgressSteps = [
    DEPLOYMENT_STATUS_LABELS.Pending,
    DEPLOYMENT_STATUS_LABELS.InProgress,
    DEPLOYMENT_STATUS_LABELS.FinalizingDeploy,
    DEPLOYMENT_STATUS_LABELS.Succeeded
  ];

  @wire(MessageContext)
  messageContext;

  @api
  publishToastOnCompletion = false;

  @api
  spinnerOnly = false;

  _trackDeployments = false;
  @api
  set trackDeployments(value) {
    this._trackDeployments = value;
  }
  get trackDeployments() {
    return this._trackDeployments;
  }

  _deploymentId;
  @api
  set deploymentId(value) {
    this._deploymentId = value;
    this.monitorDeployment(this._deploymentId);
  }
  get deploymentId() {
    return this._deploymentId;
  }

  @api
  monitorDeployment(deploymentId) {
    this._trackDeployments = true;
    this.deploymentStatus = DEPLOYMENT_STATUS_LABELS.Pending.label;
    this._deploymentId = deploymentId;
    this.requestDeploymentUpdate();
  }

  deploymentStatus;
  deploymentDone = false;
  deploymentStateDetail;
  lastDeployResult;

  numberComponentsTotal = undefined;
  numberComponentErrors = undefined;
  numComponentSuccesses = undefined;

  numberTestsTotal = undefined;
  numberTestsCompleted = undefined;
  numberTestErrors = undefined;

  errorsByCategory = [];
  nextUpdateTimeout;

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
      if (this.trackDeployments !== true) {
        return;
      }

      switch (message.type) {
        case "DeploymentResult":
          this.processDeploymentRequest(message);
          break;
        case "DeleteRequestResult":
          this.processDeleteRequestResult(message);
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
        {}
      );
    }
  }

  async processDeploymentRequest(message) {
    if (message.payload === undefined) {
      return;
    }

    const res = JSON.parse(message.payload);

    if (Array.isArray(res)) {
      // Update status
      this.deploymentStatus = DEPLOYMENT_STATUS_LABELS.Failed.label;
      this.deploymentDone = true;
      // Update current state
      this.deploymentStateDetail = undefined;
      // Update errors of different types
      this.errorsByCategory = [];
      this.errorsByCategory.push({
        label: "Errors",
        errors: res.map((err) => err.message)
      });

      let title, variant, mode;

      title = "Deployment Failed!";
      variant = "error";
      mode = "sticky";

      const evt = new ShowToastEvent({
        title,
        variant,
        mode
      });
      this.dispatchEvent(evt);

      return;
    }

    this.lastDeployResult = res;
    this.writeDeploymentUpdate(res);
  }

  async processDeleteRequestResult(message) {
    if (message.payload === undefined) {
      return;
    }
    let title, toastMessage, variant, mode;
    const deleteRequest = JSON.parse(message.payload);
    if (deleteRequest.success) {
      this.deploymentStatus = DEPLOYMENT_STATUS_LABELS.Succeeded;
      title = "Delete Completed!";
      toastMessage = `${deleteRequest.metadataNames} deleted successfully`;
      variant = "success";
      mode = "dismissible";
    } else {
      // change the last step to match the final status
      this.displayedProgressSteps.pop();
      this.displayedProgressSteps.push(DEPLOYMENT_STATUS_LABELS.Failed);

      title = "Delete Failed!";
      toastMessage = `Attempt to delete ${deleteRequest.metadataNames} returned with errors [${deleteRequest.error}]`;
      variant = "error";
      mode = "sticky";
    }

    const evt = new ShowToastEvent({
      title,
      toastMessage,
      variant,
      mode
    });
    if (this.publishToastOnCompletion) {
      this.dispatchEvent(evt);
    }
    this.dispatchEvent(
      new CustomEvent("deploymentcompleted", { detail: { deleteRequest } })
    );
  }

  async requestDeploymentUpdate() {
    if (
      this.deploymentId === undefined ||
      this.deploymentId === null ||
      this.deploymentId.length < 15
    ) {
      return;
    }
    // kick off a Queueable that will perform check on the Deployment and report back via
    // Platform Event that we receive through the messaging channel
    requestDeploymentStatusCheck({
      deploymentId: this.deploymentId
    });
  }

  writeDeploymentUpdate(deployResult) {
    this._deploymentId = deployResult.id;

    // Update status
    this.deploymentStatus =
      DEPLOYMENT_STATUS_LABELS[deployResult.status]?.label ??
      deployResult.status;
    this.deploymentDone = deployResult.done;
    // Update current state
    this.deploymentStateDetail = deployResult.stateDetail;

    this.numberComponentsTotal = deployResult.numberComponentsTotal;
    this.numberComponentErrors = deployResult.numberComponentErrors;
    this.numComponentSuccesses =
      deployResult.details?.componentSuccesses?.filter(
        (cmp) => cmp.fullName !== "package.xml"
      ).length;

    this.numberTestsTotal = deployResult.numberTestsTotal;
    this.numberTestsCompleted = deployResult.numberTestsCompleted;
    this.numberTestErrors = deployResult.numberTestErrors;

    // Update errors of different types
    this.errorsByCategory = [];

    if (deployResult.details?.componentFailures?.length) {
      this.errorsByCategory.push({
        label: "Component Failures",
        errors: deployResult.details.componentFailures.map(
          (failure) => `${failure.fullName}: ${failure.problem}`
        )
      });
    }

    if (deployResult.details?.runTestResult?.codeCoverageWarnings?.length) {
      this.errorsByCategory.push({
        label: "Code Coverage Warnings",
        errors: deployResult.details.runTestResult.codeCoverageWarnings.map(
          (failure) => `${failure.name}: ${failure.message}`
        )
      });
    }
    if (deployResult.details?.runTestResult?.failures?.length > 0) {
      this.errorsByCategory.push({
        label: "Test Failures",
        errors: deployResult.details.runTestResult.failures.map(
          (testRes) => `${testRes.name}: ${testRes.message}`
        )
      });
    }

    if (!deployResult.done) {
      clearTimeout(this.nextUpdateTimeout);
      // queue the next update request
      setTimeout(() => {
        this.requestDeploymentUpdate();
      }, 3000);

      this.dispatchEvent(
        new CustomEvent("deploymentupdate", { detail: { deployResult } })
      );
      return;
    }

    // change the last step to match the final status
    this.displayedProgressSteps.pop();
    this.displayedProgressSteps.push(
      DEPLOYMENT_STATUS_LABELS[deployResult.status]
    );

    let title, message, messageData, variant, mode;
    if (deployResult.success) {
      title = "Deployment Completed!";
      message = "Metadata saved successfully";
      variant = "success";
      mode = "dismissible";
    } else {
      title = "Deployment Failed!";
      message = "{0}";
      // if you know a better way to build this URL please replace this
      messageData = [
        {
          label: "Click to view Deployment",
          url: `/lightning/setup/DeployStatus/page?address=%2Fchangemgmt%2FmonitorDeploymentsDetails.apexp%3FasyncId%3D${deployResult.id}`
        }
      ];
      variant = "error";
      mode = "sticky";
    }

    const evt = new ShowToastEvent({
      title,
      message,
      messageData,
      variant,
      mode
    });
    if (this.publishToastOnCompletion) {
      this.dispatchEvent(evt);
    }

    this.dispatchEvent(
      new CustomEvent("deploymentcompleted", { detail: { deployResult } })
    );
  }

  get hasTestProgress() {
    return this.numberTestsTotal > 0;
  }

  get hasComponentProgress() {
    return this.numberComponentsTotal > 0;
  }

  get hasErrors() {
    return this.errorsByCategory?.length > 0;
  }

  get testProgress() {
    try {
      return (this.numberTestsCompleted / this.numberTestsTotal) * 100;
    } catch (err) {
      return 0;
    }
  }

  get componentProgress() {
    try {
      return (this.completedComponents / this.numberComponentsTotal) * 100;
    } catch (err) {
      return 0;
    }
  }

  get completedComponents() {
    try {
      return this.numberComponentErrors + this.numComponentSuccesses;
    } catch (err) {
      return 0;
    }
  }

  get deploymentFailed() {
    return this.deploymentDone && this.lastDeployResult?.success !== true;
  }

  get deploymentUrl() {
    return this.lastDeployResult?.id === undefined
      ? `/lightning/setup/DeployStatus/home` // no specific Id should go to the general deployment page
      : `/lightning/setup/DeployStatus/page?address=%2Fchangemgmt%2FmonitorDeploymentsDetails.apexp%3FasyncId%3D${this.lastDeployResult.id}`;
  }
}
