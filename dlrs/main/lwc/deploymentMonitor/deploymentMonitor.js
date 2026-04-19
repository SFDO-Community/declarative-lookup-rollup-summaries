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

// when a deployment is finished, we should have a "countdown" that auto-dismisses when finishes
export default class DeploymentMonitor extends LightningElement {
  @wire(MessageContext)
  messageContext;

  @api
  publishToastOnCompletion = false;

  @api
  monitorDeployment(deploymentId) {
    this.deploymentId = deploymentId;
    this.requestDeploymentUpdate();
  }

  deploymentId;
  deploymentStatus;
  deploymentStateDetail;
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
      if (message.type !== "DeploymentResult") {
        return;
      }
      if (message.payload === undefined) {
        return;
      }

      const res = JSON.parse(message.payload);

      if (Array.isArray(res)) {
        // Update status
        this.deploymentStatus = "Failed";
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

      this.writeDeploymentUpdate(res);
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

  async requestDeploymentUpdate() {
    const jobId = requestDeploymentStatusCheck({
      deploymentId: this.deploymentId
    });
    console.log("Requested update, job id:", jobId);
  }

  writeDeploymentUpdate(deployResult) {
    this.deploymentId = deployResult.id;

    clearTimeout(this.nextUpdateTimeout);
    // queue the next update request
    setTimeout(() => {
      this.requestDeploymentUpdate();
    }, 3000); // TODO: use heuristic to determine when next update should be requested

    // Update status
    this.deploymentStatus = deployResult.status;
    // Update current state
    this.deploymentStateDetail = deployResult.stateDetail;
    // Update errors of different types
    this.errorsByCategory = [];

    if (deployResult.details.componentFailures?.length) {
      this.errorsByCategory.push({
        label: "Component Failures",
        errors: deployResult.details.componentFailures.map(
          (failure) => `${failure.fullName}: ${failure.problem}`
        )
      });
    }
    if (deployResult.details.runTestResult.codeCoverageWarnings?.length) {
      this.errorsByCategory.push({
        label: "Code Coverage Warnings",
        errors: deployResult.details.runTestResult.codeCoverageWarnings.map(
          (failure) => `${failure.name}: ${failure.message}`
        )
      });
    }
    if (deployResult.details.runTestResult?.length) {
      this.errorsByCategory.push({
        label: "Test Failures",
        errors: deployResult.details.runTestResult.failures.map(
          (testRes) => `${testRes.name}: ${testRes.message}`
        )
      });
    }

    if (!deployResult.done) {
      return;
    }

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
}
