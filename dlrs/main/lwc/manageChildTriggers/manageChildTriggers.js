import { api, LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

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
    return this.startDeployment();
  }

  testLevel = "RunSpecifiedTests";
  testLevelOptions = [
    {
      label: "RunSpecifiedTests",
      value: "RunSpecifiedTests"
    },
    // TODO: make this available when it comes out of beta
    // {
    //   label: "RunRelevantTests",
    //   value: "RunRelevantTests"
    // },
    {
      label: "RunLocalTests",
      value: "RunLocalTests"
    }
  ];

  isLoading = true;
  isAdvancedMode = false;
  generatedApex = [];

  async connectedCallback() {
    this.fetchGeneratedApex();
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
          apx.changeIcon = "utility:warning";
          apx.changeIconVariant = "warning";
          apx.changeIconAltText = "Code will be updated via deployment";
          apx.changeOptions = EXISTING_CODE_WITH_UPDATES;
        } else {
          apx.changeType = "ignore";
          apx.changeIcon = "utility:check";
          apx.changeIconVariant = "";
          apx.changeIconAltText = "Code will not be deployed";
          apx.changeOptions = EXISTING_CODE_OPTIONS;
        }
      } else {
        apx.changeType = "deploy";
        apx.changeIcon = "utility:upload";
        apx.changeIconVariant = "success";
        apx.changeIconAltText = "Code will be created via deployment";
        apx.changeOptions = NEW_CODE;
      }
    });
    // if everything is ignore, then default them to remove
    if (
      this.generatedApex.length ===
      this.generatedApex.filter((apx) => apx.changeType === "ignore").length
    ) {
      this.generatedApex.forEach((apx) => {
        apx.changeType = "remove";
        apx.changeIconVariant = "error";
        apx.changeIcon = "utility:clear";
        apx.changeIconAltText = "Code will be removed";
      });
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
    const testsToRun = [];
    let testLevel = "RunSpecifiedTests";
    if (this.isAdvancedMode) {
      testLevel = this.testLevel;
      this.template
        .querySelectorAll("lightning-select[data-mdt-type]")
        .forEach((sel) => {
          const asset = this.generatedApex.find(
            (apx) => apx.assetName === sel.name
          );
          asset.changeType = sel.value;
        });
      testsToRun.push(
        ...this.refs.testsToRun.value.split(",").map((val) => val.trim())
      );
    }
    this.generatedApex.forEach((asset) => {
      if (asset.changeType === "ignore") {
        return;
      }
      if (asset.testedBy) {
        testsToRun.push(...asset.testedBy);
      }
      changePlan[SELECT_OPTIONS[asset.changeType].action].push(
        JSON.parse(JSON.stringify(asset))
      );
    });
    console.log("Change Plan", changePlan, testsToRun);
    const depId = await startDeployment({
      changes: changePlan,
      testLevel,
      testsToRun
    });
    console.log("Async Job Id", depId);
    this.lastDeployStatus = "Started";
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Deployment Started",
        variant: "info"
      })
    );

    this.dispatchEvent(new CustomEvent("deploymentstarted"));
  }

  handleDeploymentCompleted(event) {
    const deployResult = event.detail.deployResult;
    console.log("Deploy Completion Event", deployResult);
    this.isLoading = false;
    this.dispatchEvent(
      new CustomEvent("deploymentcompleted", { detail: event.detail })
    );
  }

  handleAdvancedToggle(event) {
    this.isAdvancedMode = event.target.checked;
  }

  handleTestLevelChange(event) {
    this.testLevel = event.target.value;
  }

  get shouldDisplayTestInput() {
    return this.isAdvancedMode && this.testLevel === "RunSpecifiedTests";
  }
}
