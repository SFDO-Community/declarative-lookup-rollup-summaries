import { api, LightningElement } from "lwc";

import getChildTriggerInfo from "@salesforce/apex/ManageChildTriggerController.getChildTriggerInfo";
import startDeployment from "@salesforce/apex/ManageChildTriggerController.startDeployment";

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
    console.log("Deployment Id", depId);
  }

  isLoading = true;

  generatedApex = [];

  async connectedCallback() {
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
    this.isLoading = false;
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
