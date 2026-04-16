import { wire, api, LightningElement } from "lwc";
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getChildTriggerInfo from "@salesforce/apex/ManageChildTriggerController.getChildTriggerInfo";
import startDeployment from "@salesforce/apex/ManageChildTriggerController.startDeployment";

import userNotification from "@salesforce/messageChannel/UserNotification__c";

const SELECT_OPTIONS = {
  ignore: {
    label: "Ignore",
    value: "ignore",
    action: "none"
  },
  remove: {
    label: "Remove",
    value: "remove",
    action: "delete"
  },
  update: {
    label: "Update",
    value: "update",
    action: "deploy"
  },
  deploy: {
    label: "Deploy",
    value: "deploy",
    action: "deploy"
  }
};

const EXISTING_CODE_OPTIONS = [SELECT_OPTIONS.ignore, SELECT_OPTIONS.remove];

const EXISTING_CODE_WITH_UPDATES = [
  SELECT_OPTIONS.update,
  SELECT_OPTIONS.ignore,
  SELECT_OPTIONS.remove
];

const NEW_CODE = [SELECT_OPTIONS.deploy, SELECT_OPTIONS.ignore];

export default class ManageChildTriggers extends LightningElement {
  @api
  rollupName;

  @api
  async deploy() {
    return this.startDeployment();
  }

  @wire(MessageContext)
  messageContext;

  subscription = null;

  isLoading = true;
  generatedApex = [];
  lastDeployStatus;
  deploymentStateDetail;
  deploymentErrors;

  async connectedCallback() {
    this.subscribeToMessageChannel();
    this.fetchGeneratedApex();
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }

  async fetchGeneratedApex() {
    this.isLoading = true;
    try {
      this.generatedApex = await getChildTriggerInfo({
        rollupName: this.rollupName
      });
    } catch (err) {
      console.error("Error retrieving generated code:", err);
      throw err;
    }
    this.generatedApex.forEach((apx) => {
      if (apx.existingBody) {
        if (apx.apiVersion !== apx.existingApiVersion) {
          apx.needsApiUpdate = true;
        }
        if (apx.body !== apx.existingBody) {
          apx.needsBodyUpdate = true;
        }
        if (apx.needsBodyUpdate || apx.needsApiUpdate) {
          apx.changeType = "update";
          apx.changeOptions = EXISTING_CODE_WITH_UPDATES;
        } else {
          apx.changeType = "ignore";
          apx.changeOptions = EXISTING_CODE_OPTIONS;
        }
      } else {
        apx.changeType = "deploy";
        apx.changeOptions = NEW_CODE;
      }
    });
    // if everything is ignore, then default them to remove
    if (
      this.generatedApex.length ===
      this.generatedApex.filter((apx) => apx.changeType === "ignore").length
    ) {
      this.generatedApex.forEach((apx) => (apx.changeType = "remove"));
    }
    this.isLoading = false;
  }

  async startDeployment() {
    this.isLoading = true;
    // figure out which elements should be deployed
    // build the list and send it to Apex to build and deploy the zip
    console.log("Deploy started");
    const changePlan = {
      delete: [],
      deploy: []
    };
    Array.from(this.template.querySelectorAll("lightning-select")).forEach(
      (sel) => {
        if (sel.value === "ignore") {
          return;
        }
        const asset = this.generatedApex.find(
          (apx) => apx.assetName === sel.name
        );
        changePlan[SELECT_OPTIONS[sel.value].action].push(
          JSON.parse(JSON.stringify(asset))
        );
      }
    );
    console.log("Change Plan", changePlan);
    const depId = await startDeployment({ changes: changePlan });
    console.log("Async Job Id", depId);
    this.lastDeployStatus = "Started";
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Deployment Started",
        variant: "info"
      })
    );
  }

  evalCompletedDeployment(deploymentData) {
    let title, message, messageData, variant, mode;
    if (deploymentData.status === "Succeeded") {
      title = "Deployment Completed!";
      message = "Metadata saved successfully";
      variant = "success";
      mode = "dismissible";
    } else {
      this.deploymentErrors = [
        ...deploymentData.details.componentFailures.map(
          (failure) => `${failure.fullName}: ${failure.problem}`
        ),
        ...deploymentData.details.runTestResult.failures.map(
          (testRes) => `${testRes.name}: ${testRes.message}`
        )
      ];
      title = "Deployment Failed!";
      message = "{0}";
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

    const evt = new ShowToastEvent({
      title,
      message,
      messageData,
      variant,
      mode
    });
    this.dispatchEvent(evt);
    // update the generated Apex
    this.fetchGeneratedApex();
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  // Handler for message received by component
  handleMessage(message) {
    console.log("Message:", message);
    if (message.type !== "DeploymentResult") {
      return;
    }
    if (message.payload === undefined) {
      return;
    }
    const res = JSON.parse(message.payload);
    if (Array.isArray(res)) {
      // must be an array of errors
      this.reportDeploymentErrors(res);
    }
    this.lastDeployStatus = res.status;
    this.deploymentStateDetail = res.stateDetail;
    if (res.done === false) {
      console.log("Deployment " + res.status);
      return;
    }
    console.log("Deployment done ", res);
    this.isLoading = false;
    this.lastDeployStatus = undefined;
    this.deploymentStateDetail = undefined;
    this.evalCompletedDeployment(res);
  }

  reportDeploymentErrors(errors) {
    let title, variant, mode;

    this.deploymentErrors = errors.map((err) => err.message);
    title = "Deployment Failed!";
    variant = "error";
    mode = "sticky";

    const evt = new ShowToastEvent({
      title,
      variant,
      mode
    });
    this.dispatchEvent(evt);
    this.isLoading = false;
  }

  subscribeToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        userNotification,
        (message) => this.handleMessage(message),
        { scope: APPLICATION_SCOPE }
      );
    }
  }
}

/**
 * if the object can be merged then we need to ensure a trigger is added to the parent. Behavior is toggleable
 *
 * Display the planned Apex that will be deployed
 *
 * Merge parent trigger should be the same as child trigger code, I'm pretty sure.
 *
 * pass the text files down to Apex then Apex builds the ZIP and passes that for deployment using Async actions.
 * Those Async actions should behave like deleting using the new wizard does. Do the work in the Queueable Apex but notify the front-end using Platform Events
 * // backup using poling??
 */
